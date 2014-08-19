/*---------------------------------------------------------------------------
// Filename:        mpcsstrc_pack.cpp
// Date:            2013-10-14 23:19:05
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//---------------------------------------------------------------------------*/
#include "mpcsstrc_pack.h"

CPackData& operator<< ( CPackData& cPackData, const SMpcsMessage&  sMpcsMessage )
{
        uint8_t nFieldNum = 5;
    do {
        if(sMpcsMessage.m_msgId == 0)
            nFieldNum--;
        else
            break;
    } while(0);
    cPackData << nFieldNum;
    cPackData << FT_STRING;
    cPackData << sMpcsMessage.m_fromId;
    cPackData << FT_UINT8;
    cPackData << sMpcsMessage.m_type;
    cPackData << FT_STRING;
    cPackData << sMpcsMessage.m_message;
    cPackData << FT_INT64;
    cPackData << sMpcsMessage.m_sendTime;
    if(nFieldNum == 4) return cPackData;
    cPackData << FT_UINT64;
    cPackData << sMpcsMessage.m_msgId;

    return cPackData;

}

CPackData& operator>> ( CPackData& cPackData, SMpcsMessage&  sMpcsMessage )
{
    uint8_t num;
    cPackData >> num;
    if(num < 4) throw PACK_LENGTH_ERROR;
    CFieldType field;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsMessage.m_fromId;
    cPackData >> field;
    if(field.m_baseType != FT_UINT8) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsMessage.m_type;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsMessage.m_message;
    cPackData >> field;
    if(field.m_baseType != FT_INT64) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsMessage.m_sendTime;
    try
    {
        if(num < 5) return cPackData;
        cPackData >> field;
        if(field.m_baseType != FT_UINT64) throw PACK_TYPEMATCH_ERROR;
        cPackData >> sMpcsMessage.m_msgId;
    }
    catch(PACKRETCODE)
    {
        return cPackData;
    }
    for(int i = 5; i < num; i++)
        cPackData.PeekField();
    return cPackData;
}

CPackData& operator<< ( CPackData& cPackData, const SMpcsOffmsgTimes&  sMpcsOffmsgTimes )
{
        uint8_t nFieldNum = 2;
    cPackData << nFieldNum;
    cPackData << FT_STRING;
    cPackData << sMpcsOffmsgTimes.m_roomId;
    cPackData << FT_INT64;
    cPackData << sMpcsOffmsgTimes.m_msgTimes;

    return cPackData;

}

CPackData& operator>> ( CPackData& cPackData, SMpcsOffmsgTimes&  sMpcsOffmsgTimes )
{
    uint8_t num;
    cPackData >> num;
    if(num < 2) throw PACK_LENGTH_ERROR;
    CFieldType field;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsOffmsgTimes.m_roomId;
    cPackData >> field;
    if(field.m_baseType != FT_INT64) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsOffmsgTimes.m_msgTimes;
    for(int i = 2; i < num; i++)
        cPackData.PeekField();
    return cPackData;
}

CPackData& operator<< ( CPackData& cPackData, const SMpcsOffmsgCount&  sMpcsOffmsgCount )
{
        uint8_t nFieldNum = 2;
    cPackData << nFieldNum;
    cPackData << FT_STRING;
    cPackData << sMpcsOffmsgCount.m_roomId;
    cPackData << FT_UINT32;
    cPackData << sMpcsOffmsgCount.m_count;

    return cPackData;

}

CPackData& operator>> ( CPackData& cPackData, SMpcsOffmsgCount&  sMpcsOffmsgCount )
{
    uint8_t num;
    cPackData >> num;
    if(num < 2) throw PACK_LENGTH_ERROR;
    CFieldType field;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsOffmsgCount.m_roomId;
    cPackData >> field;
    if(field.m_baseType != FT_UINT32) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sMpcsOffmsgCount.m_count;
    for(int i = 2; i < num; i++)
        cPackData.PeekField();
    return cPackData;
}

CPackData& operator<< ( CPackData& cPackData, const SRoomUserInfo&  sRoomUserInfo )
{
        uint8_t nFieldNum = 2;
    cPackData << nFieldNum;
    cPackData << FT_STRING;
    cPackData << sRoomUserInfo.m_userId;
    cPackData << FT_STRING;
    cPackData << sRoomUserInfo.m_nickName;

    return cPackData;

}

