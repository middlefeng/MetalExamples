#import <Metal/Metal.h>
#import "MBEMesh.h"

@class MBEOBJGroup;

@interface MBEOBJMesh : MBEMesh

- (instancetype)initWithPath:(NSString*)path device:(id<MTLDevice>)device;

@end
