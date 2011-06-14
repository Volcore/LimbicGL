/*******************************************************************************
    Copyright (c) 2010, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <stdio.h>
#include <performancemonitor/glshader.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

//#define SHADER_DEBUG

GLShader::GLShader(unsigned int shader)
    : shader_(shader) {
}

GLShader::~GLShader() {
  glDeleteShader(shader_);
}

GLShader *GLShader::LoadAndCompile(Type type, const char *text) {
  GLint status;
  GLenum shader_type;
  switch (type) {
  case VERTEX: shader_type = GL_VERTEX_SHADER; break;
  case FRAGMENT: shader_type = GL_FRAGMENT_SHADER; break;
  default:
    printf("Unknown shader type %i! Should be either VERTEX or FRAGMENT!\n", type);
    return NULL;
  }
  GLuint shader = glCreateShader(shader_type);
  glShaderSource(shader, 1, &text, NULL);
  glCompileShader(shader);
#ifdef SHADER_DEBUG
  GLint log_length;
  glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &log_length);
  if (log_length > 0) {
    GLchar *log = new GLchar[log_length];
    glGetShaderInfoLog(shader, log_length, &log_length, log);
    printf("*** Shader source:\n%s\n*** Compile log:\n%s", text, log);
    delete[]log;
  }
#endif
  glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
  if (status == 0) {
    printf("Failed to compile shader!\n");
    glDeleteShader(shader);
    return NULL;
  }
  return new GLShader(shader);
}
