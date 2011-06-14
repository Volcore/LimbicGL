/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef LAMB_RENDER_GLPROGRAM_H_
#define LAMB_RENDER_GLPROGRAM_H_

#include <performancemonitor/codingguides.h>

class GLShader;

typedef int UniformLocation;
typedef int AttributeLocation;

class GLProgram {
 public:
  GLProgram();
  ~GLProgram();
  static GLProgram *FromText(const char *vshader, const char *fshader);
  void Attach(const GLShader *shader) const;
  bool Link() const;
  bool Validate() const;
  void Use() const;
  void Disable() const;
  UniformLocation GetUniformLocation(const char *name) const;
  UniformLocation GetAttribLocation(const char *name) const;
  void SetUniformi(int uniform, int x) const;
  void SetUniformf(int uniform, float x) const;
  void SetUniformf(int uniform, float x, float y) const;
  void SetUniformf(int uniform, float x, float y, float z) const;
  void SetUniformf(int uniform, float x, float y, float z, float w) const;
  void SetUniformMatrix(int uniform, const float *m) const;
 private:
  unsigned int program_;
  DISALLOW_COPY_AND_ASSIGN(GLProgram);
};

#endif  // LAMB_RENDER_GLPROGRAM_H_
