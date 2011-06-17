/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
         http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef LIMBICGL_CONFIG_H_
#define LIMBICGL_CONFIG_H_

// This can be used to run gamecenter in a separate GCD queue. This is for testing, and doesn't really seem to have any effect on the stuttering.
//#define GAMECENTER_WITH_GCD

#define SINGLETHREADEDDRIVER 0
#define GCDDRIVER 1
#define THREADEDDRIVER 2
// Specifies with Driver to use
#define DRIVER GCDDRIVER

// Toggles between synced and async asset loading
#define ASYNC_ASSET_LOADING
// Artificial delay for the asset loading to test asyncness
#define ASSET_LOADING_DELAY 2.0

// This can configure how much load is put on OpenGL.
// Note: this doens't actually cause a lot of tiler/renderer utilization. It's just a heuristic way to produce a full 60 hz worth of load for the device
//       it is definitely _not_ a benchmark.
// Experimental values ():
//  3GS: 
//    200 -- runs smooth at 60 hz
//    400 -- runs exactly at 60 hz
//    500 -- runs very close to 60hz, but with the game update it's a little below 60 hz
//  iPad2:
//    800 -- runs smooth at 60 hz
//   1150 -- runs exactly at 60 hz
//   1600 -- runs slightly below 60 hz
#define RENDERER_LOAD 100

// This can be used to get very verbose traces for debugging
//#define VERBOSE_LOG

#ifdef VERBOSE_LOG
#   define VerboseLog(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__);
#else
#   define VerboseLog(...)
#endif


#endif  // LIMBICGL_CONFIG_H_
