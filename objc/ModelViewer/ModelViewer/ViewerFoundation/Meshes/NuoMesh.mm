
#import "NuoMesh.h"

#include "MBETypes.h"
#include "tiny_obj_loader.h"

// Test
#include "NuoModelLoader.h"
#include "NuoModelBase.h"



@implementation NuoMeshBox

@end



@implementation NuoMesh

@synthesize indexBuffer = _indexBuffer;
@synthesize vertexBuffer = _vertexBuffer;

bool operator==(const MBEVertex& a, const MBEVertex& b)
{
    return a.position.x == b.position.x &&
            a.position.y == b.position.y &&
            a.position.z == b.position.z &&
            a.normal.x == b.normal.x &&
            a.normal.y == b.normal.y &&
            a.normal.z == b.normal.z;
}

@synthesize boundingBox = _boundingBox;


- (instancetype)initWithDevice:(id<MTLDevice>)device
            withVerticesBuffer:(void*)buffer withLength:(size_t)length
                   withIndices:(void*)indices withLength:(size_t)indicesLength
{
    if ((self = [super init]))
    {
        _vertexBuffer = [device newBufferWithBytes:buffer
                                            length:length
                                           options:MTLResourceOptionCPUCacheModeDefault];
        
        _indexBuffer = [device newBufferWithBytes:indices
                                           length:indicesLength
                                          options:MTLResourceOptionCPUCacheModeDefault];
    }
    
    return self;

}


@end
