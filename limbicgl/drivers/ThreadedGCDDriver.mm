//
//  ThreadedGCDDriver.m
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/27/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ThreadedGCDDriver.h"
#include <limbicgl/config.h>
#import "RenderTarget.h"
#include <performancemonitor/performancemonitor.h>
#include <limbicgl/game/game.h>

@implementation ThreadedGCDDriver

- (id) initWithRenderTarget:(RenderTarget*)renderTarget andGame:(Game*)game {
  VerboseLog("");
  context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  renderthread_ = nil;
  rendertarget_ = renderTarget;
  animating_ = false;
  game_ = game;
  queue_ = dispatch_queue_create("com.limbic.limbicgl.threadedgcdqueue", 0);
  running_ = false;
  frame_drop_counter_ = 0;
  return self;
}

- (void) startAnimation {
  VerboseLog("");
  if (animating_ == false) {
    animating_ = true;
    renderthread_ = [[NSThread alloc] initWithTarget:self selector:@selector(threadMainLoop) object:nil];
    [renderthread_ start];
  }
}

- (void) stopAnimation {
  VerboseLog("");
  if (animating_ == true) {
    animating_ = false;
    CFRunLoopStop([renderloop_ getCFRunLoop]);
    // Wait for the thread to finish
    @synchronized(renderthread_) {
      [renderthread_ release];
      renderthread_ = nil;
    }
  }
}

- (void) teardown {
  VerboseLog("");
  [self stopAnimation];
  @synchronized(context_) {
    if (context_) {
      if (context_ == [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:nil];
      }
      [context_ release];
      context_ = nil;
    }
  }
}

- (void) setLayer:(CAEAGLLayer*)layer {
  VerboseLog("");
  @synchronized(context_) {
    [EAGLContext setCurrentContext:context_];
    [rendertarget_ deleteFramebuffer];
    [rendertarget_ createFramebuffer:layer forContext:context_];
    [EAGLContext setCurrentContext:nil];
  }
}

- (void) drawFrame {
  VerboseLog("");
  PerformanceMonitor *pm = PerformanceMonitor::Shared();
  pm->FrameStart();
  @synchronized(context_) {
    [EAGLContext setCurrentContext:context_];
    [rendertarget_ setFramebuffer];
    game_->Draw();
    pm->Draw(rendertarget_->framebufferWidth, rendertarget_->framebufferHeight);
    [rendertarget_ presentFramebuffer:context_];
    glFlush();
    [EAGLContext setCurrentContext:nil];
  }
  pm->FrameEnd();
  pm->UpdateStart();
  game_->Update();
  pm->UpdateEnd();

}

- (void) triggerDrawFrame {
  VerboseLog("");
  if (running_ == false) {
    running_ = true;
    dispatch_async(queue_, ^{
      [self drawFrame];
      running_ = false;
    });
  } else {
    frame_drop_counter_++;
    VerboseLog(@"Dropped a frame!");
  }
}

- (void) threadMainLoop {
  VerboseLog("");
  // Synchronize this with the main thread so stopAnimation waits for this to complete
  @synchronized(renderthread_) {
    // allocate the autorelease pool for any objc allocations
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // store the runloop so it can be terminated on stopanimation
    renderloop_ = [NSRunLoop currentRunLoop];
    // install the display link
    CADisplayLink *aDisplayLink = [[[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(triggerDrawFrame)] retain];
    [aDisplayLink setFrameInterval:1];
    [aDisplayLink addToRunLoop:renderloop_ forMode:NSDefaultRunLoopMode];
    // start the run loop
    CFRunLoopRun();
    // cleanup
    [aDisplayLink invalidate];
    [aDisplayLink release];
    renderloop_ = nil;
    [pool release];
    VerboseLog("Shutting down thread");
  }
}

- (void) dealloc {
  VerboseLog("");
  [self teardown];
  [super dealloc];
}
@end
