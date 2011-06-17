/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#include <limbicgl/textures/pvrfile.h>
#include <stdio.h>
#include <stdlib.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <algorithm>

template<typename T>
inline static T sqr(const T& x) {
  return x*x;
}

typedef struct PVRHeader {
  uint32_t size;
  uint32_t height;
  uint32_t width;
  uint32_t mipcount;
  uint32_t flags;
  uint32_t texdatasize;
  uint32_t bpp;
  uint32_t rmask;
  uint32_t gmask;
  uint32_t bmask;
  uint32_t amask;
  uint32_t magic;
  uint32_t numtex;
} PVRHeader;

enum PVRPixelType {
  PVR_PIXELTYPE       = 0xff,
  PVR_TYPE_RGBA4444   = 0x10,
  PVR_TYPE_RGBA5551   = 0x11,
  PVR_TYPE_RGBA8888   = 0x12,
  PVR_TYPE_RGB565     = 0x13,
  PVR_TYPE_RGB555     = 0x14, // unsupported
  PVR_TYPE_RGB888     = 0x15,
  PVR_TYPE_I8         = 0x16,
  PVR_TYPE_AI8        = 0x17,
  PVR_TYPE_PVRTC2     = 0x18,
  PVR_TYPE_PVRTC4     = 0x19,
};

PVRFile::PVRFile() {
}

PVRFile::~PVRFile() {
}

void _GenerateMipMapSquareRGBA888(uint8_t *source, int source_width, uint8_t *target) {
  int source_stride = source_width*8;
  int target_width = source_width>>1;
  int target_stride = target_width*4;
  for (int y=0; y<target_width; ++y) {
    for (int x=0; x<target_width; ++x) {
      for (int o=0; o<4; ++o) {
        int target_index = y*target_stride+x*4+o;
        int source_index = y*source_stride+x*8+o;
        int a = source[source_index];
        int b = source[source_index+4];
        int c = source[source_index+source_stride];
        int d = source[source_index+source_stride+4];
        target[target_index] = (uint8_t)((a+b+c+d)>>2);
      }
    }
  }
}

bool _ReadAndVerifyHeader(const char *name, uint8_t **data, int *length) {
  NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:name] ofType:@"pvr"];
  CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
  unsigned char filepath[512];
  CFURLGetFileSystemRepresentation(url, true, filepath, sizeof(filepath));
  FILE *f = fopen((char*)filepath, "rb");
  if (f == 0) {
    return false;
  }
  fseek(f, 0, SEEK_END );
  *length = ftell(f);
  fseek(f, 0, SEEK_SET);
  *data = new uint8_t[*length];
  fread(*data, 1, *length, f);
  fclose(f);
  PVRHeader *header = (PVRHeader *)*data;
  if (header->size != sizeof(PVRHeader)) {
    delete [] data;
    printf("LAMB_PVR: Failed to load .pvr file: invalid header size!\n");
    return false;
  }
  if (header->magic != 0x21525650) {
    delete [] data;
    printf("LAMB_PVR: Failed to load .pvr file: invalid magic!\n");
    return false;
  }
  if (header->numtex != 1) {
    delete [] data;
    printf("LAMB_PVR: Failed to load .pvr file: expect only one surface!\n");
    return false;
  }
  return true;
}

