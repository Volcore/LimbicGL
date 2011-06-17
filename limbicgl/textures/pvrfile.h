/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef LAMB_RENDER_PVRFILE_H_
#define LAMB_RENDER_PVRFILE_H_

#include <performancemonitor/codingguides.h>

class PVRFile {
 public:
  ~PVRFile();
  static bool LoadAndUpload(const char *const name);
 private:
  PVRFile();
  DISALLOW_COPY_AND_ASSIGN(PVRFile);
};

#endif  // LAMB_RENDER_PVRFILE_H_
