/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SOURCE_PERFORMANCEMONITOR_PERFORMANCEMONITOR_H_
#define SOURCE_PERFORMANCEMONITOR_PERFORMANCEMONITOR_H_

#ifdef ENABLE_PEFORMANCE_MONITOR

#include <performancemonitor/codingguides.h>
#include <list>

#define PM_HISTORY_LENGTH 320

enum PMDrawMode {
  PM_DRAWMODE_TIMES = 1,
  PM_DRAWMODE_TRIANGLES = 2,
};

class PerformanceMonitor {
 public:
  static PerformanceMonitor *Shared(bool free=false);
  void FrameStart();
  void FrameEnd();
  void UpdateStart();
  void UpdateEnd();
  void Draw(int width, int height, PMDrawMode mode=PM_DRAWMODE_TIMES);
 private:
  PerformanceMonitor();
  ~PerformanceMonitor();
  double frame_start_time_;
  double update_start_time_;
  int frame_time_index_;
  double frame_times_[PM_HISTORY_LENGTH];
  double total_frame_times_[PM_HISTORY_LENGTH];
  int update_time_index_;
  double update_times_[PM_HISTORY_LENGTH];
  unsigned int triangle_counts_[PM_HISTORY_LENGTH];
  DISALLOW_COPY_AND_ASSIGN(PerformanceMonitor);
};

#define PM_FRAME_START PerformanceMonitor::Shared()->FrameStart()
#define PM_FRAME_END PerformanceMonitor::Shared()->FrameEnd()
#define PM_UPDATE_START PerformanceMonitor::Shared()->UpdateStart()
#define PM_UPDATE_END PerformanceMonitor::Shared()->UpdateEnd()
#define PM_DRAW(w,h,m) PerformanceMonitor::Shared()->Draw(w,h,m)
#define PM_FREE PerformanceMonitor::Shared(true)
#else
#define PM_FRAME_START
#define PM_FRAME_END
#define PM_UPDATE_START
#define PM_UPDATE_END
#define PM_DRAW(w,h,m)
#define PM_FREE
#endif

#endif  // SOURCE_PERFORMANCEMONITOR_PERFORMANCEMONITOR_H_
