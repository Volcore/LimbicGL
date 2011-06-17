/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef LIMBICGL_GAME_GAME_H_
#define LIMBICGL_GAME_GAME_H_

#include <performancemonitor/codingguides.h>

class GLProgram;
@class TextureManager;
@protocol Texture;

class Game {
 public:
  Game();
  ~Game();
  void Update();
  void Draw();
  void InitGFX();
 private:
  bool gfx_initialized_;
  GLProgram *program_;
  TextureManager *texture_manager_;
  id<Texture> textures_[2];
  DISALLOW_COPY_AND_ASSIGN(Game);
};

#endif  // LIMBICGL_GAME_GAME_H_
