//
//  AsyncTexture.h
//  limbicgl
//
//  Created by Volker Schönefeld on 6/16/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextureManager.h"

@interface AsyncTexture : NSObject<Texture> {
@private
  unsigned int bind_;
  bool done_;
  dispatch_semaphore_t semaphore_;
}

- (id)initWithName:(NSString*)name andQueue:(dispatch_queue_t)queue andContext:(EAGLContext*)context;

- (bool)isReady;
- (void)bind;
- (void)unbind;

@end