bool PVRFile::LoadAndUpload(const char *const name) {
  uint8_t *data;
  int length;
  if (_ReadAndVerifyHeader(name, &data, &length) == false) {
    return false;
  }
  uint8_t *p = data;
  PVRHeader *header = (PVRHeader *)p;
  p += sizeof(PVRHeader);
  int ptype = header->flags & PVR_PIXELTYPE;
  int compressed = 0;
  int format;
  int type;
  int alpha = header->amask>0;
  (void)alpha;
  int size = header->width*header->height*header->bpp/8;
  (void)size;
  switch (ptype) {
  case PVR_TYPE_RGBA4444:
    format = GL_UNSIGNED_SHORT_4_4_4_4;
    type = GL_RGBA;
    break;
  case PVR_TYPE_RGBA5551:
    format = GL_UNSIGNED_SHORT_5_5_5_1;
    type = GL_RGBA;
    break;
  case PVR_TYPE_RGBA8888:
    format = GL_UNSIGNED_BYTE;
    type = GL_RGBA;
    break;
  case PVR_TYPE_RGB565:
    format = GL_UNSIGNED_SHORT_5_6_5;
    type = GL_RGB;
    break;
  case PVR_TYPE_RGB888:
    format = GL_UNSIGNED_BYTE;
    type = GL_RGB;
    break;
  case PVR_TYPE_I8:
    format = GL_UNSIGNED_BYTE;
    type = GL_LUMINANCE;
    break;
  case PVR_TYPE_AI8:
    format = GL_UNSIGNED_BYTE;
    type = GL_LUMINANCE_ALPHA;
    //printf( "ai8 %dx%d, %d\n", header->height, header->width, size );
    break;
#if TARGET_OS_IPHONE
  case PVR_TYPE_PVRTC2:
    format = alpha?GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG:GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
    type = alpha?GL_RGBA:GL_RGB;
    compressed = 1;
    size = std::max( header->width*header->height*header->bpp/8, 32u );
    //printf( "PVR 2bpp alpha %d %dx%d, %d\n", alpha, header->height, header->width, size );
    break;
  case PVR_TYPE_PVRTC4:
    format = alpha?GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG:GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
    type = alpha?GL_RGBA:GL_RGB;
    compressed = 1;
    size = std::max( header->width*header->height*header->bpp/8, 32u );
    //printf( "PVR 4bpp alpha %d %dx%d, %d\n", alpha, header->height, header->width, size );
    break;
#else
  case PVR_TYPE_PVRTC2:
    format = GL_UNSIGNED_BYTE;
    type = GL_RGBA;
    compressed = 1;
    size = std::max( header->width*header->height*header->bpp/8, 32u );
    //printf( "PVR 2bpp alpha %d %dx%d, %d\n", alpha, header->height, header->width, size );
    break;
  case PVR_TYPE_PVRTC4:
    format = GL_UNSIGNED_BYTE;
    type = GL_RGBA;
    compressed = 1;
    size = std::max( header->width*header->height*header->bpp/8, 32u );
    //printf( "PVR 4bpp alpha %d %dx%d, %d\n", alpha, header->height, header->width, size );
    break;
#endif
  default:
    printf("LAMB_PVR: Failed to load .pvr file: unknown format 0x%02x!\n", ptype);
    delete []data;
    return false;
  }
  if (compressed == 1) {
    if (header->height != header->width)
      printf("LAMB_PVR: Problem loading .pvr file: not a square texture!\n");
  }
  int totalread = 0;
  if (header->mipcount > 1) {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  }
  // If the device does not support compressed textures, decompress and store to cachefs
  for( int i=0; i<=header->mipcount; ++i ) {
    if( compressed )
    {
      int w = header->width>>i;
      int fsize = std::max( w*w*header->bpp/8, 32u );
      glCompressedTexImage2D( GL_TEXTURE_2D, i, format, w, w, 0, fsize, p
          );
      p += fsize;
      totalread += fsize;
    } else
    {
      int w = header->width>>i;
      int h = header->height>>i;
      if (w < 1) w = 1;
      if (h < 1) h = 1;
      int fsize = (w*h*header->bpp+7)/8;
      glTexImage2D( GL_TEXTURE_2D, i, type, w, h, 0, type, format, p );
      p += fsize;
      totalread += fsize;
    }
  }
  delete [] data;
  /** Removed this check, because it seems the exporter writes a bogus
   * texdatasize into the header-> */
  //if( totalread != header->texdatasize )
  //    printf( "Warning: loading PVR file '%s', loaded tex size (%u) does not "
  //            "match size in header (%u), compressed %i\n", name, totalread,
  //            header->texdatasize, compressed );
  return true;
}
