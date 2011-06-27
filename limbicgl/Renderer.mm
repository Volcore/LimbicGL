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
#import "ThreadedGCDDriver.h"
#include <limbicgl/config.h>


@implementation Renderer

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
#elif DRIVER == THREADEDGCDDRIVER
    driver = [[ThreadedGCDDriver alloc] initWithRenderTarget:rendertarget andGame:game_];        
#else
    driver = [[SingleThreadDriver alloc] initWithRenderTarget:rendertarget andGame:game_];
#endif
  }
  return self;
}

- (void) dealloc {
    delete game_;
    [driver teardown];
    [(NSObject*)driver release];
    [rendertarget release];
    [super dealloc];
}

- (void) startAnimation {
  [driver startAnimation];
}

- (void) stopAnimation {
  [driver stopAnimation];
}

- (Game*)game {
  return game_;
}

@end
