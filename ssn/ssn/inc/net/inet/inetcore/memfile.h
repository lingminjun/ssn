#ifndef _H_ALIMAIL_MEMFILE_H
#define _H_ALIMAIL_MEMFILE_H

#include <string>

class MemFile
{
public:
    MemFile();
    void append(const char* buff,size_t n);
    void append(const std::string& data);
    void writedSize(size_t wsize);
    const char* getReadableData(size_t& nSize);
    void clear();
    size_t capacity();
    void reserve(size_t len);
    size_t size();
private:
    size_t m_begin;
    std::string m_buff;
    size_t m_size;
};
        
        

#endif


