//
//  RenderTarget.m
//  limbicgl
//
//  Created by Volker Schoenefeld on 6/14/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RenderTarget.h"


@implementation RenderTarget

- (void)createFramebuffer:(CAEAGLLayer*)layer forContext:(EAGLContext*)context {
    NSLog(@"createFramebuffer called");
    //assert(dispatch_get_current_queue() == queue);
    if (!defaultFramebuffer) {
        NSLog(@"createFramebuffer run");        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        NSLog(@"%i/%i fb size", framebufferWidth, framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
          NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
    }
}

- (void)deleteFramebuffer {
    NSLog(@"deleteFramebuffer called");
    if (defaultFramebuffer) {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    if (colorRenderbuffer) {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
}

- (void)setFramebuffer {
    assert(defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, framebufferWidth, framebufferHeight);
}

- (void)presentFramebuffer:(EAGLContext*)context {
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    BOOL success = [context presentRenderbuffer:GL_RENDERBUFFER];
    assert(success == YES);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}


@end
