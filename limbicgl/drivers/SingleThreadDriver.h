//
//  SingleThreadDriver.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/15/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Driver.h"

class Game;
@class EAGLContext;

// This driver does everything in the main thread.
// It uses a display link on the main thread to trigger the draw calls.
@interface SingleThreadDriver : NSObject<Driver> {
@private
    EAGLContext *context_;
    CADisplayLink *displaylink_;
    RenderTarget *rendertarget_;
    Game *game_;
}

- (id) initWithRenderTarget:(RenderTarget*)renderTarget andGame:(Game*)game;
- (void) startAnimation;
- (void) stopAnimation;
- (void) teardown;
- (void) setLayer:(CAEAGLLayer*)layer;

@end
