//
//  RenderTarget.h
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/14/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class CAEAGLLayer;
@class EAGLContext;

// The rendertarget is a collection of functions used to set up and use
// the renderbuffer for the OpenGL view.
@interface RenderTarget : NSObject {
@private
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
@public
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
}

// Initialize the framebuffer, if it's not initialized already.
- (void)createFramebuffer:(CAEAGLLayer*)layer forContext:(EAGLContext*)context;
// activate the framebuffer for rendering into it
- (void)setFramebuffer;
// put the framebuffer onto the screen
- (void)presentFramebuffer:(EAGLContext*)context;
// deallocates the framebuffer and all associated structures
- (void)deleteFramebuffer;

@end