CPackData& operator>> ( CPackData& cPackData, SRoomUserInfo&  sRoomUserInfo )
{
    uint8_t num;
    cPackData >> num;
    if(num < 2) throw PACK_LENGTH_ERROR;
    CFieldType field;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sRoomUserInfo.m_userId;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sRoomUserInfo.m_nickName;
    for(int i = 2; i < num; i++)
        cPackData.PeekField();
    return cPackData;
}

CPackData& operator<< ( CPackData& cPackData, const SRoomInfo&  sRoomInfo )
{
        uint8_t nFieldNum = 7;
    do {
        if(sRoomInfo.m_msgTimes == 0)
            nFieldNum--;
        else
            break;
    } while(0);
    cPackData << nFieldNum;
    cPackData << FT_STRING;
    cPackData << sRoomInfo.m_roomName;
    cPackData << FT_STRING;
    cPackData << sRoomInfo.m_password;
    cPackData << FT_INT64;
    cPackData << sRoomInfo.m_memberTimes;
    cPackData << FT_vector;
    cPackData << FT_STRUCT;
    {
        uint32_t nLen = sRoomInfo.m_memberList.size();
        cPackData << nLen;
        vector< SRoomUserInfo >::const_iterator itr;
        for(itr = sRoomInfo.m_memberList.begin(); itr != sRoomInfo.m_memberList.end(); ++itr)
        {
            cPackData << (*itr);
        }
    }
    cPackData << FT_INT64;
    cPackData << sRoomInfo.m_lastMsgTimes;
    cPackData << FT_vector;
    cPackData << FT_STRUCT;
    {
        uint32_t nLen = sRoomInfo.m_messages.size();
        cPackData << nLen;
        vector< SMpcsMessage >::const_iterator itr;
        for(itr = sRoomInfo.m_messages.begin(); itr != sRoomInfo.m_messages.end(); ++itr)
        {
            cPackData << (*itr);
        }
    }
    if(nFieldNum == 6) return cPackData;
    cPackData << FT_INT64;
    cPackData << sRoomInfo.m_msgTimes;

    return cPackData;

}

CPackData& operator>> ( CPackData& cPackData, SRoomInfo&  sRoomInfo )
{
    uint8_t num;
    cPackData >> num;
    if(num < 6) throw PACK_LENGTH_ERROR;
    CFieldType field;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sRoomInfo.m_roomName;
    cPackData >> field;
    if(field.m_baseType != FT_STRING) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sRoomInfo.m_password;
    cPackData >> field;
    if(field.m_baseType != FT_INT64) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sRoomInfo.m_memberTimes;
    cPackData >> field;
    if(field.m_baseType != FT_vector) throw PACK_TYPEMATCH_ERROR;
    {
        uint32_t nSize;
        cPackData >> nSize;
        if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
        sRoomInfo.m_memberList.reserve(nSize);
        for(uint32_t i = 0; i < nSize; i++)
        {
            SRoomUserInfo tmpVal;
            cPackData >> tmpVal;
            sRoomInfo.m_memberList.push_back(tmpVal);
        }
    }
    cPackData >> field;
    if(field.m_baseType != FT_INT64) throw PACK_TYPEMATCH_ERROR;
    cPackData >> sRoomInfo.m_lastMsgTimes;
    cPackData >> field;
    if(field.m_baseType != FT_vector) throw PACK_TYPEMATCH_ERROR;
    {
        uint32_t nSize;
        cPackData >> nSize;
        if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
        sRoomInfo.m_messages.reserve(nSize);
        for(uint32_t i = 0; i < nSize; i++)
        {
            SMpcsMessage tmpVal;
            cPackData >> tmpVal;
            sRoomInfo.m_messages.push_back(tmpVal);
        }
    }
    try
    {
        if(num < 7) return cPackData;
        cPackData >> field;
        if(field.m_baseType != FT_INT64) throw PACK_TYPEMATCH_ERROR;
        cPackData >> sRoomInfo.m_msgTimes;
    }
    catch(PACKRETCODE)
    {
        return cPackData;
    }
    for(int i = 7; i < num; i++)
        cPackData.PeekField();
    return cPackData;
}

