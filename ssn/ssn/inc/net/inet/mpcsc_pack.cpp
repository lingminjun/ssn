/*---------------------------------------------------------------------------
// Filename:        mpcsc_pack.cpp
// Date:            2013-10-14 23:19:05
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//---------------------------------------------------------------------------*/
#include "mpcsc_pack.h"

void CMpcsReqCreateroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)2;
        (*this) << FT_STRING;
        (*this) << m_roomName;
        (*this) << FT_vector;
        (*this) << FT_STRUCT;
        {
            uint32_t nLen = m_contactList.size();
            (*this) << nLen;
            vector< SRoomUserInfo >::const_iterator itr;
            for(itr = m_contactList.cbegin(); itr != m_contactList.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqCreateroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 2) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomName;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_contactList.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                SRoomUserInfo tmpVal;
                (*this) >> tmpVal;
                m_contactList.push_back(tmpVal);
            }
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

void CMpcsRspCreateroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)4;
        (*this) << FT_UINT8;
        (*this) << m_retcode;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_STRUCT;
        (*this) << m_info;
        (*this) << FT_STRING;
        (*this) << m_retmsg;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspCreateroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 4) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retcode;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_STRUCT) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_info;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retmsg;
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

void CMpcsNtfCreateroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)3;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_STRING;
        (*this) << m_creater;
        (*this) << FT_STRUCT;
        (*this) << m_info;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsNtfCreateroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_creater;
        (*this) >> field;
        if(field.m_baseType != FT_STRUCT) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_info;
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

void CMpcsReqInviteroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)3;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_vector;
        (*this) << FT_STRUCT;
        {
            uint32_t nLen = m_userIds.size();
            (*this) << nLen;
            vector< SRoomUserInfo >::const_iterator itr;
            for(itr = m_userIds.cbegin(); itr != m_userIds.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
        (*this) << FT_STRING;
        (*this) << m_remark;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqInviteroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_userIds.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                SRoomUserInfo tmpVal;
                (*this) >> tmpVal;
                m_userIds.push_back(tmpVal);
            }
        }
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_remark;
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

void CMpcsRspInviteroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)5;
        (*this) << FT_UINT8;
        (*this) << m_retcode;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_vector;
        (*this) << FT_STRUCT;
        {
            uint32_t nLen = m_userIds.size();
            (*this) << nLen;
            vector< SRoomUserInfo >::const_iterator itr;
            for(itr = m_userIds.cbegin(); itr != m_userIds.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
        (*this) << FT_INT64;
        (*this) << m_memberTimes;
        (*this) << FT_STRING;
        (*this) << m_retmsg;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspInviteroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 5) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retcode;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_userIds.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                SRoomUserInfo tmpVal;
                (*this) >> tmpVal;
                m_userIds.push_back(tmpVal);
            }
        }
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_memberTimes;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retmsg;
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

void CMpcsReqJoinroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)3;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_STRING;
        (*this) << m_inviter;
        (*this) << FT_STRING;
        (*this) << m_password;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqJoinroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_inviter;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_password;
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

void CMpcsRspJoinroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)5;
        (*this) << FT_UINT8;
        (*this) << m_retcode;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_INT64;
        (*this) << m_memberTimes;
        (*this) << FT_vector;
        (*this) << FT_STRING;
        {
            uint32_t nLen = m_memberList.size();
            (*this) << nLen;
            vector< string >::const_iterator itr;
            for(itr = m_memberList.cbegin(); itr != m_memberList.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
        (*this) << FT_STRING;
        (*this) << m_retmsg;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspJoinroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 5) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retcode;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_memberTimes;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_memberList.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                string tmpVal;
                (*this) >> tmpVal;
                m_memberList.push_back(tmpVal);
            }
        }
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retmsg;
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

void CMpcsReqExitroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)1;
        (*this) << FT_STRING;
        (*this) << m_roomId;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqExitroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 1) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
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

void CMpcsRspExitroom::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)2;
        (*this) << FT_UINT8;
        (*this) << m_retcode;
        (*this) << FT_STRING;
        (*this) << m_roomId;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspExitroom::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 2) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retcode;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
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

void CMpcsReqGetroominfo::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)3;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_INT64;
        (*this) << m_msgTimes;
        (*this) << FT_INT64;
        (*this) << m_memberTimes;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqGetroominfo::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_msgTimes;
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_memberTimes;
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

void CMpcsRspGetroominfo::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)3;
        (*this) << FT_UINT8;
        (*this) << m_retcode;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_STRUCT;
        (*this) << m_info;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspGetroominfo::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retcode;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_STRUCT) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_info;
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

