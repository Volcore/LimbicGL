/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <limbicgl/game/game.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#import "TextureManager.h"

#include <limbicgl/config.h>

/*******************************************************************************
  A simple GPU program
 ******************************************************************************/
#include <performancemonitor/glprogram.h>

const char *const vertex_shader_source = "\
attribute vec3 att_position;\
attribute vec4 att_color;\
attribute vec2 att_texcoord;\
varying vec4 var_color;\
varying vec2 var_texcoord;\
uniform vec3 translate;\
void main() {\
  gl_Position = vec4(att_position, 1);\
  gl_Position.x += translate.z*cos(translate.x)/2.0;\
  gl_Position.y += translate.z*sin(translate.y)/2.0;\
  var_color = att_color;\
  var_texcoord = att_texcoord;\
}";

const char *const fragment_shader_source = "\
uniform sampler2D uni_texture;\
varying lowp vec4 var_color;\
varying lowp vec2 var_texcoord;\
void main() {\
  gl_FragColor = var_color * texture2D(uni_texture, var_texcoord);\
}";

#define ARC4RANDOM_MAX (0x100000000ull)
static double randomDouble() {
  return double(arc4random())/double(ARC4RANDOM_MAX);
}

Game::Game()
    : gfx_initialized_(false),
      program_(0),
      time_(0.0),
      paused_(false),
      last_update_(0.0) {
  textures_[0] = 0;
  textures_[1] = 0;
}

Game::~Game() {
  SAFE_DELETE(program_);
  [texture_manager_ release];
  [(NSObject*)textures_[0] release];
  [(NSObject*)textures_[1] release];
}

void Game::Update() {
  // To simulate a game update, sleep up to 5 ms
  double delay = 0.005 * randomDouble();
  [NSThread sleepForTimeInterval:delay];
  // Update the time
  double time = CFAbsoluteTimeGetCurrent();
  if (paused_) {
    last_update_ = time;
    return;
  }
  if (last_update_ > 0.0) {
    double delta = time - last_update_;
    time_ += delta;
  }
  last_update_ = time;
}

void Game::Draw() {
  if (gfx_initialized_ == false) {
    InitGFX();
  }
  // Clear the scene
  float c = float(sin(time_));
  glClearColor(c/2.0f+0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  // Draw a simple object using VAR
  program_->Use();
  int position_attrib = program_->GetAttribLocation("att_position");
  int att_color = program_->GetAttribLocation("att_color");
  int att_texcoord = program_->GetAttribLocation("att_texcoord");
  int uni_texture = program_->GetUniformLocation("uni_texture");
  program_->SetUniformi(uni_texture, 0);
  int translate = program_->GetUniformLocation("translate");
  float points[] = {
    -0.15f, -0.05f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f,
     0.15f, -0.05f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f,
    -0.15f,  0.05f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f,
     0.15f,  0.05f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f,
  };
  unsigned short indices[] = {
    0, 1, 2, 
    2, 1, 3
  };
  glVertexAttribPointer(position_attrib, 2, GL_FLOAT, false, 7*sizeof(float), (GLvoid*)points);
  glEnableVertexAttribArray(position_attrib);
  glVertexAttribPointer(att_color, 3, GL_FLOAT, false, 7*sizeof(float), (GLvoid*)(points+2));
  glEnableVertexAttribArray(att_color);
  glVertexAttribPointer(att_texcoord, 2, GL_FLOAT, false, 7*sizeof(float), (GLvoid*)(points+5));
  glEnableVertexAttribArray(att_texcoord);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  float base_t = float(fmod(time_, 1000.0));
  const int num_quads = RENDERER_LOAD;
  for (int i=0; i<num_quads; ++i) {
    if ([textures_[i%2] isReady]) {
      [textures_[i%2] bind];
    }
    float x = base_t*1.0f+i*11.0f;
    float y = base_t*3.0f+i*3.0f;
    float z = (float(i+1)/float(num_quads))*1.5f;
    program_->SetUniformf(translate, x, y, z);
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(unsigned short), GL_UNSIGNED_SHORT, indices);
    [textures_[i%2] unbind];
  }
  glDisable(GL_BLEND);

}

void Game::InitGFX() {
  if (gfx_initialized_ == true) return;
  gfx_initialized_ = true;
  program_ = GLProgram::FromText(vertex_shader_source, fragment_shader_source);
  texture_manager_ = [[TextureManager alloc] init];
  textures_[0] = [texture_manager_ loadTexture:@"limbic_logo"];
  textures_[1] = [texture_manager_ loadTexture:@"checkerboard"];
}

void Game::Pause() {
  paused_ = true;
}

void Game::Resume() {
  paused_ = false;
}
