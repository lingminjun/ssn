#ifndef _H_INETEXCEPTION_H
#define _H_INETEXCEPTION_H

#include <exception>
#include <string>

using namespace std;


class INetException: public exception
{
public:
    INetException(const char*) throw();
    INetException(const string& errstr)throw();
    virtual ~INetException() throw();
    
    /** Returns a C-style character string describing the general cause
     *  of the current error.  */
    virtual const char* what() const throw();
private:
    string m_errstr;
};

#endif
