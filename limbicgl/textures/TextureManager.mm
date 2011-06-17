//
//  TextureManager.m
//  limbicgl
//
//  Created by Volker Schönefeld on 6/16/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import "TextureManager.h"
#import "config.h"
#import "SyncedTexture.h"
#import "AsyncTexture.h"

@implementation TextureManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        queue_ = dispatch_queue_create("com.limbic.limbicgl.texturequeue", 0);
        EAGLContext *current_context = [EAGLContext currentContext];
        context_ = [[EAGLContext alloc] initWithAPI:current_context.API sharegroup:current_context.sharegroup];
    }
    
    return self;
}

- (void) dealloc {
  [context_ release];
  [super dealloc];
}

- (id<Texture>) loadTexture:(NSString*)name {
  VerboseLog(@"%@", name);
#ifdef ASYNC_ASSET_LOADING
  return [[AsyncTexture alloc] initWithName:name andQueue:queue_ andContext:context_];
#else
  return [[SyncedTexture alloc] initWithName:name];
#endif
}

@end
