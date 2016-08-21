#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>

@interface MBEMesh : NSObject
@property (nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (nonatomic, readonly) id<MTLBuffer> indexBuffer;
@end