void CMpcsReqSendMsg::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)5;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_UINT8;
        (*this) << m_msgType;
        (*this) << FT_STRING;
        (*this) << m_message;
        (*this) << FT_STRING;
        (*this) << m_targetId;
        (*this) << FT_INT64;
        (*this) << m_msgId;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqSendMsg::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 5) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_msgType;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_message;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_targetId;
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_msgId;
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

void CMpcsRspSendMsg::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)4;
        (*this) << FT_UINT8;
        (*this) << m_retcode;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_INT64;
        (*this) << m_sendTime;
        (*this) << FT_INT64;
        (*this) << m_msgTimes;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspSendMsg::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_retcode;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_sendTime;
        try
        {
            if(num < 4) return PACK_RIGHT;
            (*this) >> field;
            if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
            (*this) >> m_msgTimes;
        }
        catch(PACKRETCODE)
        {
            return PACK_RIGHT;
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

void CMpcsNtfMessage::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)3;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_STRING;
        (*this) << m_fromId;
        (*this) << FT_UINT8;
        (*this) << m_msgType;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsNtfMessage::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 3) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_fromId;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_msgType;
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

void CMpcsNtfUsersts::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)7;
        (*this) << FT_STRING;
        (*this) << m_roomId;
        (*this) << FT_STRING;
        (*this) << m_fromId;
        (*this) << FT_STRING;
        (*this) << m_nickName;
        (*this) << FT_STRING;
        (*this) << m_inviter;
        (*this) << FT_UINT8;
        (*this) << m_type;
        (*this) << FT_INT64;
        (*this) << m_memberTimes;
        (*this) << FT_STRING;
        (*this) << m_remark;
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsNtfUsersts::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 7) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_roomId;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_fromId;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_nickName;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_inviter;
        (*this) >> field;
        if(field.m_baseType != FT_UINT8) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_type;
        (*this) >> field;
        if(field.m_baseType != FT_INT64) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_memberTimes;
        (*this) >> field;
        if(field.m_baseType != FT_STRING) return PACK_TYPEMATCH_ERROR;
        (*this) >> m_remark;
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

void CMpcsReqOffmsgCount::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)1;
        (*this) << FT_vector;
        (*this) << FT_STRUCT;
        {
            uint32_t nLen = m_roomList.size();
            (*this) << nLen;
            vector< SMpcsOffmsgTimes >::const_iterator itr;
            for(itr = m_roomList.cbegin(); itr != m_roomList.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsReqOffmsgCount::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 1) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_roomList.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                SMpcsOffmsgTimes tmpVal;
                (*this) >> tmpVal;
                m_roomList.push_back(tmpVal);
            }
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

void CMpcsRspOffmsgCount::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)1;
        (*this) << FT_vector;
        (*this) << FT_STRUCT;
        {
            uint32_t nLen = m_offmsgCounts.size();
            (*this) << nLen;
            vector< SMpcsOffmsgCount >::const_iterator itr;
            for(itr = m_offmsgCounts.cbegin(); itr != m_offmsgCounts.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspOffmsgCount::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 1) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_offmsgCounts.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                SMpcsOffmsgCount tmpVal;
                (*this) >> tmpVal;
                m_offmsgCounts.push_back(tmpVal);
            }
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

void CMpcsReqRoomidlist::PackData(string& strData)
{
}

PACKRETCODE CMpcsReqRoomidlist::UnpackData(const string& strData)
{
    return PACK_RIGHT;
}

void CMpcsRspRoomidlist::PackData(string& strData)
{
    try
    {
        ResetOutBuff(strData);
        strData.reserve(Size() + 7);
        (*this) << (uint8_t)1;
        (*this) << FT_vector;
        (*this) << FT_STRING;
        {
            uint32_t nLen = m_roomsId.size();
            (*this) << nLen;
            vector< string >::const_iterator itr;
            for(itr = m_roomsId.cbegin(); itr != m_roomsId.cend(); ++itr)
            {
                (*this) << (*itr);
            }
        }
    }
    catch(std::exception&)
    {
        strData = "";
    }
}

PACKRETCODE CMpcsRspRoomidlist::UnpackData(const string& strData)
{
    try
    {
        ResetInBuff(strData);
        uint8_t num;
        (*this) >> num;
        if(num < 1) return PACK_LENGTH_ERROR;
         CFieldType field;
        (*this) >> field;
        if(field.m_baseType != FT_vector) return PACK_TYPEMATCH_ERROR;
        {
            uint32_t nSize;
            (*this) >> nSize;
            if(nSize > MAX_RECORD_SIZE) throw PACK_LENGTH_ERROR;
            m_roomsId.reserve(nSize);
            for(uint32_t i = 0; i < nSize; i++)
            {
                string tmpVal;
                (*this) >> tmpVal;
                m_roomsId.push_back(tmpVal);
            }
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

