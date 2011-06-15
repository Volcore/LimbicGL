/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <performancemonitor/performancemonitor.h>

unsigned int triangle_count = 0;

#ifdef ENABLE_PEFORMANCE_MONITOR

#include <stdio.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <performancemonitor/glprogram.h>

/////////////////////////////////////////////////
// Simulating lamb/generic/time.h
#include <mach/mach.h>
#include <mach/mach_time.h>
static mach_timebase_info_data_t timebase;
namespace LambTime {
static void Initialize() {
  mach_timebase_info(&timebase);
}

static double CurrentTime() {
  uint64_t t = mach_absolute_time();
  return ((double)t * (double)timebase.numer) / (double)timebase.denom / 1000000000.0;
}

static inline double TimeSince(double then) {
 return CurrentTime()-then;
}
}
/////////////////////////////////////////////////

const char *const vertex_shader_source = "\
attribute vec3 att_position;\
attribute vec4 att_color;\
varying vec4 var_color;\
void main() {\
  gl_Position = vec4(att_position, 1);\
  var_color = att_color;\
}";

const char *const fragment_shader_source = "\
varying lowp vec4 var_color;\
void main() {\
  gl_FragColor = var_color;\
}";

static GLProgram *gpu_program = 0;

PerformanceMonitor::PerformanceMonitor()
    : frame_start_time_(-1),
      update_start_time_(-1),
      frame_time_index_(0),
      update_time_index_(0) {
  LambTime::Initialize();
  memset(frame_times_, 0, sizeof(frame_times_));
  memset(update_times_, 0, sizeof(update_times_));
  memset(total_frame_times_, 0, sizeof(total_frame_times_));
  memset(triangle_counts_, 0, sizeof(triangle_counts_));
}

PerformanceMonitor::~PerformanceMonitor() {
  SAFE_DELETE(gpu_program)
}

PerformanceMonitor *PerformanceMonitor::Shared(bool free) {
  static PerformanceMonitor *instance = 0;
  if (instance == 0 && !free) {
    instance = new PerformanceMonitor();
  }
  if (free && instance) {
    delete instance;
    instance = 0;
  }
  return instance;
}

void PerformanceMonitor::FrameStart() {
  double now = LambTime::CurrentTime();
  total_frame_times_[(frame_time_index_+PM_HISTORY_LENGTH-1)%PM_HISTORY_LENGTH] = now - frame_start_time_;
  frame_start_time_ = now;
}

void PerformanceMonitor::FrameEnd() {
  if (frame_start_time_ < 0.0) {
    return;
  }
  double delta = LambTime::TimeSince(frame_start_time_);
  triangle_counts_[frame_time_index_] = triangle_count;
  frame_times_[frame_time_index_] = delta;
  frame_time_index_ = (frame_time_index_+1)%PM_HISTORY_LENGTH;
  triangle_count = 0;
}

void PerformanceMonitor::UpdateStart() {
  update_start_time_ = LambTime::CurrentTime();
}

void PerformanceMonitor::UpdateEnd() {
  if (update_start_time_ < 0.0) {
    return;
  }
  double delta = LambTime::TimeSince(update_start_time_);
  update_start_time_ = -1;
  update_times_[update_time_index_] = delta;
  update_time_index_ = (update_time_index_+1)%PM_HISTORY_LENGTH;
}

#define NUM_LINES (PM_HISTORY_LENGTH*3+4) // 3 segments per history element, plus 4 markers
#define NUM_VERTICES (NUM_LINES*2*5)
#define NUM_INDICES (NUM_LINES*2)
static float points[NUM_VERTICES];
static unsigned short indices[NUM_INDICES];

