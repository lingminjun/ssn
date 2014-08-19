/*---------------------------------------------------------------------------
// Filename:        msc_head.cpp
// Date:            2013-10-14 23:19:05
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//---------------------------------------------------------------------------*/
#include "msc_head.h"

void CMscHead::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        m_lrc = 0;
        (*this) << m_starter;
        (*this) << m_major;
        (*this) << m_minor;
        (*this) << m_msgtype;
        (*this) << m_encrypt;
        (*this) << m_compress;
        (*this) << m_encode;
        (*this) << m_lrc;
        (*this) << m_seq;
        (*this) << m_len;
        (*this) << m_cmd;
        (*this) << m_cc;
        (*this) << m_reserved;
        if((m_reserved & 0x01) == 1)
        {
            (*this) << m_extdata;
        }
        m_lrc = CalcLrc(strData, Size());
        SetOutCursor(7);
        (*this) << m_lrc;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMscHead::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        if(CalcLrc(strData, Size()) != 0) return PACK_INVALID;
        (*this) >> m_starter;
        (*this) >> m_major;
        (*this) >> m_minor;
        (*this) >> m_msgtype;
        (*this) >> m_encrypt;
        (*this) >> m_compress;
        (*this) >> m_encode;
        (*this) >> m_lrc;
        (*this) >> m_seq;
        (*this) >> m_len;
        (*this) >> m_cmd;
        (*this) >> m_cc;
        (*this) >> m_reserved;
        if((m_reserved & 0x01) == 1)
        {
            (*this) >> m_extdata;
        }
    }
    catch(PACKRETCODE ret)
    {
        return ret;
    }
    catch(std::exception&)
    {
        return PACK_SYSTEM_ERROR;
    }
    return PACK_RIGHT;
}

