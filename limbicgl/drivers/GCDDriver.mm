//
//  GCDDriver.m
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/15/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "GCDDriver.h"
#include <limbicgl/config.h>
#import "RenderTarget.h"
#include <performancemonitor/performancemonitor.h>
#include <limbicgl/game/game.h>


@implementation GCDDriver

- (id) initWithRenderTarget:(RenderTarget*)renderTarget andGame:(Game*)game {
  VerboseLog("");
  context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  queue_ = dispatch_queue_create("com.limbic.limbicgl.gcdqueue", 0);
  displaylink_ = nil;
  rendertarget_ = renderTarget;
  game_ = game;
  running_ = false;
  frame_drop_counter_ = 0;
  return self;
}

- (void) startAnimation {
  VerboseLog("");
  if (displaylink_ == nil) {
    displaylink_ = [[[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(triggerDrawFrame)] retain];
    [displaylink_ setFrameInterval:1];
    [displaylink_ addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  }
}

- (void) stopAnimation {
  VerboseLog("");
  if (displaylink_ != nil) {
    [displaylink_ invalidate];
    [displaylink_ release];
    displaylink_ = nil;
  }
}

- (void) teardown {
  VerboseLog("");
  [self stopAnimation];
  dispatch_release(queue_);
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
  // This can also run on the GCD queue, but it doesn't have to, as long as it's locked.
  @synchronized(context_) {
    if (context_) {

      [EAGLContext setCurrentContext:context_];
      [rendertarget_ deleteFramebuffer];
      [rendertarget_ createFramebuffer:layer forContext:context_];
      [EAGLContext setCurrentContext:nil];
    }
  }
}

- (void) drawFrame {
  VerboseLog("");
  PerformanceMonitor *pm = PerformanceMonitor::Shared();
  pm->FrameStart();
  @synchronized(context_) {
    if (context_) {
      [EAGLContext setCurrentContext:context_];
      [rendertarget_ setFramebuffer];
      game_->Draw();
      pm->Draw(rendertarget_->framebufferWidth, rendertarget_->framebufferHeight);
      [rendertarget_ presentFramebuffer:context_];
      glFlush();
      [EAGLContext setCurrentContext:nil];
    }
  }
  pm->FrameEnd();
  pm->UpdateStart();
  game_->Update();
  pm->UpdateEnd();
}

- (void) triggerDrawFrame {
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


- (void) dealloc {
  VerboseLog("");
  [self teardown];
  [super dealloc];
}

@end
