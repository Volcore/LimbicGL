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

@interface RenderTarget : NSObject {
@private
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
@public
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
}

- (void)createFramebuffer:(CAEAGLLayer*)layer forContext:(EAGLContext*)context;
- (void)setFramebuffer;
- (void)presentFramebuffer:(EAGLContext*)context;
- (void)deleteFramebuffer;

@end
