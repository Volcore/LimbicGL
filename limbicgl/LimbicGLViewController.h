//
//  LimbicGLViewController.h
//  LimbicGL
//
//  Created by Volker Schoenefeld on 6/11/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Renderer;

@interface LimbicGLViewController : UIViewController {
@private
    Renderer *renderer;
}

- (void)startAnimation;
- (void)stopAnimation;

@end
