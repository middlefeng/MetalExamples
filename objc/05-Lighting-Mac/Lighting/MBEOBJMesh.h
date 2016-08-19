@import Foundation;
@import Metal;
#import "MBEMesh.h"

@class MBEOBJGroup;
@class MDLMesh;

@interface MBEOBJMesh : MBEMesh

- (instancetype)initWithGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device;
- (instancetype)initWithMesh:(MDLMesh*)mesh withGroup:(MBEOBJGroup *)group device:(id<MTLDevice>)device;

@end
