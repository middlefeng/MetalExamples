#import <Metal/Metal.h>



@interface BoundingBox : NSObject

@property (nonatomic, assign) float centerX;
@property (nonatomic, assign) float centerY;
@property (nonatomic, assign) float centerZ;

@property (nonatomic, assign) float spanX;
@property (nonatomic, assign) float spanY;
@property (nonatomic, assign) float spanZ;

@end



@interface MBEOBJMesh : NSObject

@property (nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (nonatomic, readonly) id<MTLBuffer> indexBuffer;

@property (nonatomic, readonly) BoundingBox* boundingBox;

- (instancetype)initWithPath:(NSString*)path device:(id<MTLDevice>)device;

@end
