#import <Metal/Metal.h>



@interface NuoMeshBox : NSObject

@property (nonatomic, assign) float centerX;
@property (nonatomic, assign) float centerY;
@property (nonatomic, assign) float centerZ;

@property (nonatomic, assign) float spanX;
@property (nonatomic, assign) float spanY;
@property (nonatomic, assign) float spanZ;

@end



@interface NuoMesh : NSObject

@property (nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (nonatomic, readonly) id<MTLBuffer> indexBuffer;

@property (nonatomic, strong) NuoMeshBox* boundingBox;

- (instancetype)initWithPath:(NSString*)path device:(id<MTLDevice>)device;

- (instancetype)initWithDevice:(id<MTLDevice>)device
            withVerticesBuffer:(void*)buffer withLength:(size_t)length
                   withIndices:(void*)indices withLength:(size_t)indicesLength;

@end
