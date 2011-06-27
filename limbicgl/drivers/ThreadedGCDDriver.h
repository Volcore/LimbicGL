//
//  ThreadedGCDDriver.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/27/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Driver.h"

class Game;
@class EAGLContext;

// This driver runs a separate NSThread with a NSRunLoop.
// Display link is running in that thread, feeding a GCD queue for the rendering events, running on yet another thread.
@interface ThreadedGCDDriver : NSObject <Driver> {
 @private
  EAGLContext *context_;
  bool animating_;
  NSThread *renderthread_;
  RenderTarget *rendertarget_;
  NSRunLoop *renderloop_;
  Game *game_;
  // GCD data
  dispatch_queue_t queue_;
  bool running_;
  unsigned long frame_drop_counter_;
}

- (id) initWithRenderTarget:(RenderTarget*)renderTarget andGame:(Game*)game;
- (void) startAnimation;
- (void) stopAnimation;
- (void) teardown;
- (void) setLayer:(CAEAGLLayer*)layer;

@end
