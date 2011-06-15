//
//  Renderer.mm
//  LimbicGL
//
//  Created by Volker Schönefeld on 6/12/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Renderer.h"
#include <performancemonitor/performancemonitor.h>
#include <limbicgl/game/game.h>


@interface Renderer()
@property (nonatomic, assign) CADisplayLink *displayLink;
@property (nonatomic, retain) EAGLContext *context;
- (void)createFramebuffer;
- (void)setFramebuffer;
- (void)presentFramebuffer;
- (void)deleteFramebuffer;
- (void)drawFrame;
@end

@implementation Renderer

@synthesize animating;
@synthesize displayLink;
@synthesize context;
@synthesize layer;

- (void)setLayer:(CAEAGLLayer *)l {
  NSLog(@"setLayer called");
  layer = l;
  @synchronized(context) {
    NSLog(@"SetLayer starting.");
    [EAGLContext setCurrentContext:context];
    [self deleteFramebuffer];
    [self createFramebuffer];
    glFlush();
    [EAGLContext setCurrentContext:nil];
    NSLog(@"SetLayer done.");
  }
}

- (void)newTriggerDrawFrame {
  @synchronized(context) {
    PerformanceMonitor *pm = PerformanceMonitor::Shared();
    pm->FrameStart();
    BOOL res = [EAGLContext setCurrentContext:thread_context];
    assert(res == YES);
    [self drawFrame];
    glFlush();
    [EAGLContext setCurrentContext:nil];
    pm->FrameEnd();
    pm->UpdateStart();
    game_->Update();
    pm->UpdateEnd();
  }
}

- (void) threadMainLoop {
  renderthread = [NSThread currentThread];
  NSLog(@"Entering animation thread...");
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  NSRunLoop* loop = [NSRunLoop currentRunLoop];
  CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(newTriggerDrawFrame)];
  [aDisplayLink setFrameInterval:1];
  [aDisplayLink addToRunLoop:loop forMode:NSDefaultRunLoopMode];
  aDisplayLink.paused = YES;
  displayLink = aDisplayLink;
  thread_context = [[EAGLContext alloc] initWithAPI:self.context.API sharegroup:self.context.sharegroup];
  [NSThread sleepForTimeInterval:1.0];
  // run the loop one event at a time
  while (animating && [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
  // clean up
  [thread_context release];
  [pool release];
  NSLog(@"Shutting down animation thread...");
}

- (id)init
{
    NSLog(@"Init");
    self = [super init];
    if (self) {
        animating = FALSE;
        animationFrameInterval = 1;
        self.displayLink = nil;
        NSLog(@"Creating queue");
        queue = dispatch_queue_create("com.limbic.gltest.renderingqueue", 0);
        //queue = dispatch_get_main_queue();
        //dispatch_sync(queue, ^{
            NSLog(@"Creating context");
            // Create the context
            EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            if (!aContext)
                NSLog(@"Failed to create ES context");
            else if (![EAGLContext setCurrentContext:aContext])
                NSLog(@"Failed to set ES context current");
            self.context = aContext;
            [aContext release];
            [EAGLContext setCurrentContext:nil];
        game_ = new Game();
        [NSThread detachNewThreadSelector:@selector(threadMainLoop) toTarget:self withObject:nil];
        //});
        //dispatch_async(queue, ^{
          //NSLog(@"Allocating thread context");
          //thread_context = [[EAGLContext alloc] initWithAPI:self.context.API sharegroup:self.context.sharegroup];
        //});
    }
    return self;
}

- (void) tearDown {
    NSLog(@"Teardown called");
    // Synchronosuly tear down
    //dispatch_sync(queue, ^{
    @synchronized(context) {
        NSLog(@"Running Teardown");
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        [self deleteFramebuffer];    
        // Tear down context.
        if ([EAGLContext currentContext] == context)
            [EAGLContext setCurrentContext:nil];
        [context release];
        [thread_context release];
        context = nil;
    }
    //});
}

- (void) dealloc {
    NSLog(@"Dealloc called");
    [self tearDown];
    dispatch_release(queue);
    [super dealloc];
}

- (void) startAnimation {
    NSLog(@"startAnimation called");
    if (!animating) {
        NSLog(@"Creating display link...");
        // Create the thread
        animating = TRUE;
        self.displayLink.paused = NO;
        /*CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(triggerDrawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [aDisplayLink addToRunLoop:loop forMode:NSRunLoopCommonModes];
        self.displayLink = aDisplayLink;*/
    }
}

- (void) stopAnimation {
    NSLog(@"stopAnimation called");
    if (animating) {
        NSLog(@"freeing stopAnimation");
        //[self.displayLink invalidate];
        //self.displayLink = nil;
        animating = FALSE;
        self.displayLink.paused = YES;
    }
}

- (NSInteger)animationFrameInterval {
    NSLog(@"animationFrameInterval called");
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    NSLog(@"setAnimationFrameInterval called");
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}


- (void)drawFrame {
      //NSLog(@"drawFrame called");
    //assert(dispatch_get_current_queue() == queue);
    [self setFramebuffer];
    game_->Draw();
    PerformanceMonitor::Shared()->Draw(framebufferWidth, framebufferHeight);
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"Error during draw: %i", error);
    }
    [self presentFramebuffer];
}

- (void)triggerDrawFrame {
    dispatch_async(queue, ^{
        //NSLog(@"Waiting to draw frame...");
        //@synchronized(context) {
            //NSLog(@"Drawing frame");
            BOOL res = [EAGLContext setCurrentContext:thread_context];
            assert(res == YES);
            [self drawFrame];
            glFlush();
            [EAGLContext setCurrentContext:nil];
            //NSLog(@"Drawing frame done");
       //}
    });
}

- (void)createFramebuffer {
    NSLog(@"createFramebuffer called");
    //assert(dispatch_get_current_queue() == queue);
    if (!defaultFramebuffer) {
        NSLog(@"createFramebuffer run");        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        NSLog(@"%i/%i fb size", framebufferWidth, framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
    }
}

- (void)deleteFramebuffer {
    NSLog(@"deleteFramebuffer called");
    if (context) {
        NSLog(@"deleteFramebuffer run");
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer {
    assert(defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, framebufferWidth, framebufferHeight);
}

- (void)presentFramebuffer {
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    BOOL success = [thread_context presentRenderbuffer:GL_RENDERBUFFER];
    assert(success == YES);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

@end
