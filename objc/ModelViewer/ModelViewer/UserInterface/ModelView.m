//
//  ModelView.m
//  ModelViewer
//
//  Created by middleware on 8/26/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import "ModelView.h"
#import "ModelViewerRenderer.h"



@implementation ModelView
{
    ModelRenderer* _render;
}


- (void)commonInit
{
    [super commonInit];
    _render = [ModelRenderer new];
    self.delegate = _render;
}


- (void)mouseDragged:(NSEvent *)theEvent
{
    _rotationX -= 0.01 * M_PI * theEvent.deltaY;
    _rotationY -= 0.01 * M_PI * theEvent.deltaX;
    [self render];
}


- (void)magnifyWithEvent:(NSEvent *)event
{
    _zoom += 0.01 * event.deltaZ;
    [self render];
}



- (IBAction)openFile:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result)
            {
                if (result == NSFileHandlingPanelOKButton)
                {
                    NSString* path = openPanel.URL.path;
                    [_render loadMesh:path];
                    [self render];
                }
            }];
}



@end
