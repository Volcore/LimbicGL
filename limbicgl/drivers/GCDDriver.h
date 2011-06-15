//
//  GCDDriver.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/15/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Driver.h"

class Game;
@class EAGLContext;

@interface GCDDriver : NSObject<Driver> {
@private
  EAGLContext *context_;
  CADisplayLink *displaylink_;
  RenderTarget *rendertarget_;
  dispatch_queue_t queue_;
  bool running_;
  unsigned long frame_drop_counter_;
  Game *game_;
}

- (id) initWithRenderTarget:(RenderTarget*)renderTarget andGame:(Game*)game;
- (void) startAnimation;
- (void) stopAnimation;
- (void) teardown;
- (void) setLayer:(CAEAGLLayer*)layer;

@end
