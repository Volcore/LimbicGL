/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef LAMB_RENDER_GLSHADER_H_
#define LAMB_RENDER_GLSHADER_H_

#include <performancemonitor/codingguides.h>

class GLShader {
 public:
  enum Type {
    VERTEX = 0,
    FRAGMENT = 1,
  };
  static GLShader *LoadAndCompile(Type type, const char *text);
  ~GLShader();
  unsigned int shader() const { return shader_; }
 private:
  GLShader(unsigned int shader);
  unsigned int shader_;
  DISALLOW_COPY_AND_ASSIGN(GLShader);
};

#endif  // LAMB_RENDER_GLSHADER_H_
