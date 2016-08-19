#import "MBEOBJMesh.h"
#import "MBEOBJGroup.h"

#import <ModelIO/ModelIO.h>
#import <MetalKit/MetalKit.h>

#import <simd/simd.h>
typedef struct __attribute((packed))
{
    vector_float4 position;
    vector_float4 normal;
} MBEVertex;

@implementation MBEOBJMesh

@synthesize indexBuffer=_indexBuffer;
@synthesize vertexBuffer=_vertexBuffer;

- (instancetype)initWithGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device
{
    if ((self = [super init]))
    {
        _vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes]
                                            length:[group.vertexData length]
                                           options:MTLResourceOptionCPUCacheModeDefault];
        
        NSLog(@"Vertex Count: %lu.", [group.vertexData length] / (sizeof(MBEVertex)));
        
        [_vertexBuffer setLabel:[NSString stringWithFormat:@"Vertices (%@)", group.name]];
        
        _indexBuffer = [device newBufferWithBytes:[group.indexData bytes]
                                           length:[group.indexData length]
                                          options:MTLResourceOptionCPUCacheModeDefault];
        
        NSLog(@"Index Count: %lu.", [group.indexData length]);
        
        [_indexBuffer setLabel:[NSString stringWithFormat:@"Indices (%@)", group.name]];
    }
    return self;
}



- (instancetype)initWithMesh:(MDLMesh*)mesh withGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device
{
    if ((self = [super init]))
    {
        MDLSubmesh* submesh = mesh.submeshes[0];
        
        MTKMesh* mtkMesh = [[MTKMesh alloc] initWithMesh:mesh device:device error:nil];
        _vertexBuffer = mtkMesh.vertexBuffers[0].buffer;
        
        MTKSubmesh* mtkSubmesh = mtkMesh.submeshes[0];
        _indexBuffer = mtkSubmesh.indexBuffer.buffer;
        
        /*
        id<MDLMeshBuffer> buffer = mesh.vertexBuffers[0];
        MDLMeshBufferMap* map = buffer.map;
        
        _vertexBuffer = [device newBufferWithBytes:[map bytes]
                                            length:[buffer length]
                                           options:MTLResourceOptionCPUCacheModeDefault];
        _vertexBuffer = [device newBufferWithBytes:[group.vertexData bytes]
                                            length:[group.vertexData length]
                                           options:MTLResourceOptionCPUCacheModeDefault];
         */
        
        [_vertexBuffer setLabel:[NSString stringWithFormat:@"Vertices (%@)", @"Vertex"]];
        
        
        /*
        id<MDLMeshBuffer> indexBuffer = submesh.indexBuffer;
        MDLMeshBufferMap* indexBufferMap = indexBuffer.map;
        
        _indexBuffer = [device newBufferWithBytes:[indexBufferMap bytes]
                                           length:[indexBuffer length]
                                          options:MTLResourceOptionCPUCacheModeDefault];
         */
        
        [_indexBuffer setLabel:[NSString stringWithFormat:@"Indices (%@)", @"Index"]];
    }
    return self;
}


@end
