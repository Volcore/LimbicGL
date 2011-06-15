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
    /*dispatch_queue_t queue;
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
    EAGLContext *context, *thread_context;*/
    Game *game_;
    //NSThread *renderthread;
    RenderTarget *rendertarget;
    id<Driver> driver;
}

- (void)setLayer:(CAEAGLLayer *)l;

- (void)startAnimation;
- (void)stopAnimation;

@end
