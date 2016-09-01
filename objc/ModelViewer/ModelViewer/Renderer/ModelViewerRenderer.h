#import "ModelView.h"



@interface ModelRenderer : NSObject <NuoMetalViewDelegate>

- (void)loadMesh:(NSString*)path;

@end
