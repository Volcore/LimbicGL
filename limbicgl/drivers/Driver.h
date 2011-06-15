//
//  Driver.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/15/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RenderTarget;
@class CAEAGLLayer;

@protocol Driver
- (void) startAnimation;
- (void) stopAnimation;
- (void) teardown;
- (void) setLayer:(CAEAGLLayer*)layer;
@end
