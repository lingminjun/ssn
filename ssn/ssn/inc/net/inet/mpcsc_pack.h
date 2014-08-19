/*---------------------------------------------------------------------------
// Filename:        mpcsc_pack.h
// Date:            2013-10-14 23:19:05
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//---------------------------------------------------------------------------*/
#ifndef __MPCSC_PACK_H__
#define __MPCSC_PACK_H__

#include <string>
#include <vector>
#include <map>
#include "packdata.h"
#include "mpcsc_cmd.h"
#include "mpcsstrc_pack.h"

using namespace std;

class CMpcsReqCreateroom : public CPackData
{
public:
    CMpcsReqCreateroom()
    {
    }

    ~CMpcsReqCreateroom() { }
    CMpcsReqCreateroom(const string&  strRoomName, const vector< SRoomUserInfo >&  vecContactList)
    {
        m_roomName = strRoomName;
        m_contactList = vecContactList;
    }
    CMpcsReqCreateroom&  operator=( const CMpcsReqCreateroom&  cMpcsReqCreateroom )
    {
        m_roomName = cMpcsReqCreateroom.m_roomName;
        m_contactList = cMpcsReqCreateroom.m_contactList;
        return *this;
    }

    const string&  GetRoomName () const { return m_roomName; }
    bool SetRoomName ( const string&  strRoomName )
    {
        m_roomName = strRoomName;
        return true;
    }
    const vector< SRoomUserInfo >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< SRoomUserInfo >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
private:
    string m_roomName;
    vector< SRoomUserInfo > m_contactList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqCreateroom::Size() const
{
    uint32_t nSize = 12;
    nSize += m_roomName.length();
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].Size();
    }
    return nSize;
}

class CMpcsRspCreateroom : public CPackData
{
public:
    CMpcsRspCreateroom()
    {
    }

