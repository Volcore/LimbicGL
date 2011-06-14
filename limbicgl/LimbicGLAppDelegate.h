//
//  limbicglAppDelegate.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/14/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LimbicGLViewController;

@interface LimbicGLAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet LimbicGLViewController *viewController;

@end