void PerformanceMonitor::Draw(int width, int height, PMDrawMode mode) {
  if (gpu_program == 0){
    gpu_program = GLProgram::FromText(vertex_shader_source, fragment_shader_source);
  }
  float scale = float(width)/float(PM_HISTORY_LENGTH);
  float yscale = 1.0f;
  // 1 pixel = 100 triangle
  float triangles_per_pixel = 100.0f;
  float *ppoints = points;
  // Frame time per frame, 1px per ms
  // for that, first build the vbo
  for (int i=0; i<PM_HISTORY_LENGTH; ++i) {
    float age = float((i-frame_time_index_+PM_HISTORY_LENGTH)%PM_HISTORY_LENGTH)/float(PM_HISTORY_LENGTH);
    float age2 = age*age;
    float x = 2.0f/scale*i/float(PM_HISTORY_LENGTH)-1.0f/scale;
    float y = yscale*(frame_times_[i]*1000)/float(height)-1.0f;
    if (mode == PM_DRAWMODE_TRIANGLES) {
      y = (triangle_counts_[i]/triangles_per_pixel)/float(height)-1.0f;
    }
    *ppoints++ = x;
    *ppoints++ = -1.0f;
    *ppoints++ = age2;
    *ppoints++ = 0;
    *ppoints++ = 0;
    *ppoints++ = x;
    *ppoints++ = y;
    *ppoints++ = age2;
    *ppoints++ = 0;
    *ppoints++ = 0;
    float y2 = y+yscale*(update_times_[i]*1000)/float(height);
    if (mode == PM_DRAWMODE_TRIANGLES) {
      y2 = y;
    }
    *ppoints++ = x;
    *ppoints++ = y;
    *ppoints++ = 0;
    *ppoints++ = age2;
    *ppoints++ = 0;
    *ppoints++ = x;
    *ppoints++ = y2;
    *ppoints++ = 0;
    *ppoints++ = age2;
    *ppoints++ = 0;
    double rem = total_frame_times_[i] - update_times_[i] - frame_times_[i];
    float y3 = y2+yscale*(rem*1000)/float(height);
    if (mode == PM_DRAWMODE_TRIANGLES) {
      y3 = y2;
    }
    *ppoints++ = x;
    *ppoints++ = y2;
    *ppoints++ = 0;
    *ppoints++ = 0;
    *ppoints++ = age2;
    *ppoints++ = x;
    *ppoints++ = y3;
    *ppoints++ = 0;
    *ppoints++ = 0;
    *ppoints++ = age2;
  }
  // add hz markers
  float hz[4] = {
    60.0f, 30.0f, 20.0f, 10.0f
  };
  unsigned int tris[4] = {
    13333, // 0.4m tris @ 30hz
    9999, // 0.3m tris @ 30hz
    6666, // 0.2m tris @ 30hz
    3333, // 0.1m tris @ 30hz
  };
  for (int i=0; i<4; ++i) {
    float c = float(i+1)/4.0f;
    float y = yscale*1000.0f/hz[i]/float(height)-1.0f;
    if (mode == PM_DRAWMODE_TRIANGLES) {
      y = (tris[i]/triangles_per_pixel)/float(height)-1.0f;
    }
    *ppoints++ = -1.0f/scale;
    *ppoints++ = y;
    *ppoints++ = c;
    *ppoints++ = c;
    *ppoints++ = c;
    *ppoints++ = 1.0f/scale;
    *ppoints++ = y;
    *ppoints++ = c;
    *ppoints++ = c;
    *ppoints++ = c;
  }
  for (int i=0; i<NUM_INDICES; ++i) {
    indices[i] = i;
  }
  //  NOTE: if you want to use this in your app, and you use state caching, you should flush all gl states, and then reset them after the rendering is done.
  gpu_program->Use();
  int position_attrib = gpu_program->GetAttribLocation("att_position");
  int att_color = gpu_program->GetAttribLocation("att_color");
  glVertexAttribPointer(position_attrib, 2, GL_FLOAT, false, 5*sizeof(float), (GLvoid*)points);
  glEnableVertexAttribArray(position_attrib);
  glVertexAttribPointer(att_color, 3, GL_FLOAT, false, 5*sizeof(float), (GLvoid*)(points+2));
  glEnableVertexAttribArray(att_color);
  glDrawElements(GL_LINES, sizeof(indices)/sizeof(unsigned short), GL_UNSIGNED_SHORT, indices);
}

#endif
