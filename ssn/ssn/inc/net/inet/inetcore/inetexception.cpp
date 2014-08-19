#include "inetexception.h"

INetException::INetException(const char* errstr) throw()
{
    if(errstr)
        m_errstr=errstr;
}
INetException::INetException(const string& errstr)throw()
{
    m_errstr=errstr;
}
INetException::~INetException() throw()
{
    
}

const char* INetException::what() const throw()
{
    return m_errstr.c_str();
}