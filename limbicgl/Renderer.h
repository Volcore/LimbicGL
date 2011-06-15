//
//  Renderer.h
//  LimbicGL
//
//  Created by Volker Schönefeld on 6/12/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <limbicgl/drivers/Driver.h>

@class CAEAGLLayer;
@class RenderTarget;

class Game;

@interface Renderer : NSObject {
@private
    Game *game_;
    RenderTarget *rendertarget;
    id<Driver> driver;
}

// Called whenever the underlying UIView is re-layouted
- (void)setLayer:(CAEAGLLayer *)layer;
// start animating the scene at 60hz
- (void)startAnimation;
// stop the animation
- (void)stopAnimation;

@end
