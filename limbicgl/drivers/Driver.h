//
//  Driver.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/15/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RenderTarget;
@class CAEAGLLayer;

@protocol Driver
// Activates the automatic 60hz rendering of the game
- (void) startAnimation;
// Stops the automatic rendering
- (void) stopAnimation;
// Releases all the allocated assets and modules
- (void) teardown;
// Called each time the underlying UIView is re-layouted
- (void) setLayer:(CAEAGLLayer*)layer;
@end
