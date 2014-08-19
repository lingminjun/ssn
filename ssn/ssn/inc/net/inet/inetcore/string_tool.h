//
//  string_tool.h
//  inettest
//
//  Created by jay on 11-10-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef inettest_string_tool_h
#define inettest_string_tool_h

#include <string>
#include <vector>

using namespace std;

bool Compress(std::string& data);
bool Compress(const std::string& data,std::string& newdata);
bool Uncompress(std::string& data);
int splitchar(const std::string& s,char c,std::vector<std::string>& v);

#endif
