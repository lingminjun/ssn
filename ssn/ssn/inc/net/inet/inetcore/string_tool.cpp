//
//  string_tool.cpp
//  inettest
//
//  Created by jay on 11-10-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#include "string_tool.h"
#include <zlib.h>

bool Compress(std::string& data)
{
    uLongf len = data.size();
    uLongf buflen = compressBound(len);
    Bytef *buffer = new Bytef[buflen];
    //uLongf buflen = len;
    bool ret = false;
    const Bytef *p = (const Bytef *)(data.data());
    int zret = compress(buffer, &buflen, p, len);
    if(zret == Z_OK)
    {
        data.resize(buflen);
        data.replace(0,buflen,(char*)buffer,buflen);
        ret = true;
    }
    
    delete[] buffer;
    return ret;
}

bool Compress(const std::string& data,std::string& newdata)
{
    uLongf len = data.size();
    uLongf buflen = compressBound(len);
    newdata.resize(buflen);
    Bytef *buffer = (Bytef*)newdata.data();
    //uLongf buflen = len;
    bool ret = false;
    const Bytef *p = (const Bytef *)(data.data());
    int zret = compress(buffer, &buflen, p, len);
    if(zret == Z_OK)
    {
        newdata.resize(buflen);
        ret = true;
    }
    return ret;
}

bool Uncompress(std::string& data)
{
    int ratiolen=8;
    bool ret = false;
    while(true)
    {
        uLongf bufflen = ratiolen * data.size();
        Bytef *buffer = new Bytef[bufflen];
        const Bytef *p = (const Bytef *)data.data();
        uLongf pLen = data.size();
        ret=false;
        int zret = uncompress(buffer, &bufflen, p, pLen);
        if(zret == Z_OK) 
        {
            data.resize(bufflen);
            data.replace(0, bufflen, (char *)buffer, bufflen);
            ret = true;
        }
        delete[] buffer;
        if(Z_BUF_ERROR == zret)
        {
            ratiolen +=2;	
        }else{
            return ret;
        }
    }
    return ret;
}

int splitchar(const std::string& s,char c,std::vector<std::string>& v)
{
    size_t begin = 0,end = 0;
    while((end=s.find(c,begin)) != std::string::npos)
    {
        if(end != begin)
        {
            v.push_back(s.substr(begin,end-begin));
        }
        begin = end + 1;
    }
    if(begin != std::string::npos && begin != s.size())
    {
        v.push_back(s.substr(begin));
    }

    return 0;
}

