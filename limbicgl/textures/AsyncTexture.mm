//
//  AsyncTexture.m
//  limbicgl
//
//  Created by Volker Schönefeld on 6/16/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import "AsyncTexture.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <limbicgl/textures/pvrfile.h>
#include <limbicgl/config.h>

@implementation AsyncTexture

- (id)initWithName:(NSString*)name andQueue:(dispatch_queue_t)queue andContext:(EAGLContext*)context {
  self = [super init];
  if (self == nil)
    return self;
  done_ = false;
  semaphore_ = dispatch_semaphore_create(0);
  dispatch_async(queue, ^{
#ifdef ASSET_LOADING_DELAY
    [NSThread sleepForTimeInterval:ASSET_LOADING_DELAY];
#endif
    [EAGLContext setCurrentContext:context];
    glGenTextures(1, &bind_);
    glBindTexture(GL_TEXTURE_2D, bind_);
    PVRFile::LoadAndUpload([name UTF8String]);
    glBindTexture(GL_TEXTURE_2D, 0);  
    glFlush();
    [EAGLContext setCurrentContext:nil];
    dispatch_semaphore_signal(semaphore_);
    done_ = true;
  });
  return self;
}

- (void)dealloc {
  if (done_ == false) {
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
  }
  glDeleteTextures(1, &bind_);
  [super dealloc];
}

- (bool)isReady {
  return done_;
}

- (void)bind {
  if (done_ == false) {
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
  }
  glBindTexture(GL_TEXTURE_2D, bind_);
}

- (void)unbind {
  glBindTexture(GL_TEXTURE_2D, 0);
}

@end
