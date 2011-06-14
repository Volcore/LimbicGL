//
//  Renderer.mm
//  LimbicGL
//
//  Created by Volker Schönefeld on 6/12/11.
//  Copyright 2011 Limbic Software, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Renderer.h"
#include <performancemonitor/performancemonitor.h>

#define ARC4RANDOM_MAX (0x100000000ull)
static double randomDouble() {
  return double(arc4random())/double(ARC4RANDOM_MAX);
}

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface Renderer()
@property (nonatomic, assign) CADisplayLink *displayLink;
@property (nonatomic, retain) EAGLContext *context;
- (void)createFramebuffer;
- (void)setFramebuffer;
- (void)presentFramebuffer;
- (void)deleteFramebuffer;
// Actual rendering stuff
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation Renderer

@synthesize animating;
@synthesize displayLink;
@synthesize context;
@synthesize layer;

- (void)setLayer:(CAEAGLLayer *)l {
  NSLog(@"setLayer called");
  layer = l;
  @synchronized(context) {
    NSLog(@"SetLayer starting.");
    [EAGLContext setCurrentContext:context];
    [self deleteFramebuffer];
    [self createFramebuffer];
    glFlush();
    [EAGLContext setCurrentContext:nil];
    NSLog(@"SetLayer done.");
  }
}


- (void) threadMainLoop {
  NSLog(@"Entering thread main loop...");
  [NSThread sleepForTimeInterval:1.0];
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  NSRunLoop* loop = [NSRunLoop currentRunLoop];
  CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(triggerDrawFrame)];
  [aDisplayLink setFrameInterval:1];
  [aDisplayLink addToRunLoop:loop forMode:NSRunLoopCommonModes];
  [loop run];
  [pool release];
}

- (id)init
{
    NSLog(@"Init");
    self = [super init];
    if (self) {
        animating = FALSE;
        animationFrameInterval = 1;
        self.displayLink = nil;
        NSLog(@"Creating queue");
        queue = dispatch_queue_create("com.limbic.gltest.renderingqueue", 0);
        //queue = dispatch_get_main_queue();
        //dispatch_sync(queue, ^{
            NSLog(@"Creating context");
            // Create the context
            EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            if (!aContext)
                NSLog(@"Failed to create ES context");
            else if (![EAGLContext setCurrentContext:aContext])
                NSLog(@"Failed to set ES context current");
            self.context = aContext;
            [aContext release];
      [self loadShaders];
      glFlush();
            [EAGLContext setCurrentContext:nil];
        //});
        dispatch_async(queue, ^{
          NSLog(@"Allocating thread context");
          thread_context = [[EAGLContext alloc] initWithAPI:self.context.API sharegroup:self.context.sharegroup];
        });
    }
    return self;
}

- (void) tearDown {
    NSLog(@"Teardown called");
    // Synchronosuly tear down
    //dispatch_sync(queue, ^{
    @synchronized(context) {
        NSLog(@"Running Teardown");
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        [self deleteFramebuffer];    
        // Tear down context.
        if ([EAGLContext currentContext] == context)
            [EAGLContext setCurrentContext:nil];
        [context release];
        [thread_context release];
        context = nil;
    }
    //});
}

- (void) dealloc {
    NSLog(@"Dealloc called");
    [self tearDown];
    dispatch_release(queue);
    [super dealloc];
}

- (void) startAnimation {
    NSLog(@"startAnimation called");
    if (!animating) {
        NSLog(@"Creating display link...");
        // Create the thread
        //[NSThread detachNewThreadSelector:@selector(threadMainLoop) toTarget:self withObject:nil];
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(triggerDrawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [aDisplayLink addToRunLoop:loop forMode:NSRunLoopCommonModes];
        self.displayLink = aDisplayLink;
        animating = TRUE;
    }
}

- (void) stopAnimation {
    NSLog(@"stopAnimation called");
    if (animating) {
        NSLog(@"freeing stopAnimation");
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (NSInteger)animationFrameInterval {
    NSLog(@"animationFrameInterval called");
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
    NSLog(@"setAnimationFrameInterval called");
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}


- (void)drawFrame {
    PerformanceMonitor *pm = PerformanceMonitor::Shared();
    pm->FrameStart();
      //NSLog(@"drawFrame called");
    //assert(dispatch_get_current_queue() == queue);
    [self setFramebuffer];
    // Replace the implementation of this method to do your own custom drawing.
    static const GLfloat squareVertices[] = {
        -0.5f, -0.33f,
        0.5f, -0.33f,
        -0.5f,  0.33f,
        0.5f,  0.33f,
    };
    
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    static float transY = 0.0f;
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Use shader program.
    glUseProgram(program);
    // Update uniform value.
    glUniform1f(uniforms[UNIFORM_TRANSLATE], (GLfloat)transY);
    transY += 0.075f;	
    // Update attribute values.
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
    glEnableVertexAttribArray(ATTRIB_COLOR);
    
    // Validate program before drawing. This is a good check, but only really necessary in a debug build.
    // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
    if (![self validateProgram:program]) {
        NSLog(@"Failed to validate program: %d", program);
        return;
    }
#endif
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    pm->Draw(framebufferWidth, framebufferHeight);
    [self presentFramebuffer];
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"Error: %i", error);
    }
      //NSLog(@"drawFrame done");
    pm->FrameEnd();
    pm->UpdateStart();
    double delay = 0.005 * randomDouble(); // between 0 and 5 ms delay
    [NSThread sleepForTimeInterval:delay];
    pm->UpdateEnd();
}

- (void)triggerDrawFrame {
    dispatch_async(queue, ^{
        //NSLog(@"Waiting to draw frame...");
        //@synchronized(context) {
            //NSLog(@"Drawing frame");
            BOOL res = [EAGLContext setCurrentContext:thread_context];
            assert(res == YES);
            [self drawFrame];
            glFlush();
            [EAGLContext setCurrentContext:nil];
            //NSLog(@"Drawing frame done");
       //}
    });
}

- (void)createFramebuffer {
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
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.layer];
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
    if (context) {
        NSLog(@"deleteFramebuffer run");
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)asyncDeleteFramebuffer {
  
    NSLog(@"asyncDeleteFramebuffer called");
    dispatch_async(queue, ^{
        NSLog(@"asyncDeleteFramebuffer run");
        @synchronized(thread_context) {
            BOOL res = [EAGLContext setCurrentContext:thread_context];
            assert(res == YES);
            [self deleteFramebuffer];
            glFlush();
            [EAGLContext setCurrentContext:nil];
        }
    });
}


- (void)setFramebuffer {
    assert(defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, framebufferWidth, framebufferHeight);
}

- (void)presentFramebuffer {
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    BOOL success = [thread_context presentRenderbuffer:GL_RENDERBUFFER];
    assert(success == YES);
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    //assert(dispatch_get_current_queue() == queue);
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog {
    //assert(dispatch_get_current_queue() == queue);
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog {
    GLint logLength = 0, status = 1;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders {
    //assert(dispatch_get_current_queue() == queue);
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

@end
