#import <Metal/Metal.h>
#import "MBEMesh.h"

@class MBEOBJGroup;

@interface MBEOBJMesh : MBEMesh

- (instancetype)initWithGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device;
- (instancetype)initWithPath:(NSString*)path device:(id<MTLDevice>)device;

@end
