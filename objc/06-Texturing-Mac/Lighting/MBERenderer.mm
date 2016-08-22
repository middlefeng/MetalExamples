#import "MBERenderer.h"
#import "MBEMathUtilities.h"
#import "MBEOBJMesh.h"
#import "MBETypes.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#import <simd/simd.h>

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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Satellite" withExtension:@"obj"];
    _mesh = [[MBEOBJMesh alloc] initWithPath:modelURL.path device:_device];
    
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
}

- (void)updateUniformsForView:(MBEMetalView *)view duration:(NSTimeInterval)duration
{
    self.time += duration;
    self.rotationX = view.rotationX;
    self.rotationY = view.rotationY;
    float scaleFactor = 1;
    const vector_float3 xAxis = { 1, 0, 0 };
    const vector_float3 yAxis = { 0, 1, 0 };
    const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis, self.rotationX);
    const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
    const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
    const matrix_float4x4 rotationMatrix = matrix_multiply(matrix_multiply(xRot, yRot), scale);

    
    const vector_float3 translationToCenter =
    {
        -_mesh.boundingBox.centerX,
        -_mesh.boundingBox.centerY,
        -_mesh.boundingBox.centerZ
    };
    const matrix_float4x4 modelCenteringMatrix = matrix_float4x4_translation(translationToCenter);
    const matrix_float4x4 modelMatrix = matrix_multiply(rotationMatrix, modelCenteringMatrix);
    
    float modelSpanZ = _mesh.boundingBox.spanZ;
    float modelNearest = - modelSpanZ / 2.0;
    
    const vector_float3 cameraTranslation =
    {
        0, 0,
        (modelNearest - modelSpanZ) + view.zoom * modelSpanZ / 20.0f
    };

    const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);

    const CGSize drawableSize = view.metalLayer.drawableSize;
    const float aspect = drawableSize.width / drawableSize.height;
    const float fov = (2 * M_PI) / 8;
    const float near = 0.1;
    const float far = -(modelNearest - modelSpanZ) + modelSpanZ * 2.0f - view.zoom * modelSpanZ / 20.0f;
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
