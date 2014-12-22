//
//  buffer.h
//  ssn
//
//  Created by lingminjun on 14-8-23.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#ifndef __ssn__buffer__
#define __ssn__buffer__

#include <string>

namespace ssn
{

typedef std::basic_string<unsigned char, std::char_traits<unsigned char>, std::allocator<unsigned char>> ustring;

class buffer
{
  public:
    buffer()
    {
        _begin = 0;
        _size = 0;
    }
    void append(const unsigned char *buffer, const unsigned long &size);
    void append(const ustring &data);
    void cut_front_size(unsigned long cut_size);//cut_size don't allow more than buffer size
    const unsigned char *read_data(unsigned long &size);
    void clear()
    {
        _buffer.clear();
        _size = 0;
        _begin = 0;
    }
    unsigned long capacity();
    void reserve(unsigned long length);
    unsigned long size()
    {
        return _size;
    }

  private:
    unsigned long _begin;
    unsigned long _size;
    ustring _buffer;
};
}

#endif /* defined(__ssn__buffer__) */
