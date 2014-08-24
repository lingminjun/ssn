//
//  buffer.cpp
//  ssn
//
//  Created by lingminjun on 14-8-23.
//  Copyright (c) 2014年 lingminjun. All rights reserved.
//

#include "buffer.h"
#include <assert.h>

namespace ssn
{
void buffer::append(const unsigned char *buffer, const unsigned long &size)
{
    if (capacity() < 256)
    {
        reserve(256);
    }
    _buffer.append(buffer, size);
    _size += size;
}

void buffer::append(const ustring &data)
{
    append(data.c_str(), data.size());
}

void buffer::writed_size(unsigned long size)
{
    unsigned long tmpsize = _buffer.size();
    assert(size + _begin <= tmpsize);
    _begin += size;
    unsigned long leftsize = _buffer.size() - _begin;
    if ((_begin > 4096) && (_begin > leftsize))
    {
        _buffer.replace(0, leftsize, _buffer.data() + _begin, leftsize);
        _buffer.resize(leftsize);
        _begin = 0;
    }
    _size -= size;
    if (_size == 0 && _begin > 1024)
    {
        _buffer.resize(0);
        _begin = 0;
    }
}
const unsigned char *buffer::read_data(unsigned long &nsize)
{
    nsize = size();
    return _buffer.data() + _begin;
}

unsigned long buffer::capacity()
{
    return _buffer.capacity();
}
    
void buffer::reserve(unsigned long length)
{
    _buffer.reserve(length + _buffer.size());
}
}