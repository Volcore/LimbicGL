/*******************************************************************************
    Copyright (c) 2011, Limbic Software, Inc.
    All rights reserved.
    This code is subject to the Google C++ Coding conventions:
        http://google-styleguide.googlecode.com/svn/trunk/cppguide.xml
 ******************************************************************************/
#ifndef SOURCE_CODINGGUIDES_H_
#define SOURCE_CODINGGUIDES_H_

#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
    TypeName(const TypeName&);               \
    void operator=(const TypeName&)

#define SAFE_DELETE(x) \
    if (x != 0) { \
      delete x; \
      x = 0; \
    }

#define SAFE_FREE(x) \
    if (x != 0) { \
      free(x); \
      x = 0; \
    }


#define SAFE_DELETE_ARRAY(x) \
    if (x != 0) { \
      delete [] x; \
      x = 0; \
    }
    
#define EMPTY_STD_VECTOR(x) \
    while (x.empty() == false) {\
      delete x.back(); \
      x.pop_back(); \
    }

#define EMPTY_STD_LIST(x) \
    while (x.empty() == false) {\
      delete x.back(); \
      x.pop_back(); \
    }

#endif  // SOURCE_CODINGGUIDES_H_
