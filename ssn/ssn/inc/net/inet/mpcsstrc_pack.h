/*---------------------------------------------------------------------------
// Filename:        mpcsstrc_pack.h
// Date:            2013-10-14 23:19:05
// Author:          autogen
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//---------------------------------------------------------------------------*/
#ifndef __MPCSSTRC_PACK_H__
#define __MPCSSTRC_PACK_H__

#include <string>
#include <vector>
#include <map>
#include "packdata.h"

using namespace std;

struct SMpcsMessage
{
  public:
    SMpcsMessage() : m_msgId(0)
    {
    }

    ~SMpcsMessage()
    {
    }
    SMpcsMessage(const string &strFromId, const uint8_t &chType, const string &strMessage, const int64_t &llSendTime,
                 const uint64_t &ullMsgId = 0)
    {
        m_fromId = strFromId;
        m_type = chType;
        m_message = strMessage;
        m_sendTime = llSendTime;
        m_msgId = ullMsgId;
    }
    SMpcsMessage &operator=(const SMpcsMessage &sMpcsMessage)
    {
        m_fromId = sMpcsMessage.m_fromId;
        m_type = sMpcsMessage.m_type;
        m_message = sMpcsMessage.m_message;
        m_sendTime = sMpcsMessage.m_sendTime;
        m_msgId = sMpcsMessage.m_msgId;
        return *this;
    }

    string m_fromId;
    uint8_t m_type;
    string m_message;
    int64_t m_sendTime;
    uint64_t m_msgId;

  public:
    uint32_t Size() const;
};

inline uint32_t SMpcsMessage::Size() const
{
    uint32_t nSize = 31;
    nSize += m_fromId.length();
    nSize += m_message.length();
    return nSize;
}

CPackData &operator<<(CPackData &cPackData, const SMpcsMessage &sMpcsMessage);
CPackData &operator>>(CPackData &cPackData, SMpcsMessage &sMpcsMessage);

struct SMpcsOffmsgTimes
{
  public:
    SMpcsOffmsgTimes()
    {
    }

    ~SMpcsOffmsgTimes()
    {
    }
    SMpcsOffmsgTimes(const string &strRoomId, const int64_t &llMsgTimes)
    {
        m_roomId = strRoomId;
        m_msgTimes = llMsgTimes;
    }
    SMpcsOffmsgTimes &operator=(const SMpcsOffmsgTimes &sMpcsOffmsgTimes)
    {
        m_roomId = sMpcsOffmsgTimes.m_roomId;
        m_msgTimes = sMpcsOffmsgTimes.m_msgTimes;
        return *this;
    }

    string m_roomId;
    int64_t m_msgTimes;

  public:
    uint32_t Size() const;
};

inline uint32_t SMpcsOffmsgTimes::Size() const
{
    uint32_t nSize = 15;
    nSize += m_roomId.length();
    return nSize;
}

CPackData &operator<<(CPackData &cPackData, const SMpcsOffmsgTimes &sMpcsOffmsgTimes);
CPackData &operator>>(CPackData &cPackData, SMpcsOffmsgTimes &sMpcsOffmsgTimes);

struct SMpcsOffmsgCount
{
  public:
    SMpcsOffmsgCount()
    {
    }

    ~SMpcsOffmsgCount()
    {
    }
    SMpcsOffmsgCount(const string &strRoomId, const uint32_t &dwCount)
    {
        m_roomId = strRoomId;
        m_count = dwCount;
    }
    SMpcsOffmsgCount &operator=(const SMpcsOffmsgCount &sMpcsOffmsgCount)
    {
        m_roomId = sMpcsOffmsgCount.m_roomId;
        m_count = sMpcsOffmsgCount.m_count;
        return *this;
    }

    string m_roomId;
    uint32_t m_count;

  public:
    uint32_t Size() const;
};

inline uint32_t SMpcsOffmsgCount::Size() const
{
    uint32_t nSize = 11;
    nSize += m_roomId.length();
    return nSize;
}

CPackData &operator<<(CPackData &cPackData, const SMpcsOffmsgCount &sMpcsOffmsgCount);
CPackData &operator>>(CPackData &cPackData, SMpcsOffmsgCount &sMpcsOffmsgCount);

struct SRoomUserInfo
{
  public:
    SRoomUserInfo()
    {
    }

    ~SRoomUserInfo()
    {
    }
    SRoomUserInfo(const string &strUserId, const string &strNickName)
    {
        m_userId = strUserId;
        m_nickName = strNickName;
    }
    SRoomUserInfo &operator=(const SRoomUserInfo &sRoomUserInfo)
    {
        m_userId = sRoomUserInfo.m_userId;
        m_nickName = sRoomUserInfo.m_nickName;
        return *this;
    }

    string m_userId;
    string m_nickName;

  public:
    uint32_t Size() const;
};

inline uint32_t SRoomUserInfo::Size() const
{
    uint32_t nSize = 11;
    nSize += m_userId.length();
    nSize += m_nickName.length();
    return nSize;
}

CPackData &operator<<(CPackData &cPackData, const SRoomUserInfo &sRoomUserInfo);
CPackData &operator>>(CPackData &cPackData, SRoomUserInfo &sRoomUserInfo);

struct SRoomInfo
{
  public:
    SRoomInfo() : m_msgTimes(0)
    {
    }

    ~SRoomInfo()
    {
    }
    SRoomInfo(const string &strRoomName, const string &strPassword, const int64_t &llMemberTimes,
              const vector<SRoomUserInfo> &vecMemberList, const int64_t &llLastMsgTimes,
              const vector<SMpcsMessage> &vecMessages, const int64_t &llMsgTimes = 0)
    {
        m_roomName = strRoomName;
        m_password = strPassword;
        m_memberTimes = llMemberTimes;
        m_memberList = vecMemberList;
        m_lastMsgTimes = llLastMsgTimes;
        m_messages = vecMessages;
        m_msgTimes = llMsgTimes;
    }
    SRoomInfo &operator=(const SRoomInfo &sRoomInfo)
    {
        m_roomName = sRoomInfo.m_roomName;
        m_password = sRoomInfo.m_password;
        m_memberTimes = sRoomInfo.m_memberTimes;
        m_memberList = sRoomInfo.m_memberList;
        m_lastMsgTimes = sRoomInfo.m_lastMsgTimes;
        m_messages = sRoomInfo.m_messages;
        m_msgTimes = sRoomInfo.m_msgTimes;
        return *this;
    }

    string m_roomName;
    string m_password;
    int64_t m_memberTimes;
    vector<SRoomUserInfo> m_memberList;
    int64_t m_lastMsgTimes;
    vector<SMpcsMessage> m_messages;
    int64_t m_msgTimes;

  public:
    uint32_t Size() const;
};

inline uint32_t SRoomInfo::Size() const
{
    uint32_t nSize = 50;
    nSize += m_roomName.length();
    nSize += m_password.length();
    for (uint32_t i = 0; i < m_memberList.size(); i++)
    {
        nSize += m_memberList[i].Size();
    }
    for (uint32_t i = 0; i < m_messages.size(); i++)
    {
        nSize += m_messages[i].Size();
    }
    return nSize;
}

CPackData &operator<<(CPackData &cPackData, const SRoomInfo &sRoomInfo);
CPackData &operator>>(CPackData &cPackData, SRoomInfo &sRoomInfo);

#endif