    ~CMpcsRspCreateroom() { }
    CMpcsRspCreateroom(const uint8_t&  chRetcode, const string&  strRoomId, const SRoomInfo&  sInfo, const string&  strRetmsg)
    {
        m_retcode = chRetcode;
        m_roomId = strRoomId;
        m_info = sInfo;
        m_retmsg = strRetmsg;
    }
    CMpcsRspCreateroom&  operator=( const CMpcsRspCreateroom&  cMpcsRspCreateroom )
    {
        m_retcode = cMpcsRspCreateroom.m_retcode;
        m_roomId = cMpcsRspCreateroom.m_roomId;
        m_info = cMpcsRspCreateroom.m_info;
        m_retmsg = cMpcsRspCreateroom.m_retmsg;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const SRoomInfo&  GetInfo () const { return m_info; }
    bool SetInfo ( const SRoomInfo&  sInfo )
    {
        m_info = sInfo;
        return true;
    }
    const string&  GetRetmsg () const { return m_retmsg; }
    bool SetRetmsg ( const string&  strRetmsg )
    {
        m_retmsg = strRetmsg;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_roomId;
    SRoomInfo m_info;
    string m_retmsg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspCreateroom::Size() const
{
    uint32_t nSize = 14;
    nSize += m_roomId.length();
    nSize += m_info.Size();
    nSize += m_retmsg.length();
    return nSize;
}

class CMpcsNtfCreateroom : public CPackData
{
public:
    CMpcsNtfCreateroom()
    {
    }

    ~CMpcsNtfCreateroom() { }
    CMpcsNtfCreateroom(const string&  strRoomId, const string&  strCreater, const SRoomInfo&  sInfo)
    {
        m_roomId = strRoomId;
        m_creater = strCreater;
        m_info = sInfo;
    }
    CMpcsNtfCreateroom&  operator=( const CMpcsNtfCreateroom&  cMpcsNtfCreateroom )
    {
        m_roomId = cMpcsNtfCreateroom.m_roomId;
        m_creater = cMpcsNtfCreateroom.m_creater;
        m_info = cMpcsNtfCreateroom.m_info;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const string&  GetCreater () const { return m_creater; }
    bool SetCreater ( const string&  strCreater )
    {
        m_creater = strCreater;
        return true;
    }
    const SRoomInfo&  GetInfo () const { return m_info; }
    bool SetInfo ( const SRoomInfo&  sInfo )
    {
        m_info = sInfo;
        return true;
    }
private:
    string m_roomId;
    string m_creater;
    SRoomInfo m_info;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsNtfCreateroom::Size() const
{
    uint32_t nSize = 12;
    nSize += m_roomId.length();
    nSize += m_creater.length();
    nSize += m_info.Size();
    return nSize;
}

class CMpcsReqInviteroom : public CPackData
{
public:
    CMpcsReqInviteroom()
    {
    }

    ~CMpcsReqInviteroom() { }
    CMpcsReqInviteroom(const string&  strRoomId, const vector< SRoomUserInfo >&  vecUserIds, const string&  strRemark)
    {
        m_roomId = strRoomId;
        m_userIds = vecUserIds;
        m_remark = strRemark;
    }
    CMpcsReqInviteroom&  operator=( const CMpcsReqInviteroom&  cMpcsReqInviteroom )
    {
        m_roomId = cMpcsReqInviteroom.m_roomId;
        m_userIds = cMpcsReqInviteroom.m_userIds;
        m_remark = cMpcsReqInviteroom.m_remark;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const vector< SRoomUserInfo >&  GetUserIds () const { return m_userIds; }
    bool SetUserIds ( const vector< SRoomUserInfo >&  vecUserIds )
    {
        m_userIds = vecUserIds;
        return true;
    }
    const string&  GetRemark () const { return m_remark; }
    bool SetRemark ( const string&  strRemark )
    {
        m_remark = strRemark;
        return true;
    }
private:
    string m_roomId;
    vector< SRoomUserInfo > m_userIds;
    string m_remark;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqInviteroom::Size() const
{
    uint32_t nSize = 17;
    nSize += m_roomId.length();
    for(uint32_t i = 0; i < m_userIds.size(); i++)
    {
        nSize += m_userIds[i].Size();
    }
    nSize += m_remark.length();
    return nSize;
}

class CMpcsRspInviteroom : public CPackData
{
public:
    CMpcsRspInviteroom()
    {
    }

    ~CMpcsRspInviteroom() { }
    CMpcsRspInviteroom(const uint8_t&  chRetcode, const string&  strRoomId, const vector< SRoomUserInfo >&  vecUserIds, const int64_t&  llMemberTimes, const string&  strRetmsg)
    {
        m_retcode = chRetcode;
        m_roomId = strRoomId;
        m_userIds = vecUserIds;
        m_memberTimes = llMemberTimes;
        m_retmsg = strRetmsg;
    }
    CMpcsRspInviteroom&  operator=( const CMpcsRspInviteroom&  cMpcsRspInviteroom )
    {
        m_retcode = cMpcsRspInviteroom.m_retcode;
        m_roomId = cMpcsRspInviteroom.m_roomId;
        m_userIds = cMpcsRspInviteroom.m_userIds;
        m_memberTimes = cMpcsRspInviteroom.m_memberTimes;
        m_retmsg = cMpcsRspInviteroom.m_retmsg;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const vector< SRoomUserInfo >&  GetUserIds () const { return m_userIds; }
    bool SetUserIds ( const vector< SRoomUserInfo >&  vecUserIds )
    {
        m_userIds = vecUserIds;
        return true;
    }
    const int64_t&  GetMemberTimes () const { return m_memberTimes; }
    bool SetMemberTimes ( const int64_t&  llMemberTimes )
    {
        m_memberTimes = llMemberTimes;
        return true;
    }
    const string&  GetRetmsg () const { return m_retmsg; }
    bool SetRetmsg ( const string&  strRetmsg )
    {
        m_retmsg = strRetmsg;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_roomId;
    vector< SRoomUserInfo > m_userIds;
    int64_t m_memberTimes;
    string m_retmsg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspInviteroom::Size() const
{
    uint32_t nSize = 28;
    nSize += m_roomId.length();
    for(uint32_t i = 0; i < m_userIds.size(); i++)
    {
        nSize += m_userIds[i].Size();
    }
    nSize += m_retmsg.length();
    return nSize;
}

class CMpcsReqJoinroom : public CPackData
{
public:
    CMpcsReqJoinroom()
    {
    }

    ~CMpcsReqJoinroom() { }
    CMpcsReqJoinroom(const string&  strRoomId, const string&  strInviter, const string&  strPassword)
    {
        m_roomId = strRoomId;
        m_inviter = strInviter;
        m_password = strPassword;
    }
    CMpcsReqJoinroom&  operator=( const CMpcsReqJoinroom&  cMpcsReqJoinroom )
    {
        m_roomId = cMpcsReqJoinroom.m_roomId;
        m_inviter = cMpcsReqJoinroom.m_inviter;
        m_password = cMpcsReqJoinroom.m_password;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const string&  GetInviter () const { return m_inviter; }
    bool SetInviter ( const string&  strInviter )
    {
        m_inviter = strInviter;
        return true;
    }
    const string&  GetPassword () const { return m_password; }
    bool SetPassword ( const string&  strPassword )
    {
        m_password = strPassword;
        return true;
    }
private:
    string m_roomId;
    string m_inviter;
    string m_password;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqJoinroom::Size() const
{
    uint32_t nSize = 16;
    nSize += m_roomId.length();
    nSize += m_inviter.length();
    nSize += m_password.length();
    return nSize;
}

class CMpcsRspJoinroom : public CPackData
{
public:
    CMpcsRspJoinroom()
    {
    }

    ~CMpcsRspJoinroom() { }
    CMpcsRspJoinroom(const uint8_t&  chRetcode, const string&  strRoomId, const int64_t&  llMemberTimes, const vector< string >&  vecMemberList, const string&  strRetmsg)
    {
        m_retcode = chRetcode;
        m_roomId = strRoomId;
        m_memberTimes = llMemberTimes;
        m_memberList = vecMemberList;
        m_retmsg = strRetmsg;
    }
    CMpcsRspJoinroom&  operator=( const CMpcsRspJoinroom&  cMpcsRspJoinroom )
    {
        m_retcode = cMpcsRspJoinroom.m_retcode;
        m_roomId = cMpcsRspJoinroom.m_roomId;
        m_memberTimes = cMpcsRspJoinroom.m_memberTimes;
        m_memberList = cMpcsRspJoinroom.m_memberList;
        m_retmsg = cMpcsRspJoinroom.m_retmsg;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const int64_t&  GetMemberTimes () const { return m_memberTimes; }
    bool SetMemberTimes ( const int64_t&  llMemberTimes )
    {
        m_memberTimes = llMemberTimes;
        return true;
    }
    const vector< string >&  GetMemberList () const { return m_memberList; }
    bool SetMemberList ( const vector< string >&  vecMemberList )
    {
        m_memberList = vecMemberList;
        return true;
    }
    const string&  GetRetmsg () const { return m_retmsg; }
    bool SetRetmsg ( const string&  strRetmsg )
    {
        m_retmsg = strRetmsg;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_roomId;
    int64_t m_memberTimes;
    vector< string > m_memberList;
    string m_retmsg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspJoinroom::Size() const
{
    uint32_t nSize = 28;
    nSize += m_roomId.length();
    nSize += m_memberList.size() * 4;
    for(uint32_t i = 0; i < m_memberList.size(); i++)
    {
        nSize += m_memberList[i].length();
    }
    nSize += m_retmsg.length();
    return nSize;
}

class CMpcsReqExitroom : public CPackData
{
public:
    CMpcsReqExitroom()
    {
    }

    ~CMpcsReqExitroom() { }
    CMpcsReqExitroom(const string&  strRoomId)
    {
        m_roomId = strRoomId;
    }
    CMpcsReqExitroom&  operator=( const CMpcsReqExitroom&  cMpcsReqExitroom )
    {
        m_roomId = cMpcsReqExitroom.m_roomId;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
private:
    string m_roomId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqExitroom::Size() const
{
    uint32_t nSize = 6;
    nSize += m_roomId.length();
    return nSize;
}

class CMpcsRspExitroom : public CPackData
{
public:
    CMpcsRspExitroom()
    {
    }

    ~CMpcsRspExitroom() { }
    CMpcsRspExitroom(const uint8_t&  chRetcode, const string&  strRoomId)
    {
        m_retcode = chRetcode;
        m_roomId = strRoomId;
    }
    CMpcsRspExitroom&  operator=( const CMpcsRspExitroom&  cMpcsRspExitroom )
    {
        m_retcode = cMpcsRspExitroom.m_retcode;
        m_roomId = cMpcsRspExitroom.m_roomId;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_roomId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspExitroom::Size() const
{
    uint32_t nSize = 8;
    nSize += m_roomId.length();
    return nSize;
}

class CMpcsReqGetroominfo : public CPackData
{
public:
    CMpcsReqGetroominfo()
    {
    }

    ~CMpcsReqGetroominfo() { }
    CMpcsReqGetroominfo(const string&  strRoomId, const int64_t&  llMsgTimes, const int64_t&  llMemberTimes)
    {
        m_roomId = strRoomId;
        m_msgTimes = llMsgTimes;
        m_memberTimes = llMemberTimes;
    }
    CMpcsReqGetroominfo&  operator=( const CMpcsReqGetroominfo&  cMpcsReqGetroominfo )
    {
        m_roomId = cMpcsReqGetroominfo.m_roomId;
        m_msgTimes = cMpcsReqGetroominfo.m_msgTimes;
        m_memberTimes = cMpcsReqGetroominfo.m_memberTimes;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const int64_t&  GetMsgTimes () const { return m_msgTimes; }
    bool SetMsgTimes ( const int64_t&  llMsgTimes )
    {
        m_msgTimes = llMsgTimes;
        return true;
    }
    const int64_t&  GetMemberTimes () const { return m_memberTimes; }
    bool SetMemberTimes ( const int64_t&  llMemberTimes )
    {
        m_memberTimes = llMemberTimes;
        return true;
    }
private:
    string m_roomId;
    int64_t m_msgTimes;
    int64_t m_memberTimes;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqGetroominfo::Size() const
{
    uint32_t nSize = 24;
    nSize += m_roomId.length();
    return nSize;
}

class CMpcsRspGetroominfo : public CPackData
{
public:
    CMpcsRspGetroominfo()
    {
    }

    ~CMpcsRspGetroominfo() { }
    CMpcsRspGetroominfo(const uint8_t&  chRetcode, const string&  strRoomId, const SRoomInfo&  sInfo)
    {
        m_retcode = chRetcode;
        m_roomId = strRoomId;
        m_info = sInfo;
    }
    CMpcsRspGetroominfo&  operator=( const CMpcsRspGetroominfo&  cMpcsRspGetroominfo )
    {
        m_retcode = cMpcsRspGetroominfo.m_retcode;
        m_roomId = cMpcsRspGetroominfo.m_roomId;
        m_info = cMpcsRspGetroominfo.m_info;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const SRoomInfo&  GetInfo () const { return m_info; }
    bool SetInfo ( const SRoomInfo&  sInfo )
    {
        m_info = sInfo;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_roomId;
    SRoomInfo m_info;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspGetroominfo::Size() const
{
    uint32_t nSize = 9;
    nSize += m_roomId.length();
    nSize += m_info.Size();
    return nSize;
}

class CMpcsReqSendMsg : public CPackData
{
public:
    CMpcsReqSendMsg() : m_targetId("")
    {
    }

    ~CMpcsReqSendMsg() { }
    CMpcsReqSendMsg(const string&  strRoomId, const uint8_t&  chMsgType, const string &  strMessage, const string&  strTargetId, const int64_t&  llMsgId)
    {
        m_roomId = strRoomId;
        m_msgType = chMsgType;
        m_message = strMessage;
        m_targetId = strTargetId;
        m_msgId = llMsgId;
    }
    CMpcsReqSendMsg&  operator=( const CMpcsReqSendMsg&  cMpcsReqSendMsg )
    {
        m_roomId = cMpcsReqSendMsg.m_roomId;
        m_msgType = cMpcsReqSendMsg.m_msgType;
        m_message = cMpcsReqSendMsg.m_message;
        m_targetId = cMpcsReqSendMsg.m_targetId;
        m_msgId = cMpcsReqSendMsg.m_msgId;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const uint8_t&  GetMsgType () const { return m_msgType; }
    bool SetMsgType ( const uint8_t&  chMsgType )
    {
        m_msgType = chMsgType;
        return true;
    }
    const string &  GetMessage () const { return m_message; }
    bool SetMessage ( const string &  strMessage )
    {
        m_message = strMessage;
        return true;
    }
    const string&  GetTargetId () const { return m_targetId; }
    bool SetTargetId ( const string&  strTargetId )
    {
        m_targetId = strTargetId;
        return true;
    }
    const int64_t&  GetMsgId () const { return m_msgId; }
    bool SetMsgId ( const int64_t&  llMsgId )
    {
        m_msgId = llMsgId;
        return true;
    }
private:
    string m_roomId;
    uint8_t m_msgType;
    string  m_message;
    string m_targetId;
    int64_t m_msgId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqSendMsg::Size() const
{
    uint32_t nSize = 27;
    nSize += m_roomId.length();
    nSize += m_message.length();
    nSize += m_targetId.length();
    return nSize;
}

class CMpcsRspSendMsg : public CPackData
{
public:
    CMpcsRspSendMsg() : m_msgTimes(0)
    {
    }

    ~CMpcsRspSendMsg() { }
    CMpcsRspSendMsg(const uint8_t&  chRetcode, const string&  strRoomId, const int64_t&  llSendTime, const int64_t&  llMsgTimes= 0)
    {
        m_retcode = chRetcode;
        m_roomId = strRoomId;
        m_sendTime = llSendTime;
        m_msgTimes = llMsgTimes;
    }
    CMpcsRspSendMsg&  operator=( const CMpcsRspSendMsg&  cMpcsRspSendMsg )
    {
        m_retcode = cMpcsRspSendMsg.m_retcode;
        m_roomId = cMpcsRspSendMsg.m_roomId;
        m_sendTime = cMpcsRspSendMsg.m_sendTime;
        m_msgTimes = cMpcsRspSendMsg.m_msgTimes;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const int64_t&  GetSendTime () const { return m_sendTime; }
    bool SetSendTime ( const int64_t&  llSendTime )
    {
        m_sendTime = llSendTime;
        return true;
    }
    const int64_t&  GetMsgTimes () const { return m_msgTimes; }
    bool SetMsgTimes ( const int64_t&  llMsgTimes )
    {
        m_msgTimes = llMsgTimes;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_roomId;
    int64_t m_sendTime;
    int64_t m_msgTimes;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspSendMsg::Size() const
{
    uint32_t nSize = 26;
    nSize += m_roomId.length();
    return nSize;
}

class CMpcsNtfMessage : public CPackData
{
public:
    CMpcsNtfMessage()
    {
    }

    ~CMpcsNtfMessage() { }
    CMpcsNtfMessage(const string&  strRoomId, const string&  strFromId, const uint8_t&  chMsgType)
    {
        m_roomId = strRoomId;
        m_fromId = strFromId;
        m_msgType = chMsgType;
    }
    CMpcsNtfMessage&  operator=( const CMpcsNtfMessage&  cMpcsNtfMessage )
    {
        m_roomId = cMpcsNtfMessage.m_roomId;
        m_fromId = cMpcsNtfMessage.m_fromId;
        m_msgType = cMpcsNtfMessage.m_msgType;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const string&  GetFromId () const { return m_fromId; }
    bool SetFromId ( const string&  strFromId )
    {
        m_fromId = strFromId;
        return true;
    }
    const uint8_t&  GetMsgType () const { return m_msgType; }
    bool SetMsgType ( const uint8_t&  chMsgType )
    {
        m_msgType = chMsgType;
        return true;
    }
private:
    string m_roomId;
    string m_fromId;
    uint8_t m_msgType;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsNtfMessage::Size() const
{
    uint32_t nSize = 13;
    nSize += m_roomId.length();
    nSize += m_fromId.length();
    return nSize;
}

class CMpcsNtfUsersts : public CPackData
{
public:
    CMpcsNtfUsersts()
    {
    }

    ~CMpcsNtfUsersts() { }
    CMpcsNtfUsersts(const string&  strRoomId, const string&  strFromId, const string&  strNickName, const string&  strInviter, const uint8_t&  chType, const int64_t&  llMemberTimes, const string&  strRemark)
    {
        m_roomId = strRoomId;
        m_fromId = strFromId;
        m_nickName = strNickName;
        m_inviter = strInviter;
        m_type = chType;
        m_memberTimes = llMemberTimes;
        m_remark = strRemark;
    }
    CMpcsNtfUsersts&  operator=( const CMpcsNtfUsersts&  cMpcsNtfUsersts )
    {
        m_roomId = cMpcsNtfUsersts.m_roomId;
        m_fromId = cMpcsNtfUsersts.m_fromId;
        m_nickName = cMpcsNtfUsersts.m_nickName;
        m_inviter = cMpcsNtfUsersts.m_inviter;
        m_type = cMpcsNtfUsersts.m_type;
        m_memberTimes = cMpcsNtfUsersts.m_memberTimes;
        m_remark = cMpcsNtfUsersts.m_remark;
        return *this;
    }

    const string&  GetRoomId () const { return m_roomId; }
    bool SetRoomId ( const string&  strRoomId )
    {
        m_roomId = strRoomId;
        return true;
    }
    const string&  GetFromId () const { return m_fromId; }
    bool SetFromId ( const string&  strFromId )
    {
        m_fromId = strFromId;
        return true;
    }
    const string&  GetNickName () const { return m_nickName; }
    bool SetNickName ( const string&  strNickName )
    {
        m_nickName = strNickName;
        return true;
    }
    const string&  GetInviter () const { return m_inviter; }
    bool SetInviter ( const string&  strInviter )
    {
        m_inviter = strInviter;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const int64_t&  GetMemberTimes () const { return m_memberTimes; }
    bool SetMemberTimes ( const int64_t&  llMemberTimes )
    {
        m_memberTimes = llMemberTimes;
        return true;
    }
    const string&  GetRemark () const { return m_remark; }
    bool SetRemark ( const string&  strRemark )
    {
        m_remark = strRemark;
        return true;
    }
private:
    string m_roomId;
    string m_fromId;
    string m_nickName;
    string m_inviter;
    uint8_t m_type;
    int64_t m_memberTimes;
    string m_remark;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsNtfUsersts::Size() const
{
    uint32_t nSize = 37;
    nSize += m_roomId.length();
    nSize += m_fromId.length();
    nSize += m_nickName.length();
    nSize += m_inviter.length();
    nSize += m_remark.length();
    return nSize;
}

class CMpcsReqOffmsgCount : public CPackData
{
public:
    CMpcsReqOffmsgCount()
    {
    }

    ~CMpcsReqOffmsgCount() { }
    CMpcsReqOffmsgCount(const vector< SMpcsOffmsgTimes >&  vecRoomList)
    {
        m_roomList = vecRoomList;
    }
    CMpcsReqOffmsgCount&  operator=( const CMpcsReqOffmsgCount&  cMpcsReqOffmsgCount )
    {
        m_roomList = cMpcsReqOffmsgCount.m_roomList;
        return *this;
    }

    const vector< SMpcsOffmsgTimes >&  GetRoomList () const { return m_roomList; }
    bool SetRoomList ( const vector< SMpcsOffmsgTimes >&  vecRoomList )
    {
        m_roomList = vecRoomList;
        return true;
    }
private:
    vector< SMpcsOffmsgTimes > m_roomList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqOffmsgCount::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_roomList.size(); i++)
    {
        nSize += m_roomList[i].Size();
    }
    return nSize;
}

class CMpcsRspOffmsgCount : public CPackData
{
public:
    CMpcsRspOffmsgCount()
    {
    }

    ~CMpcsRspOffmsgCount() { }
    CMpcsRspOffmsgCount(const vector< SMpcsOffmsgCount >&  vecOffmsgCounts)
    {
        m_offmsgCounts = vecOffmsgCounts;
    }
    CMpcsRspOffmsgCount&  operator=( const CMpcsRspOffmsgCount&  cMpcsRspOffmsgCount )
    {
        m_offmsgCounts = cMpcsRspOffmsgCount.m_offmsgCounts;
        return *this;
    }

    const vector< SMpcsOffmsgCount >&  GetOffmsgCounts () const { return m_offmsgCounts; }
    bool SetOffmsgCounts ( const vector< SMpcsOffmsgCount >&  vecOffmsgCounts )
    {
        m_offmsgCounts = vecOffmsgCounts;
        return true;
    }
private:
    vector< SMpcsOffmsgCount > m_offmsgCounts;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspOffmsgCount::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_offmsgCounts.size(); i++)
    {
        nSize += m_offmsgCounts[i].Size();
    }
    return nSize;
}

class CMpcsReqRoomidlist : public CPackData
{
public:
    ~CMpcsReqRoomidlist() { }
public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsReqRoomidlist::Size() const
{
    return 1;
}
class CMpcsRspRoomidlist : public CPackData
{
public:
    CMpcsRspRoomidlist()
    {
    }

    ~CMpcsRspRoomidlist() { }
    CMpcsRspRoomidlist(const vector< string >&  vecRoomsId)
    {
        m_roomsId = vecRoomsId;
    }
    CMpcsRspRoomidlist&  operator=( const CMpcsRspRoomidlist&  cMpcsRspRoomidlist )
    {
        m_roomsId = cMpcsRspRoomidlist.m_roomsId;
        return *this;
    }

    const vector< string >&  GetRoomsId () const { return m_roomsId; }
    bool SetRoomsId ( const vector< string >&  vecRoomsId )
    {
        m_roomsId = vecRoomsId;
        return true;
    }
private:
    vector< string > m_roomsId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CMpcsRspRoomidlist::Size() const
{
    uint32_t nSize = 7;
    nSize += m_roomsId.size() * 4;
    for(uint32_t i = 0; i < m_roomsId.size(); i++)
    {
        nSize += m_roomsId[i].length();
    }
    return nSize;
}

#endif
