//
//  SyncedTexture.m
//  limbicgl
//
//  Created by Volker Schönefeld on 6/16/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import "SyncedTexture.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <limbicgl/textures/pvrfile.h>

@implementation SyncedTexture

- (id)initWithName:(NSString*)name {
  self = [super init];
  if (self == nil)
    return self;
  glGenTextures(1, &bind_);
  glBindTexture(GL_TEXTURE_2D, bind_);
  PVRFile::LoadAndUpload([name UTF8String]);
  glBindTexture(GL_TEXTURE_2D, 0);  
  return self;
}

- (void)dealloc {
  glDeleteTextures(1, &bind_);
  [super dealloc];
}

- (bool)isReady {
  return true;
}

- (void)bind {
  glBindTexture(GL_TEXTURE_2D, bind_);
}

- (void)unbind {
  glBindTexture(GL_TEXTURE_2D, 0);
}

@end
