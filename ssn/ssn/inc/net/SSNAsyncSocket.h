//
//  SSNAsyncSocket.h
//  ssn
//
//  Created by lingminjun on 14-8-18.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__SSNAsyncSocket__
#define __ssn__SSNAsyncSocket__

#include <iostream>

class SSNBuffer
{
  public:
    unsigned long &size()
    {
        return _size;
    }
    const unsigned long &size() const
    {
        return _size;
    }
    unsigned long &length()
    {
        return _length;
    }
    const unsigned long &length() const
    {
        return _length;
    }

    unsigned char *readBuffer(const unsigned long &length);
    unsigned long writeBuffer(const unsigned char *buffer, const unsigned long &length);
  private:
    unsigned long _size;
    unsigned long _length;
    unsigned char *_buffer;
};

#endif /* defined(__ssn__SSNAsyncSocket__) */
