//
//  ModelView.h
//  ModelViewer
//
//  Created by middleware on 8/26/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import "NuoMetalView.h"




@interface ModelView : NuoMetalView

//  TODO: move to delegate
@property (nonatomic, assign) float rotationX;
@property (nonatomic, assign) float rotationY;
@property (nonatomic, assign) float zoom;


- (IBAction)openFile:(id)sender;

@end
