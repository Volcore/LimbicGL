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

@class CAEAGLLayer;

@interface Renderer : NSObject {
@private
    dispatch_queue_t queue;
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
    EAGLContext *context, *thread_context;
    GLuint program;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) CAEAGLLayer *layer;

- (void)tearDown;

- (void)startAnimation;
- (void)stopAnimation;

- (void)asyncDeleteFramebuffer;

@end
