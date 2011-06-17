//
//  TextureManager.h
//  limbicgl
//
//  Created by Volker Schönefeld on 6/16/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Texture
// Returns true once the textures is ready to be used
- (bool)isReady;
// Will block until the texture is ready
- (void)bind;
// Will never block, even if the texture is not ready
- (void)unbind;
@end

// TODO: move the texture manager to the renderer, pass it into the game. create separate context

@interface TextureManager : NSObject {
@private
  NSDictionary *textures_;
  dispatch_queue_t queue_;
  EAGLContext *context_;
}

- (id<Texture>) loadTexture:(NSString*)name;

@end
