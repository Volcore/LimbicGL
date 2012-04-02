//
//  SingleThreadDriver.m
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/15/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SingleThreadDriver.h"
#include <limbicgl/config.h>
#import "RenderTarget.h"
#include <performancemonitor/performancemonitor.h>
#include <limbicgl/game/game.h>


@implementation SingleThreadDriver

- (id) initWithRenderTarget:(RenderTarget*)renderTarget andGame:(Game*)game {
  VerboseLog("");
  context_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
  displaylink_ = nil;
  rendertarget_ = renderTarget;
  game_ = game;
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
  if (context_) {
    if (context_ == [EAGLContext currentContext]) {
      [EAGLContext setCurrentContext:nil];
    }
    [context_ release];
    context_ = nil;
  }
}

- (void) setLayer:(CAEAGLLayer*)layer {
  VerboseLog("");
  [EAGLContext setCurrentContext:context_];
  [rendertarget_ deleteFramebuffer];
  [rendertarget_ createFramebuffer:layer forContext:context_];
  [EAGLContext setCurrentContext:nil];
}

- (void) triggerDrawFrame {
  VerboseLog("");
  PM_FRAME_START;
  [EAGLContext setCurrentContext:context_];
  [rendertarget_ setFramebuffer];
  game_->Draw();
  PM_DRAW(rendertarget_->framebufferWidth, rendertarget_->framebufferHeight, PM_DRAWMODE_TIMES);
  [rendertarget_ presentFramebuffer:context_];
  glFlush();
  [EAGLContext setCurrentContext:nil];
  PM_FRAME_END;
  PM_UPDATE_START;
  game_->Update();
  PM_UPDATE_END;
}

- (void) dealloc {
  VerboseLog("");
  [self teardown];
  [super dealloc];
}

@end
