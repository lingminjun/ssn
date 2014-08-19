#include "memfile.h"
#include <assert.h>


MemFile::MemFile()
{
    m_begin=0;
    m_size=0;
}
void MemFile::append(const char* buff,size_t n)
{
    if(capacity()<256)
    {
        reserve(256);
    }
    m_buff.append(buff,n);
    m_size +=n;
}
void MemFile::append(const std::string& data){
    append(data.c_str(),data.size());
}
void MemFile::writedSize(size_t wsize){
    size_t tmpsize=m_buff.size();
    assert(wsize+m_begin<=tmpsize);
    m_begin +=wsize;
    size_t leftsize= m_buff.size() - m_begin;
    if((m_begin>4096)&&( m_begin>leftsize))
    {
        m_buff.replace(0,leftsize,m_buff.data()+m_begin,leftsize);
        m_buff.resize(leftsize);
        m_begin=0;	
    }
    m_size -=wsize;
    if(m_size==0 && m_begin>1024)
    {
        m_buff.resize(0);
        m_begin=0;
    }
}
const char* MemFile::getReadableData(size_t& nSize){
    nSize=size();
    return m_buff.data()+m_begin;
}
void MemFile::clear(){
    m_buff.clear();
    m_size=0;
    m_begin=0; 
}
size_t MemFile::capacity()
{
    return m_buff.capacity();
}
void MemFile::reserve(size_t len)
{
    m_buff.reserve(len+m_buff.size());
}
size_t MemFile::size()
{
    return m_size;
}


