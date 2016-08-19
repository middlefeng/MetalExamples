#import "MBERenderer.h"
#import "MBEMathUtilities.h"
#import "MBEOBJModel.h"
#import "MBEOBJMesh.h"
#import "MBETypes.h"

#import <MetalKit/MetalKit.h>

@import Metal;
@import QuartzCore.CAMetalLayer;
@import simd;

static const NSInteger MBEInFlightBufferCount = 3;

@interface MBERenderer ()
@property (strong) id<MTLDevice> device;
@property (strong) MBEMesh *mesh;
@property (strong) NSArray<id<MTLBuffer>>* uniformBuffers;
@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX, rotationY, time;
@end

@implementation MBERenderer

- (instancetype)init
{
    if ((self = [super init]))
    {
        _device = MTLCreateSystemDefaultDevice();
        _displaySemaphore = dispatch_semaphore_create(MBEInFlightBufferCount);
        [self makePipeline];
        [self makeResources];
    }

    return self;
}

- (void)makePipeline
{
    self.commandQueue = [self.device newCommandQueue];

    id<MTLLibrary> library = [self.device newDefaultLibrary];

    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertex_project"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_light"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;

    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];

    NSError *error = nil;
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                           error:&error];

    if (!self.renderPipelineState)
    {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }

    self.commandQueue = [self.device newCommandQueue];
}

- (void)makeResources
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"teapot" withExtension:@"obj"];
    MBEOBJModel *model = [[MBEOBJModel alloc] initWithContentsOfURL:modelURL generateNormals:YES];
    MBEOBJGroup *group = [model groupForName:@"Rectangle047"];
    // _mesh = [[MBEOBJMesh alloc] initWithGroup:group device:_device];

    id<MTLBuffer> buffers[MBEInFlightBufferCount];
    for (size_t i = 0; i < MBEInFlightBufferCount; ++i)
    {
        id<MTLBuffer> uniformBuffer = [self.device newBufferWithLength:sizeof(MBEUniforms)
                                                               options:MTLResourceOptionCPUCacheModeDefault];
        buffers[i] = uniformBuffer;
        
        NSString* label = [NSString stringWithFormat:@"Uniforms %lu", i];
        [uniformBuffer setLabel:label];
    }
    _uniformBuffers = [[NSArray alloc] initWithObjects:buffers[0],
                                                       buffers[1],
                                                       buffers[2], nil];
    
    
    
    MTLVertexDescriptor *mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];
    
    // Positions.
    mtlVertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    mtlVertexDescriptor.attributes[0].offset = 0;
    mtlVertexDescriptor.attributes[0].bufferIndex = 0;
    
    // Normals.
    mtlVertexDescriptor.attributes[1].format = MTLVertexFormatFloat3;
    mtlVertexDescriptor.attributes[1].offset = 16;
    mtlVertexDescriptor.attributes[1].bufferIndex = 0;
    
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(mtlVertexDescriptor);
    mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
    mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
    
    MTKMeshBufferAllocator *bufferAllocator = [[MTKMeshBufferAllocator alloc] initWithDevice:_device];
    
    MDLAsset* asset = [[MDLAsset alloc] initWithURL:modelURL vertexDescriptor:nil bufferAllocator:bufferAllocator];
    NSLog(@"Object Count: %lu.", asset.count);
    
    /*
    MDLVertexDescriptor* desc = asset.vertexDescriptor;
    NSMutableArray<MDLVertexAttribute*> *attributes = desc.attributes;
    for (size_t i = 0; i < attributes.count; ++i)
    {
        NSLog(@"Attrbute: %@.", attributes[0].name);
    }
     */
        
    MDLMesh* mesh = (MDLMesh*)[asset objectAtIndex:0];
    NSLog(@"Vertex Count: %lu.", mesh.vertexCount);
    NSLog(@"Buffer Count: %lu.", mesh.vertexBuffers.count);
    
    MDLVertexDescriptor* desc = mesh.vertexDescriptor;
    MDLVertexAttributeData* attrDataPos = [mesh vertexAttributeDataForAttributeNamed:MDLVertexAttributePosition];
    MDLVertexAttributeData* attrDataNor = [mesh vertexAttributeDataForAttributeNamed:MDLVertexAttributeNormal];
    
    NSLog(@"Sub-meshes: %lu.", mesh.submeshes.count);
    
    MDLSubmesh* submesh = mesh.submeshes[0];
    NSLog(@"Index Count: %lu.", submesh.indexCount);
    
    _mesh = [[MBEOBJMesh alloc] initWithMesh:mesh withGroup:group device:_device];
}

- (void)updateUniformsForView:(MBEMetalView *)view duration:(NSTimeInterval)duration
{
    self.time += duration;
    self.rotationX += duration * (M_PI / 2);
    self.rotationY += duration * (M_PI / 3);
    float scaleFactor = 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);

    const vector_float3 cameraTranslation = { 0, 0, -1.5 };
    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 5;
    const float near = 0.1;
    const float far = 800;
    const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect, fov, near, far);

    MBEUniforms uniforms;
    uniforms.modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix);
    uniforms.modelViewProjectionMatrix = matrix_multiply(projectionMatrix, uniforms.modelViewMatrix);
    uniforms.normalMatrix = matrix_float4x4_extract_linear(uniforms.modelViewMatrix);

    memcpy([self.uniformBuffers[self.bufferIndex] contents], &uniforms, sizeof(uniforms));
}

- (void)drawInView:(MBEMetalView *)view
{
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);

    view.clearColor = MTLClearColorMake(0.95, 0.95, 0.95, 1);

    [self updateUniformsForView:view duration:view.frameDuration];

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    MTLRenderPassDescriptor *passDescriptor = [view currentRenderPassDescriptor];

    id<MTLRenderCommandEncoder> renderPass = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderPass setRenderPipelineState:self.renderPipelineState];
    [renderPass setDepthStencilState:self.depthStencilState];
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];

    [renderPass setVertexBuffer:self.mesh.vertexBuffer offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffers[self.bufferIndex] offset:0 atIndex:1];

    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[self.mesh.indexBuffer length] / sizeof(MBEIndex)
                            indexType:MBEIndexType
                          indexBuffer:self.mesh.indexBuffer
                    indexBufferOffset:0];

    [renderPass endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];

    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % MBEInFlightBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    
    [commandBuffer commit];
}

@end
