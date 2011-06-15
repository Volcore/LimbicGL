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
#import "RenderTarget.h"

#import "SingleThreadDriver.h"
#import "ThreadedDriver.h"
#import "GCDDriver.h"
#include <limbicgl/config.h>


@interface Renderer()
//@property (nonatomic, assign) CADisplayLink *displayLink;
//@property (nonatomic, retain) EAGLContext *context;
//- (void)drawFrame;
@end

@implementation Renderer

//@synthesize displayLink;
//@synthesize context;

/*- (void)setLayer:(CAEAGLLayer *)l {
  // Set layer is called every time the underlying view is updated/layouted
  // This means the renderbuffers need to be re-allocated
  NSLog(@"setLayer called");
  @synchronized(context) {
    NSLog(@"SetLayer starting.");
    [EAGLContext setCurrentContext:context];
    [rendertarget deleteFramebuffer];
    [rendertarget createFramebuffer:l forContext:context];
    //[self deleteFramebuffer];
    //[self createFramebuffer];
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
  aDisplayLink.paused = NO;
  displayLink = aDisplayLink;
  thread_context = [[EAGLContext alloc] initWithAPI:self.context.API sharegroup:self.context.sharegroup];
  //[NSThread sleepForTimeInterval:1.0];
  // run the loop one event at a time
  while (animating && [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
  // clean up
  [thread_context release];
  [pool release];
  NSLog(@"Shutting down animation thread...");
}*/

- (void)setLayer:(CAEAGLLayer *)layer {
  [driver setLayer:layer];
}

- (id)init {
    self = [super init];
    if (self) {
        game_ = new Game();
        rendertarget = [[RenderTarget alloc] init];
#if DRIVER == GCDDRIVER
        driver = [[GCDDriver alloc] initWithRenderTarget:rendertarget andGame:game_];
#elif DRIVER == THREADEDDRIVER
        driver = [[ThreadedDriver alloc] initWithRenderTarget:rendertarget andGame:game_];        
#else
        driver = [[SingleThreadDriver alloc] initWithRenderTarget:rendertarget andGame:game_];
#endif
        /*
        animating = NO;
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

        //});
        //dispatch_async(queue, ^{
          //NSLog(@"Allocating thread context");
          //thread_context = [[EAGLContext alloc] initWithAPI:self.context.API sharegroup:self.context.sharegroup];
        //});*/
    }
    return self;
}
/*
- (void) tearDown {
    NSLog(@"Teardown called");
    // Synchronosuly tear down
    //dispatch_sync(queue, ^{
    @synchronized(context) {
        NSLog(@"Running Teardown");
        //[self deleteFramebuffer];    
        // Tear down context.
        if ([EAGLContext currentContext] == context)
            [EAGLContext setCurrentContext:nil];
        [context release];
        [thread_context release];
        context = nil;
    }
    //});
}*/

- (void) dealloc {
    delete game_;
    [driver teardown];
    [(NSObject*)driver release];
    [rendertarget release];
    [super dealloc];
}

- (void) startAnimation {
    [driver startAnimation];
    /*NSLog(@"startAnimation called");
    if (!animating) {
        NSLog(@"Creating display link...");
        // Create the thread
        animating = TRUE;
        [NSThread detachNewThreadSelector:@selector(threadMainLoop) toTarget:self withObject:nil];
        self.displayLink.paused = NO;
        /*CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(triggerDrawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [aDisplayLink addToRunLoop:loop forMode:NSRunLoopCommonModes];
        self.displayLink = aDisplayLink;//* /
    }*/
}

- (void) stopAnimation {
    [driver stopAnimation];
    /*NSLog(@"stopAnimation called");
    if (animating) {
        NSLog(@"freeing stopAnimation");
        //[self.displayLink invalidate];
        //self.displayLink = nil;
        animating = FALSE;
        self.displayLink.paused = YES;
    }*/
}
/*
- (void)drawFrame {
      //NSLog(@"drawFrame called");
    //assert(dispatch_get_current_queue() == queue);
    [rendertarget setFramebuffer];
    game_->Draw();
    PerformanceMonitor::Shared()->Draw(rendertarget->framebufferWidth, rendertarget->framebufferHeight);
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"Error during draw: %i", error);
    }
    [rendertarget presentFramebuffer:thread_context];
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
}*/

@end
