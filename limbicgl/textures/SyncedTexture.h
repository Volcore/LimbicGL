//
//  SyncedTexture.h
//  limbicgl
//
//  Created by Volker Schönefeld on 6/16/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextureManager.h"

@interface SyncedTexture : NSObject<Texture> {
@private
  unsigned int bind_;
}

- (id)initWithName:(NSString*)name;

- (bool)isReady;
- (void)bind;
- (void)unbind;

@end
