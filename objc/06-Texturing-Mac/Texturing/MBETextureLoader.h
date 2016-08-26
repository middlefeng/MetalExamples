
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>

@interface MBETextureLoader : NSObject

+ (instancetype)sharedTextureLoader;

- (id<MTLTexture>)texture2DWithImageNamed:(NSString *)imageName
                                mipmapped:(BOOL)mipmapped
                             commandQueue:(id<MTLCommandQueue>)queue;

@end
