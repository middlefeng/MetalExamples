#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <Quartz/Quartz.h>

@protocol NuoMetalViewDelegate;



@interface NuoMetalView : NSView

/**
 *  The delegate of this view, responsible for maintain the model/scene state,
 *  and the rendering
 */
@property (nonatomic, weak) id<NuoMetalViewDelegate> delegate;

@property (nonatomic) NSInteger preferredFramesPerSecond;

@property (nonatomic) MTLPixelFormat colorPixelFormat;
@property (nonatomic, assign) MTLClearColor clearColor;

@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;
@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;

//  TODO: move to delegate
@property (nonatomic, assign) float rotationX;
@property (nonatomic, assign) float rotationY;
@property (nonatomic, assign) float zoom;

@property (nonatomic, readonly) CGSize drawableSize;

@end



@protocol NuoMetalViewDelegate <NSObject>

- (void)drawInView:(NuoMetalView *)view;

@end
