//
//  LimbicGLViewController.m
//  LimbicGL
//
//  Created by Volker Schoenefeld on 6/11/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LimbicGLViewController.h"
#import "EAGLView.h"
#import "Renderer.h"

@implementation LimbicGLViewController


- (void)awakeFromNib
{
    renderer = [[Renderer alloc] init];
    [(EAGLView *)self.view setRenderer:renderer];
}

- (void)dealloc
{
    [renderer release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
    [self startAnimation];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopAnimation];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)startAnimation {
    [renderer startAnimation];
}

- (void)stopAnimation {
    [renderer stopAnimation];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
