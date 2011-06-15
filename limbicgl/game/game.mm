/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <limbicgl/game/game.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

/*******************************************************************************
  A simple GPU program
 ******************************************************************************/
#include <performancemonitor/glprogram.h>

const char *const vertex_shader_source = "\
attribute vec3 att_position;\
attribute vec4 att_color;\
varying vec4 var_color;\
uniform float translate;\
void main() {\
  gl_Position = vec4(att_position, 1);\
  gl_Position.y += sin(translate)/2.0;\
  var_color = att_color;\
}";

const char *const fragment_shader_source = "\
varying lowp vec4 var_color;\
void main() {\
  gl_FragColor = var_color;\
}";

#define ARC4RANDOM_MAX (0x100000000ull)
static double randomDouble() {
  return double(arc4random())/double(ARC4RANDOM_MAX);
}

Game::Game()
    : gfx_initialized_(false),
      program_(0) {
}

Game::~Game() {
}

void Game::Update() {
  // To simulate a game update, sleep up to 5 ms
  double delay = 0.005 * randomDouble();
  [NSThread sleepForTimeInterval:delay];
}

void Game::Draw() {
  if (gfx_initialized_ == false) {
    InitGFX();
  }
  // Clear the scene
  double time = CFAbsoluteTimeGetCurrent();
  float c = float(sin(time));
  glClearColor(c/2.0f+0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  // Draw a simple object using VAR
  program_->Use();
  int position_attrib = program_->GetAttribLocation("att_position");
  int att_color = program_->GetAttribLocation("att_color");
  int translate = program_->GetUniformLocation("translate");
  program_->SetUniformf(translate, float(fmod(CFAbsoluteTimeGetCurrent(), 1000.0)));
  float points[] = {
    -0.5f, -0.33f, 1.0f, 1.0f, 0.0f,
     0.5f, -0.33f, 0.0f, 1.0f, 1.0f, 
    -0.5f,  0.33f, 0.0f, 0.0f, 0.0f,
     0.5f,  0.33f, 1.0f, 0.0f, 1.0f,
  };
  unsigned short indices[] = {
    0, 1, 2, 
    2, 1, 3
  };
  glVertexAttribPointer(position_attrib, 2, GL_FLOAT, false, 5*sizeof(float), (GLvoid*)points);
  glEnableVertexAttribArray(position_attrib);
  glVertexAttribPointer(att_color, 3, GL_FLOAT, false, 5*sizeof(float), (GLvoid*)(points+2));
  glEnableVertexAttribArray(att_color);
  glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(unsigned short), GL_UNSIGNED_SHORT, indices);
}

void Game::InitGFX() {
  if (gfx_initialized_ == true) return;
  gfx_initialized_ = true;
  program_ = GLProgram::FromText(vertex_shader_source, fragment_shader_source);
}
