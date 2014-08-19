/*---------------------------------------------------------------------------
// Filename:        mimsc_pack.h
// Date:            2013-12-12 16:02:24
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//                  created by muhua
//---------------------------------------------------------------------------*/
#ifndef __MIMSC_PACK_H__
#define __MIMSC_PACK_H__

#include <string>
#include <vector>
#include <map>
#include "packdata.h"
#include "mconst_macro.h"
#include "mimsc_cmd.h"
#include "mimsc_enum.h"

using namespace std;

#ifndef STATUSDEF_LENGTH
#define STATUSDEF_LENGTH 64
#endif 

class CImReqOfflinemsg : public CPackData
{
public:
    CImReqOfflinemsg()
    {
    }

    ~CImReqOfflinemsg() { }
    CImReqOfflinemsg(const string&  strOperation, const string&  strReqData)
    {
        m_operation = strOperation;
        m_reqData = strReqData;
    }
    CImReqOfflinemsg&  operator=( const CImReqOfflinemsg&  cImReqOfflinemsg )
    {
        m_operation = cImReqOfflinemsg.m_operation;
        m_reqData = cImReqOfflinemsg.m_reqData;
        return *this;
    }

    const string&  GetOperation () const { return m_operation; }
    bool SetOperation ( const string&  strOperation )
    {
        m_operation = strOperation;
        return true;
    }
    const string&  GetReqData () const { return m_reqData; }
    bool SetReqData ( const string&  strReqData )
    {
        m_reqData = strReqData;
        return true;
    }
private:
    string m_operation;
    string m_reqData;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqOfflinemsg::Size() const
{
    uint32_t nSize = 11;
    nSize += m_operation.length();
    nSize += m_reqData.length();
    return nSize;
}

class CImRspOfflinemsg : public CPackData
{
public:
    CImRspOfflinemsg()
    {
    }

    ~CImRspOfflinemsg() { }
    CImRspOfflinemsg(const uint32_t&  dwRetcode, const string&  strOperations, const string&  strRspData)
    {
        m_retcode = dwRetcode;
        m_operations = strOperations;
        m_rspData = strRspData;
    }
    CImRspOfflinemsg&  operator=( const CImRspOfflinemsg&  cImRspOfflinemsg )
    {
        m_retcode = cImRspOfflinemsg.m_retcode;
        m_operations = cImRspOfflinemsg.m_operations;
        m_rspData = cImRspOfflinemsg.m_rspData;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetOperations () const { return m_operations; }
    bool SetOperations ( const string&  strOperations )
    {
        m_operations = strOperations;
        return true;
    }
    const string&  GetRspData () const { return m_rspData; }
    bool SetRspData ( const string&  strRspData )
    {
        m_rspData = strRspData;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_operations;
    string m_rspData;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspOfflinemsg::Size() const
{
    uint32_t nSize = 16;
    nSize += m_operations.length();
    nSize += m_rspData.length();
    return nSize;
}

class CImHelthCheck : public CPackData
{
public:
    ~CImHelthCheck() { }
public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImHelthCheck::Size() const
{
    return 1;
}
class CImReqCheckversion : public CPackData
{
public:
    CImReqCheckversion()
    {
    }

    ~CImReqCheckversion() { }
    CImReqCheckversion(const string&  strVersion)
    {
        m_version = strVersion;
    }
    CImReqCheckversion&  operator=( const CImReqCheckversion&  cImReqCheckversion )
    {
        m_version = cImReqCheckversion.m_version;
        return *this;
    }

    const string&  GetVersion () const { return m_version; }
    bool SetVersion ( const string&  strVersion )
    {
        if(strVersion.size() > 128) return false;
        m_version = strVersion;
        return true;
    }
private:
    string m_version;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqCheckversion::Size() const
{
    uint32_t nSize = 6;
    nSize += m_version.length();
    return nSize;
}

class CImRspCheckversion : public CPackData
{
public:
    CImRspCheckversion()
    {
    }

    ~CImRspCheckversion() { }
    CImRspCheckversion(const uint32_t&  dwRetcode, const string&  strRemark, const string &  strPubkey)
    {
        m_retcode = dwRetcode;
        m_remark = strRemark;
        m_pubkey = strPubkey;
    }
    CImRspCheckversion&  operator=( const CImRspCheckversion&  cImRspCheckversion )
    {
        m_retcode = cImRspCheckversion.m_retcode;
        m_remark = cImRspCheckversion.m_remark;
        m_pubkey = cImRspCheckversion.m_pubkey;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetRemark () const { return m_remark; }
    bool SetRemark ( const string&  strRemark )
    {
        if(strRemark.size() > 256) return false;
        m_remark = strRemark;
        return true;
    }
    const string &  GetPubkey () const { return m_pubkey; }
    bool SetPubkey ( const string &  strPubkey )
    {
        m_pubkey = strPubkey;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_remark;
    string  m_pubkey;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspCheckversion::Size() const
{
    uint32_t nSize = 16;
    nSize += m_remark.length();
    nSize += m_pubkey.length();
    return nSize;
}

class CImReqGetToken : public CPackData
{
public:
    CImReqGetToken()
    {
    }

    ~CImReqGetToken() { }
    CImReqGetToken(const uint8_t&  chType, const string&  strClientusedata)
    {
        m_type = chType;
        m_clientusedata = strClientusedata;
    }
    CImReqGetToken&  operator=( const CImReqGetToken&  cImReqGetToken )
    {
        m_type = cImReqGetToken.m_type;
        m_clientusedata = cImReqGetToken.m_clientusedata;
        return *this;
    }

    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const string&  GetClientusedata () const { return m_clientusedata; }
    bool SetClientusedata ( const string&  strClientusedata )
    {
        m_clientusedata = strClientusedata;
        return true;
    }
private:
    uint8_t m_type;
    string m_clientusedata;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqGetToken::Size() const
{
    uint32_t nSize = 8;
    nSize += m_clientusedata.length();
    return nSize;
}

class CImRspGetToken : public CPackData
{
public:
    CImRspGetToken()
    {
    }

    ~CImRspGetToken() { }
    CImRspGetToken(const uint32_t&  dwRetcode, const uint8_t&  chType, const string&  strToken, const string&  strClientusedata)
    {
        m_retcode = dwRetcode;
        m_type = chType;
        m_token = strToken;
        m_clientusedata = strClientusedata;
    }
    CImRspGetToken&  operator=( const CImRspGetToken&  cImRspGetToken )
    {
        m_retcode = cImRspGetToken.m_retcode;
        m_type = cImRspGetToken.m_type;
        m_token = cImRspGetToken.m_token;
        m_clientusedata = cImRspGetToken.m_clientusedata;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const string&  GetToken () const { return m_token; }
    bool SetToken ( const string&  strToken )
    {
        m_token = strToken;
        return true;
    }
    const string&  GetClientusedata () const { return m_clientusedata; }
    bool SetClientusedata ( const string&  strClientusedata )
    {
        m_clientusedata = strClientusedata;
        return true;
    }
private:
    uint32_t m_retcode;
    uint8_t m_type;
    string m_token;
    string m_clientusedata;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspGetToken::Size() const
{
    uint32_t nSize = 18;
    nSize += m_token.length();
    nSize += m_clientusedata.length();
    return nSize;
}

class CImReqMls : public CPackData
{
public:
    CImReqMls()
    {
    }

    ~CImReqMls() { }
    CImReqMls(const uint32_t&  dwMsgtype, const string &  strMsg)
    {
        m_msgtype = dwMsgtype;
        m_msg = strMsg;
    }
    CImReqMls&  operator=( const CImReqMls&  cImReqMls )
    {
        m_msgtype = cImReqMls.m_msgtype;
        m_msg = cImReqMls.m_msg;
        return *this;
    }

    const uint32_t&  GetMsgtype () const { return m_msgtype; }
    bool SetMsgtype ( const uint32_t&  dwMsgtype )
    {
        m_msgtype = dwMsgtype;
        return true;
    }
    const string &  GetMsg () const { return m_msg; }
    bool SetMsg ( const string &  strMsg )
    {
        m_msg = strMsg;
        return true;
    }
private:
    uint32_t m_msgtype;
    string  m_msg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqMls::Size() const
{
    uint32_t nSize = 11;
    nSize += m_msg.length();
    return nSize;
}

class CImRspMls : public CPackData
{
public:
    CImRspMls()
    {
    }

    ~CImRspMls() { }
    CImRspMls(const uint32_t&  dwRetcode, const uint32_t&  dwMsgtype, const string &  strMsg)
    {
        m_retcode = dwRetcode;
        m_msgtype = dwMsgtype;
        m_msg = strMsg;
    }
    CImRspMls&  operator=( const CImRspMls&  cImRspMls )
    {
        m_retcode = cImRspMls.m_retcode;
        m_msgtype = cImRspMls.m_msgtype;
        m_msg = cImRspMls.m_msg;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const uint32_t&  GetMsgtype () const { return m_msgtype; }
    bool SetMsgtype ( const uint32_t&  dwMsgtype )
    {
        m_msgtype = dwMsgtype;
        return true;
    }
    const string &  GetMsg () const { return m_msg; }
    bool SetMsg ( const string &  strMsg )
    {
        m_msg = strMsg;
        return true;
    }
private:
    uint32_t m_retcode;
    uint32_t m_msgtype;
    string  m_msg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspMls::Size() const
{
    uint32_t nSize = 16;
    nSize += m_msg.length();
    return nSize;
}

struct SClientHello
{
public:
    SClientHello()
    {
    }

    ~SClientHello() { }
    SClientHello(const string&  strProtocolVersion)
    {
        m_protocolVersion = strProtocolVersion;
    }
    SClientHello&  operator=( const SClientHello&  sClientHello )
    {
        m_protocolVersion = sClientHello.m_protocolVersion;
        return *this;
    }

    string m_protocolVersion;

public:
    uint32_t Size() const;
};

inline uint32_t SClientHello::Size() const
{
    uint32_t nSize = 6;
    nSize += m_protocolVersion.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SClientHello&  sClientHello );
CPackData& operator>> ( CPackData& cPackData, SClientHello&  sClientHello );

struct SInputstatus
{
public:
    SInputstatus()
    {
    }

    ~SInputstatus() { }
    SInputstatus(const uint8_t&  chInputStatus)
    {
        m_inputStatus = chInputStatus;
    }
    SInputstatus&  operator=( const SInputstatus&  sInputstatus )
    {
        m_inputStatus = sInputstatus.m_inputStatus;
        return *this;
    }

    uint8_t m_inputStatus;

public:
    uint32_t Size() const;
};

inline uint32_t SInputstatus::Size() const
{
    return 3;
}
CPackData& operator<< ( CPackData& cPackData, const SInputstatus&  sInputstatus );
CPackData& operator>> ( CPackData& cPackData, SInputstatus&  sInputstatus );

struct SServerHello
{
public:
    SServerHello()
    {
    }

    ~SServerHello() { }
    SServerHello(const string&  strProtocolVersion, const string &  strPubKey)
    {
        m_protocolVersion = strProtocolVersion;
        m_pubKey = strPubKey;
    }
    SServerHello&  operator=( const SServerHello&  sServerHello )
    {
        m_protocolVersion = sServerHello.m_protocolVersion;
        m_pubKey = sServerHello.m_pubKey;
        return *this;
    }

    string m_protocolVersion;
    string  m_pubKey;

public:
    uint32_t Size() const;
};

inline uint32_t SServerHello::Size() const
{
    uint32_t nSize = 11;
    nSize += m_protocolVersion.length();
    nSize += m_pubKey.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SServerHello&  sServerHello );
CPackData& operator>> ( CPackData& cPackData, SServerHello&  sServerHello );

struct SClientKeyExchange
{
public:
    SClientKeyExchange()
    {
    }

    ~SClientKeyExchange() { }
    SClientKeyExchange(const string &  strPreMasterKey)
    {
        m_preMasterKey = strPreMasterKey;
    }
    SClientKeyExchange&  operator=( const SClientKeyExchange&  sClientKeyExchange )
    {
        m_preMasterKey = sClientKeyExchange.m_preMasterKey;
        return *this;
    }

    string  m_preMasterKey;

public:
    uint32_t Size() const;
};

inline uint32_t SClientKeyExchange::Size() const
{
    uint32_t nSize = 6;
    nSize += m_preMasterKey.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SClientKeyExchange&  sClientKeyExchange );
CPackData& operator>> ( CPackData& cPackData, SClientKeyExchange&  sClientKeyExchange );

struct SServerKeyExchange
{
public:
    SServerKeyExchange()
    {
    }

    ~SServerKeyExchange() { }
    SServerKeyExchange(const string &  strMasterKey)
    {
        m_masterKey = strMasterKey;
    }
    SServerKeyExchange&  operator=( const SServerKeyExchange&  sServerKeyExchange )
    {
        m_masterKey = sServerKeyExchange.m_masterKey;
        return *this;
    }

    string  m_masterKey;

public:
    uint32_t Size() const;
};

inline uint32_t SServerKeyExchange::Size() const
{
    uint32_t nSize = 6;
    nSize += m_masterKey.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SServerKeyExchange&  sServerKeyExchange );
CPackData& operator>> ( CPackData& cPackData, SServerKeyExchange&  sServerKeyExchange );

struct SCardMsg
{
public:
    SCardMsg()
    {
    }

    ~SCardMsg() { }
    SCardMsg(const string&  strCardId, const string&  strMessage, const string&  strHeadUrl, const string&  strAudioUrl, const uint32_t&  dwAudioTime, const string&  strImageUrl)
    {
        m_cardId = strCardId;
        m_message = strMessage;
        m_headUrl = strHeadUrl;
        m_audioUrl = strAudioUrl;
        m_audioTime = dwAudioTime;
        m_imageUrl = strImageUrl;
    }
    SCardMsg&  operator=( const SCardMsg&  sCardMsg )
    {
        m_cardId = sCardMsg.m_cardId;
        m_message = sCardMsg.m_message;
        m_headUrl = sCardMsg.m_headUrl;
        m_audioUrl = sCardMsg.m_audioUrl;
        m_audioTime = sCardMsg.m_audioTime;
        m_imageUrl = sCardMsg.m_imageUrl;
        return *this;
    }

    string m_cardId;
    string m_message;
    string m_headUrl;
    string m_audioUrl;
    uint32_t m_audioTime;
    string m_imageUrl;

public:
    uint32_t Size() const;
};

inline uint32_t SCardMsg::Size() const
{
    uint32_t nSize = 31;
    nSize += m_cardId.length();
    nSize += m_message.length();
    nSize += m_headUrl.length();
    nSize += m_audioUrl.length();
    nSize += m_imageUrl.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SCardMsg&  sCardMsg );
CPackData& operator>> ( CPackData& cPackData, SCardMsg&  sCardMsg );

class CImReqLogin : public CPackData
{
public:
    CImReqLogin() : m_longitude(0),
            m_latitude(0),
            m_authcodeurl(""),
            m_appId(0),
            m_extradata("")
    {
    }

    ~CImReqLogin() { }
    CImReqLogin(const uint8_t&  chTokenFlag, const string&  strPassword, const string&  strVersion, const uint32_t&  dwLanguage, const string&  strAuthcode, const string&  strDeviceid, const uint8_t&  chDevtype, const string&  strDevver, const double&  dLongitude= 0, const double&  dLatitude= 0, const string&  strAuthcodeurl= "", const uint32_t&  dwAppId= 0, const string&  strExtradata= "")
    {
        m_tokenFlag = chTokenFlag;
        m_password = strPassword;
        m_version = strVersion;
        m_language = dwLanguage;
        m_authcode = strAuthcode;
        m_deviceid = strDeviceid;
        m_devtype = chDevtype;
        m_devver = strDevver;
        m_longitude = dLongitude;
        m_latitude = dLatitude;
        m_authcodeurl = strAuthcodeurl;
        m_appId = dwAppId;
        m_extradata = strExtradata;
    }
    CImReqLogin&  operator=( const CImReqLogin&  cImReqLogin )
    {
        m_tokenFlag = cImReqLogin.m_tokenFlag;
        m_password = cImReqLogin.m_password;
        m_version = cImReqLogin.m_version;
        m_language = cImReqLogin.m_language;
        m_authcode = cImReqLogin.m_authcode;
        m_deviceid = cImReqLogin.m_deviceid;
        m_devtype = cImReqLogin.m_devtype;
        m_devver = cImReqLogin.m_devver;
        m_longitude = cImReqLogin.m_longitude;
        m_latitude = cImReqLogin.m_latitude;
        m_authcodeurl = cImReqLogin.m_authcodeurl;
        m_appId = cImReqLogin.m_appId;
        m_extradata = cImReqLogin.m_extradata;
        return *this;
    }

    const uint8_t&  GetTokenFlag () const { return m_tokenFlag; }
    bool SetTokenFlag ( const uint8_t&  chTokenFlag )
    {
        m_tokenFlag = chTokenFlag;
        return true;
    }
    const string&  GetPassword () const { return m_password; }
    bool SetPassword ( const string&  strPassword )
    {
        if(strPassword.size() > 48) return false;
        m_password = strPassword;
        return true;
    }
    const string&  GetVersion () const { return m_version; }
    bool SetVersion ( const string&  strVersion )
    {
        if(strVersion.size() > 128) return false;
        m_version = strVersion;
        return true;
    }
    const uint32_t&  GetLanguage () const { return m_language; }
    bool SetLanguage ( const uint32_t&  dwLanguage )
    {
        m_language = dwLanguage;
        return true;
    }
    const string&  GetAuthcode () const { return m_authcode; }
    bool SetAuthcode ( const string&  strAuthcode )
    {
        m_authcode = strAuthcode;
        return true;
    }
    const string&  GetDeviceid () const { return m_deviceid; }
    bool SetDeviceid ( const string&  strDeviceid )
    {
        m_deviceid = strDeviceid;
        return true;
    }
    const uint8_t&  GetDevtype () const { return m_devtype; }
    bool SetDevtype ( const uint8_t&  chDevtype )
    {
        m_devtype = chDevtype;
        return true;
    }
    const string&  GetDevver () const { return m_devver; }
    bool SetDevver ( const string&  strDevver )
    {
        m_devver = strDevver;
        return true;
    }
    const double&  GetLongitude () const { return m_longitude; }
    bool SetLongitude ( const double&  dLongitude )
    {
        m_longitude = dLongitude;
        return true;
    }
    const double&  GetLatitude () const { return m_latitude; }
    bool SetLatitude ( const double&  dLatitude )
    {
        m_latitude = dLatitude;
        return true;
    }
    const string&  GetAuthcodeurl () const { return m_authcodeurl; }
    bool SetAuthcodeurl ( const string&  strAuthcodeurl )
    {
        m_authcodeurl = strAuthcodeurl;
        return true;
    }
    const uint32_t&  GetAppId () const { return m_appId; }
    bool SetAppId ( const uint32_t&  dwAppId )
    {
        m_appId = dwAppId;
        return true;
    }
    const string&  GetExtradata () const { return m_extradata; }
    bool SetExtradata ( const string&  strExtradata )
    {
        m_extradata = strExtradata;
        return true;
    }
private:
    uint8_t m_tokenFlag;
    string m_password;
    string m_version;
    uint32_t m_language;
    string m_authcode;
    string m_deviceid;
    uint8_t m_devtype;
    string m_devver;
    double m_longitude;
    double m_latitude;
    string m_authcodeurl;
    uint32_t m_appId;
    string m_extradata;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqLogin::Size() const
{
    uint32_t nSize = 68;
    nSize += m_password.length();
    nSize += m_version.length();
    nSize += m_authcode.length();
    nSize += m_deviceid.length();
    nSize += m_devver.length();
    nSize += m_authcodeurl.length();
    nSize += m_extradata.length();
    return nSize;
}

class CImRspLogin : public CPackData
{
public:
    CImRspLogin() : m_authcodeurl(""),
            m_sessionId("")
    {
    }

    ~CImRspLogin() { }
    CImRspLogin(const uint32_t&  dwRetcode, const uint32_t&  dwClientIp, const uint32_t&  dwServerTime, const string &  strWorkKey, const string&  strPwtoken, const string&  strRemark, const string&  strWebmd5pw, const uint32_t&  dwLastClientip, const string&  strBindid, const string&  strNewVersion, const string&  strNewVersionUrl, const string&  strVersionInfo, const string&  strUserId, const string&  strNickName, const string&  strAuthcodeurl= "", const string&  strSessionId= "")
    {
        m_retcode = dwRetcode;
        m_clientIp = dwClientIp;
        m_serverTime = dwServerTime;
        m_workKey = strWorkKey;
        m_pwtoken = strPwtoken;
        m_remark = strRemark;
        m_webmd5pw = strWebmd5pw;
        m_lastClientip = dwLastClientip;
        m_bindid = strBindid;
        m_newVersion = strNewVersion;
        m_newVersionUrl = strNewVersionUrl;
        m_versionInfo = strVersionInfo;
        m_userId = strUserId;
        m_nickName = strNickName;
        m_authcodeurl = strAuthcodeurl;
        m_sessionId = strSessionId;
    }
    CImRspLogin&  operator=( const CImRspLogin&  cImRspLogin )
    {
        m_retcode = cImRspLogin.m_retcode;
        m_clientIp = cImRspLogin.m_clientIp;
        m_serverTime = cImRspLogin.m_serverTime;
        m_workKey = cImRspLogin.m_workKey;
        m_pwtoken = cImRspLogin.m_pwtoken;
        m_remark = cImRspLogin.m_remark;
        m_webmd5pw = cImRspLogin.m_webmd5pw;
        m_lastClientip = cImRspLogin.m_lastClientip;
        m_bindid = cImRspLogin.m_bindid;
        m_newVersion = cImRspLogin.m_newVersion;
        m_newVersionUrl = cImRspLogin.m_newVersionUrl;
        m_versionInfo = cImRspLogin.m_versionInfo;
        m_userId = cImRspLogin.m_userId;
        m_nickName = cImRspLogin.m_nickName;
        m_authcodeurl = cImRspLogin.m_authcodeurl;
        m_sessionId = cImRspLogin.m_sessionId;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const uint32_t&  GetClientIp () const { return m_clientIp; }
    bool SetClientIp ( const uint32_t&  dwClientIp )
    {
        m_clientIp = dwClientIp;
        return true;
    }
    const uint32_t&  GetServerTime () const { return m_serverTime; }
    bool SetServerTime ( const uint32_t&  dwServerTime )
    {
        m_serverTime = dwServerTime;
        return true;
    }
    const string &  GetWorkKey () const { return m_workKey; }
    bool SetWorkKey ( const string &  strWorkKey )
    {
        m_workKey = strWorkKey;
        return true;
    }
    const string&  GetPwtoken () const { return m_pwtoken; }
    bool SetPwtoken ( const string&  strPwtoken )
    {
        m_pwtoken = strPwtoken;
        return true;
    }
    const string&  GetRemark () const { return m_remark; }
    bool SetRemark ( const string&  strRemark )
    {
        if(strRemark.size() > 2048) return false;
        m_remark = strRemark;
        return true;
    }
    const string&  GetWebmd5pw () const { return m_webmd5pw; }
    bool SetWebmd5pw ( const string&  strWebmd5pw )
    {
        m_webmd5pw = strWebmd5pw;
        return true;
    }
    const uint32_t&  GetLastClientip () const { return m_lastClientip; }
    bool SetLastClientip ( const uint32_t&  dwLastClientip )
    {
        m_lastClientip = dwLastClientip;
        return true;
    }
    const string&  GetBindid () const { return m_bindid; }
    bool SetBindid ( const string&  strBindid )
    {
        m_bindid = strBindid;
        return true;
    }
    const string&  GetNewVersion () const { return m_newVersion; }
    bool SetNewVersion ( const string&  strNewVersion )
    {
        m_newVersion = strNewVersion;
        return true;
    }
    const string&  GetNewVersionUrl () const { return m_newVersionUrl; }
    bool SetNewVersionUrl ( const string&  strNewVersionUrl )
    {
        m_newVersionUrl = strNewVersionUrl;
        return true;
    }
    const string&  GetVersionInfo () const { return m_versionInfo; }
    bool SetVersionInfo ( const string&  strVersionInfo )
    {
        m_versionInfo = strVersionInfo;
        return true;
    }
    const string&  GetUserId () const { return m_userId; }
    bool SetUserId ( const string&  strUserId )
    {
        m_userId = strUserId;
        return true;
    }
    const string&  GetNickName () const { return m_nickName; }
    bool SetNickName ( const string&  strNickName )
    {
        m_nickName = strNickName;
        return true;
    }
    const string&  GetAuthcodeurl () const { return m_authcodeurl; }
    bool SetAuthcodeurl ( const string&  strAuthcodeurl )
    {
        m_authcodeurl = strAuthcodeurl;
        return true;
    }
    const string&  GetSessionId () const { return m_sessionId; }
    bool SetSessionId ( const string&  strSessionId )
    {
        m_sessionId = strSessionId;
        return true;
    }
private:
    uint32_t m_retcode;
    uint32_t m_clientIp;
    uint32_t m_serverTime;
    string  m_workKey;
    string m_pwtoken;
    string m_remark;
    string m_webmd5pw;
    uint32_t m_lastClientip;
    string m_bindid;
    string m_newVersion;
    string m_newVersionUrl;
    string m_versionInfo;
    string m_userId;
    string m_nickName;
    string m_authcodeurl;
    string m_sessionId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspLogin::Size() const
{
    uint32_t nSize = 81;
    nSize += m_workKey.length();
    nSize += m_pwtoken.length();
    nSize += m_remark.length();
    nSize += m_webmd5pw.length();
    nSize += m_bindid.length();
    nSize += m_newVersion.length();
    nSize += m_newVersionUrl.length();
    nSize += m_versionInfo.length();
    nSize += m_userId.length();
    nSize += m_nickName.length();
    nSize += m_authcodeurl.length();
    nSize += m_sessionId.length();
    return nSize;
}

struct SNotifyPluginAck
{
public:
    SNotifyPluginAck()
    {
    }

    ~SNotifyPluginAck() { }
    SNotifyPluginAck(const uint32_t&  dwPluginid, const string&  strItemid, const string&  strUid)
    {
        m_pluginid = dwPluginid;
        m_itemid = strItemid;
        m_uid = strUid;
    }
    SNotifyPluginAck&  operator=( const SNotifyPluginAck&  sNotifyPluginAck )
    {
        m_pluginid = sNotifyPluginAck.m_pluginid;
        m_itemid = sNotifyPluginAck.m_itemid;
        m_uid = sNotifyPluginAck.m_uid;
        return *this;
    }

    uint32_t m_pluginid;
    string m_itemid;
    string m_uid;

public:
    uint32_t Size() const;
};

inline uint32_t SNotifyPluginAck::Size() const
{
    uint32_t nSize = 16;
    nSize += m_itemid.length();
    nSize += m_uid.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SNotifyPluginAck&  sNotifyPluginAck );
CPackData& operator>> ( CPackData& cPackData, SNotifyPluginAck&  sNotifyPluginAck );

struct SMsgAck
{
public:
    SMsgAck() : m_ackResult(0)
    {
    }

    ~SMsgAck() { }
    SMsgAck(const uint8_t&  chType, const string &  strMessage, const uint8_t&  chAckResult= 0)
    {
        m_type = chType;
        m_message = strMessage;
        m_ackResult = chAckResult;
    }
    SMsgAck&  operator=( const SMsgAck&  sMsgAck )
    {
        m_type = sMsgAck.m_type;
        m_message = sMsgAck.m_message;
        m_ackResult = sMsgAck.m_ackResult;
        return *this;
    }

    uint8_t m_type;
    string  m_message;
    uint8_t m_ackResult;

public:
    uint32_t Size() const;
};

inline uint32_t SMsgAck::Size() const
{
    uint32_t nSize = 10;
    nSize += m_message.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SMsgAck&  sMsgAck );
CPackData& operator>> ( CPackData& cPackData, SMsgAck&  sMsgAck );

class CImReqLogoff : public CPackData
{
public:
    CImReqLogoff() : m_iscancle(0)
    {
    }

    ~CImReqLogoff() { }
    CImReqLogoff(const string&  strUid, const uint32_t&  dwIscancle= 0)
    {
        m_uid = strUid;
        m_iscancle = dwIscancle;
    }
    CImReqLogoff&  operator=( const CImReqLogoff&  cImReqLogoff )
    {
        m_uid = cImReqLogoff.m_uid;
        m_iscancle = cImReqLogoff.m_iscancle;
        return *this;
    }

    const string&  GetUid () const { return m_uid; }
    bool SetUid ( const string&  strUid )
    {
        m_uid = strUid;
        return true;
    }
    const uint32_t&  GetIscancle () const { return m_iscancle; }
    bool SetIscancle ( const uint32_t&  dwIscancle )
    {
        m_iscancle = dwIscancle;
        return true;
    }
private:
    string m_uid;
    uint32_t m_iscancle;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqLogoff::Size() const
{
    uint32_t nSize = 11;
    nSize += m_uid.length();
    return nSize;
}

class CImRspLogoff : public CPackData
{
public:
    CImRspLogoff()
    {
    }

    ~CImRspLogoff() { }
    CImRspLogoff(const uint32_t&  dwRetcode, const string&  strRemark)
    {
        m_retcode = dwRetcode;
        m_remark = strRemark;
    }
    CImRspLogoff&  operator=( const CImRspLogoff&  cImRspLogoff )
    {
        m_retcode = cImRspLogoff.m_retcode;
        m_remark = cImRspLogoff.m_remark;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetRemark () const { return m_remark; }
    bool SetRemark ( const string&  strRemark )
    {
        if(strRemark.size() > 256) return false;
        m_remark = strRemark;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_remark;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspLogoff::Size() const
{
    uint32_t nSize = 11;
    nSize += m_remark.length();
    return nSize;
}

class CImNtfForcedisconnect : public CPackData
{
public:
    CImNtfForcedisconnect()
    {
    }

    ~CImNtfForcedisconnect() { }
    CImNtfForcedisconnect(const uint8_t&  chType, const string&  strRemark, const string&  strIp, const string&  strUuid)
    {
        m_type = chType;
        m_remark = strRemark;
        m_ip = strIp;
        m_uuid = strUuid;
    }
    CImNtfForcedisconnect&  operator=( const CImNtfForcedisconnect&  cImNtfForcedisconnect )
    {
        m_type = cImNtfForcedisconnect.m_type;
        m_remark = cImNtfForcedisconnect.m_remark;
        m_ip = cImNtfForcedisconnect.m_ip;
        m_uuid = cImNtfForcedisconnect.m_uuid;
        return *this;
    }

    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const string&  GetRemark () const { return m_remark; }
    bool SetRemark ( const string&  strRemark )
    {
        if(strRemark.size() > 256) return false;
        m_remark = strRemark;
        return true;
    }
    const string&  GetIp () const { return m_ip; }
    bool SetIp ( const string&  strIp )
    {
        m_ip = strIp;
        return true;
    }
    const string&  GetUuid () const { return m_uuid; }
    bool SetUuid ( const string&  strUuid )
    {
        m_uuid = strUuid;
        return true;
    }
private:
    uint8_t m_type;
    string m_remark;
    string m_ip;
    string m_uuid;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfForcedisconnect::Size() const
{
    uint32_t nSize = 18;
    nSize += m_remark.length();
    nSize += m_ip.length();
    nSize += m_uuid.length();
    return nSize;
}

class CImReqSendimmessage : public CPackData
{
public:
    CImReqSendimmessage() : m_appId(0),
            m_devtype(0)
    {
    }

    ~CImReqSendimmessage() { }
    CImReqSendimmessage(const string&  strTargetId, const uint8_t&  chType, const uint8_t&  chMsgType, const int64_t&  llMsgId, const string&  strNickName, const string &  strMessage, const uint32_t&  dwAppId= 0, const uint8_t&  chDevtype= 0)
    {
        m_targetId = strTargetId;
        m_type = chType;
        m_msgType = chMsgType;
        m_msgId = llMsgId;
        m_nickName = strNickName;
        m_message = strMessage;
        m_appId = dwAppId;
        m_devtype = chDevtype;
    }
    CImReqSendimmessage&  operator=( const CImReqSendimmessage&  cImReqSendimmessage )
    {
        m_targetId = cImReqSendimmessage.m_targetId;
        m_type = cImReqSendimmessage.m_type;
        m_msgType = cImReqSendimmessage.m_msgType;
        m_msgId = cImReqSendimmessage.m_msgId;
        m_nickName = cImReqSendimmessage.m_nickName;
        m_message = cImReqSendimmessage.m_message;
        m_appId = cImReqSendimmessage.m_appId;
        m_devtype = cImReqSendimmessage.m_devtype;
        return *this;
    }

    const string&  GetTargetId () const { return m_targetId; }
    bool SetTargetId ( const string&  strTargetId )
    {
        if(strTargetId.size() > 64) return false;
        m_targetId = strTargetId;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const uint8_t&  GetMsgType () const { return m_msgType; }
    bool SetMsgType ( const uint8_t&  chMsgType )
    {
        m_msgType = chMsgType;
        return true;
    }
    const int64_t&  GetMsgId () const { return m_msgId; }
    bool SetMsgId ( const int64_t&  llMsgId )
    {
        m_msgId = llMsgId;
        return true;
    }
    const string&  GetNickName () const { return m_nickName; }
    bool SetNickName ( const string&  strNickName )
    {
        m_nickName = strNickName;
        return true;
    }
    const string &  GetMessage () const { return m_message; }
    bool SetMessage ( const string &  strMessage )
    {
        m_message = strMessage;
        return true;
    }
    const uint32_t&  GetAppId () const { return m_appId; }
    bool SetAppId ( const uint32_t&  dwAppId )
    {
        m_appId = dwAppId;
        return true;
    }
    const uint8_t&  GetDevtype () const { return m_devtype; }
    bool SetDevtype ( const uint8_t&  chDevtype )
    {
        m_devtype = chDevtype;
        return true;
    }
private:
    string m_targetId;
    uint8_t m_type;
    uint8_t m_msgType;
    int64_t m_msgId;
    string m_nickName;
    string  m_message;
    uint32_t m_appId;
    uint8_t m_devtype;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqSendimmessage::Size() const
{
    uint32_t nSize = 36;
    nSize += m_targetId.length();
    nSize += m_nickName.length();
    nSize += m_message.length();
    return nSize;
}

class CImRspSendimmessage : public CPackData
{
public:
    ~CImRspSendimmessage() { }
    CImRspSendimmessage(const uint32_t&  dwRetcode= 0, const string&  strRspdata= "")
    {
        m_retcode = dwRetcode;
        m_rspdata = strRspdata;
    }
    CImRspSendimmessage&  operator=( const CImRspSendimmessage&  cImRspSendimmessage )
    {
        m_retcode = cImRspSendimmessage.m_retcode;
        m_rspdata = cImRspSendimmessage.m_rspdata;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetRspdata () const { return m_rspdata; }
    bool SetRspdata ( const string&  strRspdata )
    {
        m_rspdata = strRspdata;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_rspdata;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspSendimmessage::Size() const
{
    uint32_t nSize = 11;
    nSize += m_rspdata.length();
    return nSize;
}

struct STypeStatus
{
public:
    STypeStatus()
    {
    }

    ~STypeStatus() { }
    STypeStatus(const uint8_t&  chType)
    {
        m_type = chType;
    }
    STypeStatus&  operator=( const STypeStatus&  sTypeStatus )
    {
        m_type = sTypeStatus.m_type;
        return *this;
    }

    uint8_t m_type;

public:
    uint32_t Size() const;
};

inline uint32_t STypeStatus::Size() const
{
    return 3;
}
CPackData& operator<< ( CPackData& cPackData, const STypeStatus&  sTypeStatus );
CPackData& operator>> ( CPackData& cPackData, STypeStatus&  sTypeStatus );

struct SMsgStatus
{
public:
    SMsgStatus()
    {
    }

    ~SMsgStatus() { }
    SMsgStatus(const uint32_t&  dwStatus)
    {
        m_status = dwStatus;
    }
    SMsgStatus&  operator=( const SMsgStatus&  sMsgStatus )
    {
        m_status = sMsgStatus.m_status;
        return *this;
    }

    uint32_t m_status;

public:
    uint32_t Size() const;
};

inline uint32_t SMsgStatus::Size() const
{
    return 6;
}
CPackData& operator<< ( CPackData& cPackData, const SMsgStatus&  sMsgStatus );
CPackData& operator>> ( CPackData& cPackData, SMsgStatus&  sMsgStatus );

class CImReqSendmulimmessage : public CPackData
{
public:
    CImReqSendmulimmessage() : m_appId(0),
            m_devtype(0)
    {
    }

    ~CImReqSendmulimmessage() { }
    CImReqSendmulimmessage(const vector< string >&  vecTargetidList, const uint8_t&  chType, const uint8_t&  chMsgType, const int64_t&  llMsgId, const string&  strNickName, const string &  strMessage, const uint32_t&  dwAppId= 0, const uint8_t&  chDevtype= 0)
    {
        m_targetidList = vecTargetidList;
        m_type = chType;
        m_msgType = chMsgType;
        m_msgId = llMsgId;
        m_nickName = strNickName;
        m_message = strMessage;
        m_appId = dwAppId;
        m_devtype = chDevtype;
    }
    CImReqSendmulimmessage&  operator=( const CImReqSendmulimmessage&  cImReqSendmulimmessage )
    {
        m_targetidList = cImReqSendmulimmessage.m_targetidList;
        m_type = cImReqSendmulimmessage.m_type;
        m_msgType = cImReqSendmulimmessage.m_msgType;
        m_msgId = cImReqSendmulimmessage.m_msgId;
        m_nickName = cImReqSendmulimmessage.m_nickName;
        m_message = cImReqSendmulimmessage.m_message;
        m_appId = cImReqSendmulimmessage.m_appId;
        m_devtype = cImReqSendmulimmessage.m_devtype;
        return *this;
    }

    const vector< string >&  GetTargetidList () const { return m_targetidList; }
    bool SetTargetidList ( const vector< string >&  vecTargetidList )
    {
        m_targetidList = vecTargetidList;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const uint8_t&  GetMsgType () const { return m_msgType; }
    bool SetMsgType ( const uint8_t&  chMsgType )
    {
        m_msgType = chMsgType;
        return true;
    }
    const int64_t&  GetMsgId () const { return m_msgId; }
    bool SetMsgId ( const int64_t&  llMsgId )
    {
        m_msgId = llMsgId;
        return true;
    }
    const string&  GetNickName () const { return m_nickName; }
    bool SetNickName ( const string&  strNickName )
    {
        m_nickName = strNickName;
        return true;
    }
    const string &  GetMessage () const { return m_message; }
    bool SetMessage ( const string &  strMessage )
    {
        m_message = strMessage;
        return true;
    }
    const uint32_t&  GetAppId () const { return m_appId; }
    bool SetAppId ( const uint32_t&  dwAppId )
    {
        m_appId = dwAppId;
        return true;
    }
    const uint8_t&  GetDevtype () const { return m_devtype; }
    bool SetDevtype ( const uint8_t&  chDevtype )
    {
        m_devtype = chDevtype;
        return true;
    }
private:
    vector< string > m_targetidList;
    uint8_t m_type;
    uint8_t m_msgType;
    int64_t m_msgId;
    string m_nickName;
    string  m_message;
    uint32_t m_appId;
    uint8_t m_devtype;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqSendmulimmessage::Size() const
{
    uint32_t nSize = 37;
    nSize += m_targetidList.size() * 4;
    for(uint32_t i = 0; i < m_targetidList.size(); i++)
    {
        nSize += m_targetidList[i].length();
    }
    nSize += m_nickName.length();
    nSize += m_message.length();
    return nSize;
}

class CImRspSendmulimmessage : public CPackData
{
public:
    CImRspSendmulimmessage()
    {
    }

    ~CImRspSendmulimmessage() { }
    CImRspSendmulimmessage(const int64_t&  llMsgId, const uint8_t&  chRetcode, const string&  strErrinfo)
    {
        m_msgId = llMsgId;
        m_retcode = chRetcode;
        m_errinfo = strErrinfo;
    }
    CImRspSendmulimmessage&  operator=( const CImRspSendmulimmessage&  cImRspSendmulimmessage )
    {
        m_msgId = cImRspSendmulimmessage.m_msgId;
        m_retcode = cImRspSendmulimmessage.m_retcode;
        m_errinfo = cImRspSendmulimmessage.m_errinfo;
        return *this;
    }

    const int64_t&  GetMsgId () const { return m_msgId; }
    bool SetMsgId ( const int64_t&  llMsgId )
    {
        m_msgId = llMsgId;
        return true;
    }
    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetErrinfo () const { return m_errinfo; }
    bool SetErrinfo ( const string&  strErrinfo )
    {
        m_errinfo = strErrinfo;
        return true;
    }
private:
    int64_t m_msgId;
    uint8_t m_retcode;
    string m_errinfo;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspSendmulimmessage::Size() const
{
    uint32_t nSize = 17;
    nSize += m_errinfo.length();
    return nSize;
}

struct SMsgItem
{
public:
    SMsgItem() : m_receiverFlag(0xffff),
            m_cliExtData(""),
            m_srvExtData("")
    {
    }

    ~SMsgItem() { }
    SMsgItem(const uint8_t&  chSubType, const string &  strData, const string&  strUrl, const uint32_t&  dwFileSize, const uint32_t&  dwPlayTime, const uint32_t&  dwReceiverFlag= 0xffff, const string&  strCliExtData= "", const string&  strSrvExtData= "")
    {
        m_subType = chSubType;
        m_data = strData;
        m_url = strUrl;
        m_fileSize = dwFileSize;
        m_playTime = dwPlayTime;
        m_receiverFlag = dwReceiverFlag;
        m_cliExtData = strCliExtData;
        m_srvExtData = strSrvExtData;
    }
    SMsgItem&  operator=( const SMsgItem&  sMsgItem )
    {
        m_subType = sMsgItem.m_subType;
        m_data = sMsgItem.m_data;
        m_url = sMsgItem.m_url;
        m_fileSize = sMsgItem.m_fileSize;
        m_playTime = sMsgItem.m_playTime;
        m_receiverFlag = sMsgItem.m_receiverFlag;
        m_cliExtData = sMsgItem.m_cliExtData;
        m_srvExtData = sMsgItem.m_srvExtData;
        return *this;
    }

    uint8_t m_subType;
    string  m_data;
    string m_url;
    uint32_t m_fileSize;
    uint32_t m_playTime;
    uint32_t m_receiverFlag;
    string m_cliExtData;
    string m_srvExtData;

public:
    uint32_t Size() const;
};

inline uint32_t SMsgItem::Size() const
{
    uint32_t nSize = 38;
    nSize += m_data.length();
    nSize += m_url.length();
    nSize += m_cliExtData.length();
    nSize += m_srvExtData.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SMsgItem&  sMsgItem );
CPackData& operator>> ( CPackData& cPackData, SMsgItem&  sMsgItem );

struct SMessageBody
{
public:
    SMessageBody()
    {
    }

    ~SMessageBody() { }
    SMessageBody(const vector< SMsgItem >&  vecMessageList)
    {
        m_messageList = vecMessageList;
    }
    SMessageBody&  operator=( const SMessageBody&  sMessageBody )
    {
        m_messageList = sMessageBody.m_messageList;
        return *this;
    }

    vector< SMsgItem > m_messageList;

public:
    uint32_t Size() const;
};

inline uint32_t SMessageBody::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_messageList.size(); i++)
    {
        nSize += m_messageList[i].Size();
    }
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SMessageBody&  sMessageBody );
CPackData& operator>> ( CPackData& cPackData, SMessageBody&  sMessageBody );

class CImNtfImmessage : public CPackData
{
public:
    CImNtfImmessage()
    {
    }

    ~CImNtfImmessage() { }
    CImNtfImmessage(const string&  strSendId, const uint32_t&  dwSendTime, const uint8_t&  chMsgType, const int64_t&  llMsgId, const string &  strMessage, const string&  strNickName)
    {
        m_sendId = strSendId;
        m_sendTime = dwSendTime;
        m_msgType = chMsgType;
        m_msgId = llMsgId;
        m_message = strMessage;
        m_nickName = strNickName;
    }
    CImNtfImmessage&  operator=( const CImNtfImmessage&  cImNtfImmessage )
    {
        m_sendId = cImNtfImmessage.m_sendId;
        m_sendTime = cImNtfImmessage.m_sendTime;
        m_msgType = cImNtfImmessage.m_msgType;
        m_msgId = cImNtfImmessage.m_msgId;
        m_message = cImNtfImmessage.m_message;
        m_nickName = cImNtfImmessage.m_nickName;
        return *this;
    }

    const string&  GetSendId () const { return m_sendId; }
    bool SetSendId ( const string&  strSendId )
    {
        if(strSendId.size() > 64) return false;
        m_sendId = strSendId;
        return true;
    }
    const uint32_t&  GetSendTime () const { return m_sendTime; }
    bool SetSendTime ( const uint32_t&  dwSendTime )
    {
        m_sendTime = dwSendTime;
        return true;
    }
    const uint8_t&  GetMsgType () const { return m_msgType; }
    bool SetMsgType ( const uint8_t&  chMsgType )
    {
        m_msgType = chMsgType;
        return true;
    }
    const int64_t&  GetMsgId () const { return m_msgId; }
    bool SetMsgId ( const int64_t&  llMsgId )
    {
        m_msgId = llMsgId;
        return true;
    }
    const string &  GetMessage () const { return m_message; }
    bool SetMessage ( const string &  strMessage )
    {
        m_message = strMessage;
        return true;
    }
    const string&  GetNickName () const { return m_nickName; }
    bool SetNickName ( const string&  strNickName )
    {
        m_nickName = strNickName;
        return true;
    }
private:
    string m_sendId;
    uint32_t m_sendTime;
    uint8_t m_msgType;
    int64_t m_msgId;
    string  m_message;
    string m_nickName;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfImmessage::Size() const
{
    uint32_t nSize = 32;
    nSize += m_sendId.length();
    nSize += m_message.length();
    nSize += m_nickName.length();
    return nSize;
}

class CImNtfOperationtip : public CPackData
{
public:
    CImNtfOperationtip()
    {
    }

    ~CImNtfOperationtip() { }
    CImNtfOperationtip(const string&  strSendId, const uint32_t&  dwSendTime, const uint8_t&  chMsgType, const string &  strMessage)
    {
        m_sendId = strSendId;
        m_sendTime = dwSendTime;
        m_msgType = chMsgType;
        m_message = strMessage;
    }
    CImNtfOperationtip&  operator=( const CImNtfOperationtip&  cImNtfOperationtip )
    {
        m_sendId = cImNtfOperationtip.m_sendId;
        m_sendTime = cImNtfOperationtip.m_sendTime;
        m_msgType = cImNtfOperationtip.m_msgType;
        m_message = cImNtfOperationtip.m_message;
        return *this;
    }

    const string&  GetSendId () const { return m_sendId; }
    bool SetSendId ( const string&  strSendId )
    {
        if(strSendId.size() > 64) return false;
        m_sendId = strSendId;
        return true;
    }
    const uint32_t&  GetSendTime () const { return m_sendTime; }
    bool SetSendTime ( const uint32_t&  dwSendTime )
    {
        m_sendTime = dwSendTime;
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
private:
    string m_sendId;
    uint32_t m_sendTime;
    uint8_t m_msgType;
    string  m_message;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfOperationtip::Size() const
{
    uint32_t nSize = 18;
    nSize += m_sendId.length();
    nSize += m_message.length();
    return nSize;
}

struct SNotifyOffmsgItem
{
public:
    SNotifyOffmsgItem()
    {
    }

    ~SNotifyOffmsgItem() { }
    SNotifyOffmsgItem(const uint32_t&  dwCount, const uint32_t&  dwSize)
    {
        m_count = dwCount;
        m_size = dwSize;
    }
    SNotifyOffmsgItem&  operator=( const SNotifyOffmsgItem&  sNotifyOffmsgItem )
    {
        m_count = sNotifyOffmsgItem.m_count;
        m_size = sNotifyOffmsgItem.m_size;
        return *this;
    }

    uint32_t m_count;
    uint32_t m_size;

public:
    uint32_t Size() const;
};

inline uint32_t SNotifyOffmsgItem::Size() const
{
    return 11;
}
CPackData& operator<< ( CPackData& cPackData, const SNotifyOffmsgItem&  sNotifyOffmsgItem );
CPackData& operator>> ( CPackData& cPackData, SNotifyOffmsgItem&  sNotifyOffmsgItem );

struct SNotifyContactOperate
{
public:
    SNotifyContactOperate()
    {
    }

    ~SNotifyContactOperate() { }
    SNotifyContactOperate(const uint8_t&  chOptype, const string&  strPeerId, const string&  strPeerName, const string&  strMessage)
    {
        m_optype = chOptype;
        m_peerId = strPeerId;
        m_peerName = strPeerName;
        m_message = strMessage;
    }
    SNotifyContactOperate&  operator=( const SNotifyContactOperate&  sNotifyContactOperate )
    {
        m_optype = sNotifyContactOperate.m_optype;
        m_peerId = sNotifyContactOperate.m_peerId;
        m_peerName = sNotifyContactOperate.m_peerName;
        m_message = sNotifyContactOperate.m_message;
        return *this;
    }

    uint8_t m_optype;
    string m_peerId;
    string m_peerName;
    string m_message;

public:
    uint32_t Size() const;
};

inline uint32_t SNotifyContactOperate::Size() const
{
    uint32_t nSize = 18;
    nSize += m_peerId.length();
    nSize += m_peerName.length();
    nSize += m_message.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SNotifyContactOperate&  sNotifyContactOperate );
CPackData& operator>> ( CPackData& cPackData, SNotifyContactOperate&  sNotifyContactOperate );

class CImReqDelofflinemsg : public CPackData
{
public:
    CImReqDelofflinemsg()
    {
    }

    ~CImReqDelofflinemsg() { }
    CImReqDelofflinemsg(const uint32_t&  dwLastTime, const uint32_t&  dwCount)
    {
        m_lastTime = dwLastTime;
        m_count = dwCount;
    }
    CImReqDelofflinemsg&  operator=( const CImReqDelofflinemsg&  cImReqDelofflinemsg )
    {
        m_lastTime = cImReqDelofflinemsg.m_lastTime;
        m_count = cImReqDelofflinemsg.m_count;
        return *this;
    }

    const uint32_t&  GetLastTime () const { return m_lastTime; }
    bool SetLastTime ( const uint32_t&  dwLastTime )
    {
        m_lastTime = dwLastTime;
        return true;
    }
    const uint32_t&  GetCount () const { return m_count; }
    bool SetCount ( const uint32_t&  dwCount )
    {
        m_count = dwCount;
        return true;
    }
private:
    uint32_t m_lastTime;
    uint32_t m_count;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqDelofflinemsg::Size() const
{
    return 11;
}
class CImRspDelofflinemsg : public CPackData
{
public:
    CImRspDelofflinemsg()
    {
    }

    ~CImRspDelofflinemsg() { }
    CImRspDelofflinemsg(const uint32_t&  dwRetcode)
    {
        m_retcode = dwRetcode;
    }
    CImRspDelofflinemsg&  operator=( const CImRspDelofflinemsg&  cImRspDelofflinemsg )
    {
        m_retcode = cImRspDelofflinemsg.m_retcode;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
private:
    uint32_t m_retcode;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspDelofflinemsg::Size() const
{
    return 6;
}
struct SContactAddNotify
{
public:
    SContactAddNotify()
    {
    }

    ~SContactAddNotify() { }
    SContactAddNotify(const uint32_t&  dwAction, const string&  strMessage)
    {
        m_action = dwAction;
        m_message = strMessage;
    }
    SContactAddNotify&  operator=( const SContactAddNotify&  sContactAddNotify )
    {
        m_action = sContactAddNotify.m_action;
        m_message = sContactAddNotify.m_message;
        return *this;
    }

    uint32_t m_action;
    string m_message;

public:
    uint32_t Size() const;
};

inline uint32_t SContactAddNotify::Size() const
{
    uint32_t nSize = 11;
    nSize += m_message.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SContactAddNotify&  sContactAddNotify );
CPackData& operator>> ( CPackData& cPackData, SContactAddNotify&  sContactAddNotify );

struct SChgContactInfo
{
public:
    SChgContactInfo()
    {
    }

    ~SChgContactInfo() { }
    SChgContactInfo(const int64_t&  llMask, const string&  strContactId, const string&  strNickName, const string&  strImportance, const int64_t&  llGroupId)
    {
        m_mask = llMask;
        m_contactId = strContactId;
        m_nickName = strNickName;
        m_importance = strImportance;
        m_groupId = llGroupId;
    }
    SChgContactInfo&  operator=( const SChgContactInfo&  sChgContactInfo )
    {
        m_mask = sChgContactInfo.m_mask;
        m_contactId = sChgContactInfo.m_contactId;
        m_nickName = sChgContactInfo.m_nickName;
        m_importance = sChgContactInfo.m_importance;
        m_groupId = sChgContactInfo.m_groupId;
        return *this;
    }

    int64_t m_mask;
    string m_contactId;
    string m_nickName;
    string m_importance;
    int64_t m_groupId;

public:
    uint32_t Size() const;
};

inline uint32_t SChgContactInfo::Size() const
{
    uint32_t nSize = 34;
    nSize += m_contactId.length();
    nSize += m_nickName.length();
    nSize += m_importance.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SChgContactInfo&  sChgContactInfo );
CPackData& operator>> ( CPackData& cPackData, SChgContactInfo&  sChgContactInfo );

struct SContactInfo
{
public:
    SContactInfo()
    {
    }

    ~SContactInfo() { }
    SContactInfo(const string&  strContactId, const string&  strNickName, const string&  strMd5Phone, const string&  strImportance, const int64_t&  llGroupId)
    {
        m_contactId = strContactId;
        m_nickName = strNickName;
        m_md5Phone = strMd5Phone;
        m_importance = strImportance;
        m_groupId = llGroupId;
    }
    SContactInfo&  operator=( const SContactInfo&  sContactInfo )
    {
        m_contactId = sContactInfo.m_contactId;
        m_nickName = sContactInfo.m_nickName;
        m_md5Phone = sContactInfo.m_md5Phone;
        m_importance = sContactInfo.m_importance;
        m_groupId = sContactInfo.m_groupId;
        return *this;
    }

    string m_contactId;
    string m_nickName;
    string m_md5Phone;
    string m_importance;
    int64_t m_groupId;

public:
    uint32_t Size() const;
};

inline uint32_t SContactInfo::Size() const
{
    uint32_t nSize = 30;
    nSize += m_contactId.length();
    nSize += m_nickName.length();
    nSize += m_md5Phone.length();
    nSize += m_importance.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SContactInfo&  sContactInfo );
CPackData& operator>> ( CPackData& cPackData, SContactInfo&  sContactInfo );

struct SUserStatus
{
public:
    SUserStatus()
    {
    }

    ~SUserStatus() { }
    SUserStatus(const string&  strUserId, const uint8_t&  chBasicStatus, const uint8_t&  chPredefStatus)
    {
        m_userId = strUserId;
        m_basicStatus = chBasicStatus;
        m_predefStatus = chPredefStatus;
    }
    SUserStatus&  operator=( const SUserStatus&  sUserStatus )
    {
        m_userId = sUserStatus.m_userId;
        m_basicStatus = sUserStatus.m_basicStatus;
        m_predefStatus = sUserStatus.m_predefStatus;
        return *this;
    }

    string m_userId;
    uint8_t m_basicStatus;
    uint8_t m_predefStatus;

public:
    uint32_t Size() const;
};

inline uint32_t SUserStatus::Size() const
{
    uint32_t nSize = 10;
    nSize += m_userId.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SUserStatus&  sUserStatus );
CPackData& operator>> ( CPackData& cPackData, SUserStatus&  sUserStatus );

class CImNtfStatus : public CPackData
{
public:
    CImNtfStatus()
    {
    }

    ~CImNtfStatus() { }
    CImNtfStatus(const vector< SUserStatus >&  vecUserStatusList)
    {
        m_userStatusList = vecUserStatusList;
    }
    CImNtfStatus&  operator=( const CImNtfStatus&  cImNtfStatus )
    {
        m_userStatusList = cImNtfStatus.m_userStatusList;
        return *this;
    }

    const vector< SUserStatus >&  GetUserStatusList () const { return m_userStatusList; }
    bool SetUserStatusList ( const vector< SUserStatus >&  vecUserStatusList )
    {
        m_userStatusList = vecUserStatusList;
        return true;
    }
private:
    vector< SUserStatus > m_userStatusList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfStatus::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_userStatusList.size(); i++)
    {
        nSize += m_userStatusList[i].Size();
    }
    return nSize;
}

class CImReqSubscribeInfo : public CPackData
{
public:
    CImReqSubscribeInfo()
    {
    }

    ~CImReqSubscribeInfo() { }
    CImReqSubscribeInfo(const vector< string >&  vecTargetList)
    {
        m_targetList = vecTargetList;
    }
    CImReqSubscribeInfo&  operator=( const CImReqSubscribeInfo&  cImReqSubscribeInfo )
    {
        m_targetList = cImReqSubscribeInfo.m_targetList;
        return *this;
    }

    const vector< string >&  GetTargetList () const { return m_targetList; }
    bool SetTargetList ( const vector< string >&  vecTargetList )
    {
        m_targetList = vecTargetList;
        return true;
    }
private:
    vector< string > m_targetList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqSubscribeInfo::Size() const
{
    uint32_t nSize = 7;
    nSize += m_targetList.size() * 4;
    for(uint32_t i = 0; i < m_targetList.size(); i++)
    {
        nSize += m_targetList[i].length();
    }
    return nSize;
}

class CImRspSubscribeInfo : public CPackData
{
public:
    CImRspSubscribeInfo()
    {
    }

    ~CImRspSubscribeInfo() { }
    CImRspSubscribeInfo(const uint32_t&  dwRetcode, const vector< SUserStatus >&  vecStatusList)
    {
        m_retcode = dwRetcode;
        m_statusList = vecStatusList;
    }
    CImRspSubscribeInfo&  operator=( const CImRspSubscribeInfo&  cImRspSubscribeInfo )
    {
        m_retcode = cImRspSubscribeInfo.m_retcode;
        m_statusList = cImRspSubscribeInfo.m_statusList;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SUserStatus >&  GetStatusList () const { return m_statusList; }
    bool SetStatusList ( const vector< SUserStatus >&  vecStatusList )
    {
        m_statusList = vecStatusList;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SUserStatus > m_statusList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspSubscribeInfo::Size() const
{
    uint32_t nSize = 12;
    for(uint32_t i = 0; i < m_statusList.size(); i++)
    {
        nSize += m_statusList[i].Size();
    }
    return nSize;
}

class CImReqUserudbprofile : public CPackData
{
public:
    CImReqUserudbprofile()
    {
    }

    ~CImReqUserudbprofile() { }
    CImReqUserudbprofile(const string&  strUid)
    {
        m_uid = strUid;
    }
    CImReqUserudbprofile&  operator=( const CImReqUserudbprofile&  cImReqUserudbprofile )
    {
        m_uid = cImReqUserudbprofile.m_uid;
        return *this;
    }

    const string&  GetUid () const { return m_uid; }
    bool SetUid ( const string&  strUid )
    {
        m_uid = strUid;
        return true;
    }
private:
    string m_uid;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqUserudbprofile::Size() const
{
    uint32_t nSize = 6;
    nSize += m_uid.length();
    return nSize;
}

class CImRspUserudbprofile : public CPackData
{
public:
    CImRspUserudbprofile()
    {
    }

    ~CImRspUserudbprofile() { }
    CImRspUserudbprofile(const uint32_t&  dwRetcode, const string&  strUid, const map< string,string >&  mapProfilelist)
    {
        m_retcode = dwRetcode;
        m_uid = strUid;
        m_profilelist = mapProfilelist;
    }
    CImRspUserudbprofile&  operator=( const CImRspUserudbprofile&  cImRspUserudbprofile )
    {
        m_retcode = cImRspUserudbprofile.m_retcode;
        m_uid = cImRspUserudbprofile.m_uid;
        m_profilelist = cImRspUserudbprofile.m_profilelist;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetUid () const { return m_uid; }
    bool SetUid ( const string&  strUid )
    {
        m_uid = strUid;
        return true;
    }
    const map< string,string >&  GetProfilelist () const { return m_profilelist; }
    bool SetProfilelist ( const map< string,string >&  mapProfilelist )
    {
        m_profilelist = mapProfilelist;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_uid;
    map< string,string > m_profilelist;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspUserudbprofile::Size() const
{
    uint32_t nSize = 15;
    nSize += m_uid.length();
    nSize += m_profilelist.size() * 8;
    {
        map< string,string >::const_iterator itr;
        for(itr = m_profilelist.begin(); itr != m_profilelist.end(); ++itr)
        {
            nSize += itr->first.length();
            nSize += itr->second.length();
        }
    }
    return nSize;
}

class CImReqSearchLatentContact : public CPackData
{
public:
    CImReqSearchLatentContact() : m_longitude(0),
            m_latitude(0)
    {
    }

    ~CImReqSearchLatentContact() { }
    CImReqSearchLatentContact(const uint32_t&  dwAction, const double&  dLongitude= 0, const double&  dLatitude= 0)
    {
        m_action = dwAction;
        m_longitude = dLongitude;
        m_latitude = dLatitude;
    }
    CImReqSearchLatentContact&  operator=( const CImReqSearchLatentContact&  cImReqSearchLatentContact )
    {
        m_action = cImReqSearchLatentContact.m_action;
        m_longitude = cImReqSearchLatentContact.m_longitude;
        m_latitude = cImReqSearchLatentContact.m_latitude;
        return *this;
    }

    const uint32_t&  GetAction () const { return m_action; }
    bool SetAction ( const uint32_t&  dwAction )
    {
        m_action = dwAction;
        return true;
    }
    const double&  GetLongitude () const { return m_longitude; }
    bool SetLongitude ( const double&  dLongitude )
    {
        m_longitude = dLongitude;
        return true;
    }
    const double&  GetLatitude () const { return m_latitude; }
    bool SetLatitude ( const double&  dLatitude )
    {
        m_latitude = dLatitude;
        return true;
    }
private:
    uint32_t m_action;
    double m_longitude;
    double m_latitude;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqSearchLatentContact::Size() const
{
    return 24;
}
struct SLatentContact
{
public:
    SLatentContact()
    {
    }

    ~SLatentContact() { }
    SLatentContact(const string&  strContactId, const string&  strNickName, const string&  strMd5Phone, const string&  strReason, const int32_t&  lDistance, const int32_t&  lGender, const string&  strAvatarurl, const string&  strSignature)
    {
        m_contactId = strContactId;
        m_nickName = strNickName;
        m_md5Phone = strMd5Phone;
        m_reason = strReason;
        m_distance = lDistance;
        m_gender = lGender;
        m_avatarurl = strAvatarurl;
        m_signature = strSignature;
    }
    SLatentContact&  operator=( const SLatentContact&  sLatentContact )
    {
        m_contactId = sLatentContact.m_contactId;
        m_nickName = sLatentContact.m_nickName;
        m_md5Phone = sLatentContact.m_md5Phone;
        m_reason = sLatentContact.m_reason;
        m_distance = sLatentContact.m_distance;
        m_gender = sLatentContact.m_gender;
        m_avatarurl = sLatentContact.m_avatarurl;
        m_signature = sLatentContact.m_signature;
        return *this;
    }

    string m_contactId;
    string m_nickName;
    string m_md5Phone;
    string m_reason;
    int32_t m_distance;
    int32_t m_gender;
    string m_avatarurl;
    string m_signature;

public:
    uint32_t Size() const;
};

inline uint32_t SLatentContact::Size() const
{
    uint32_t nSize = 41;
    nSize += m_contactId.length();
    nSize += m_nickName.length();
    nSize += m_md5Phone.length();
    nSize += m_reason.length();
    nSize += m_avatarurl.length();
    nSize += m_signature.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SLatentContact&  sLatentContact );
CPackData& operator>> ( CPackData& cPackData, SLatentContact&  sLatentContact );

struct SFriendRecommendItem
{
public:
    SFriendRecommendItem()
    {
    }

    ~SFriendRecommendItem() { }
    SFriendRecommendItem(const string&  strContactId, const string&  strNickName, const string&  strPhoneMd5, const uint32_t&  dwRelationType, const string&  strReason, const string&  strRecommendIndex, const string&  strAvatar)
    {
        m_contactId = strContactId;
        m_nickName = strNickName;
        m_phoneMd5 = strPhoneMd5;
        m_relationType = dwRelationType;
        m_reason = strReason;
        m_recommendIndex = strRecommendIndex;
        m_avatar = strAvatar;
    }
    SFriendRecommendItem&  operator=( const SFriendRecommendItem&  sFriendRecommendItem )
    {
        m_contactId = sFriendRecommendItem.m_contactId;
        m_nickName = sFriendRecommendItem.m_nickName;
        m_phoneMd5 = sFriendRecommendItem.m_phoneMd5;
        m_relationType = sFriendRecommendItem.m_relationType;
        m_reason = sFriendRecommendItem.m_reason;
        m_recommendIndex = sFriendRecommendItem.m_recommendIndex;
        m_avatar = sFriendRecommendItem.m_avatar;
        return *this;
    }

    string m_contactId;
    string m_nickName;
    string m_phoneMd5;
    uint32_t m_relationType;
    string m_reason;
    string m_recommendIndex;
    string m_avatar;

public:
    uint32_t Size() const;
};

inline uint32_t SFriendRecommendItem::Size() const
{
    uint32_t nSize = 36;
    nSize += m_contactId.length();
    nSize += m_nickName.length();
    nSize += m_phoneMd5.length();
    nSize += m_reason.length();
    nSize += m_recommendIndex.length();
    nSize += m_avatar.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SFriendRecommendItem&  sFriendRecommendItem );
CPackData& operator>> ( CPackData& cPackData, SFriendRecommendItem&  sFriendRecommendItem );

struct SFriendRecommendList
{
public:
    SFriendRecommendList()
    {
    }

    ~SFriendRecommendList() { }
    SFriendRecommendList(const vector< SFriendRecommendItem >&  vecItems)
    {
        m_items = vecItems;
    }
    SFriendRecommendList&  operator=( const SFriendRecommendList&  sFriendRecommendList )
    {
        m_items = sFriendRecommendList.m_items;
        return *this;
    }

    vector< SFriendRecommendItem > m_items;

public:
    uint32_t Size() const;
};

inline uint32_t SFriendRecommendList::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_items.size(); i++)
    {
        nSize += m_items[i].Size();
    }
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SFriendRecommendList&  sFriendRecommendList );
CPackData& operator>> ( CPackData& cPackData, SFriendRecommendList&  sFriendRecommendList );

class CImRspSearchLatentContact : public CPackData
{
public:
    CImRspSearchLatentContact()
    {
    }

    ~CImRspSearchLatentContact() { }
    CImRspSearchLatentContact(const uint32_t&  dwRetcode, const vector< SLatentContact >&  vecContactList)
    {
        m_retcode = dwRetcode;
        m_contactList = vecContactList;
    }
    CImRspSearchLatentContact&  operator=( const CImRspSearchLatentContact&  cImRspSearchLatentContact )
    {
        m_retcode = cImRspSearchLatentContact.m_retcode;
        m_contactList = cImRspSearchLatentContact.m_contactList;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SLatentContact >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< SLatentContact >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SLatentContact > m_contactList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspSearchLatentContact::Size() const
{
    uint32_t nSize = 12;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].Size();
    }
    return nSize;
}

class CImReqCheckAuthcode : public CPackData
{
public:
    CImReqCheckAuthcode() : m_mode(0)
    {
    }

    ~CImReqCheckAuthcode() { }
    CImReqCheckAuthcode(const string&  strSessionId, const string&  strAuthCode, const uint8_t&  chMode= 0)
    {
        m_sessionId = strSessionId;
        m_authCode = strAuthCode;
        m_mode = chMode;
    }
    CImReqCheckAuthcode&  operator=( const CImReqCheckAuthcode&  cImReqCheckAuthcode )
    {
        m_sessionId = cImReqCheckAuthcode.m_sessionId;
        m_authCode = cImReqCheckAuthcode.m_authCode;
        m_mode = cImReqCheckAuthcode.m_mode;
        return *this;
    }

    const string&  GetSessionId () const { return m_sessionId; }
    bool SetSessionId ( const string&  strSessionId )
    {
        m_sessionId = strSessionId;
        return true;
    }
    const string&  GetAuthCode () const { return m_authCode; }
    bool SetAuthCode ( const string&  strAuthCode )
    {
        m_authCode = strAuthCode;
        return true;
    }
    const uint8_t&  GetMode () const { return m_mode; }
    bool SetMode ( const uint8_t&  chMode )
    {
        m_mode = chMode;
        return true;
    }
private:
    string m_sessionId;
    string m_authCode;
    uint8_t m_mode;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqCheckAuthcode::Size() const
{
    uint32_t nSize = 13;
    nSize += m_sessionId.length();
    nSize += m_authCode.length();
    return nSize;
}

class CImRspCheckAuthcode : public CPackData
{
public:
    CImRspCheckAuthcode()
    {
    }

    ~CImRspCheckAuthcode() { }
    CImRspCheckAuthcode(const uint8_t&  chRetcode, const string&  strSessionId, const string&  strAuthCode, const string&  strNewSessionId)
    {
        m_retcode = chRetcode;
        m_sessionId = strSessionId;
        m_authCode = strAuthCode;
        m_newSessionId = strNewSessionId;
    }
    CImRspCheckAuthcode&  operator=( const CImRspCheckAuthcode&  cImRspCheckAuthcode )
    {
        m_retcode = cImRspCheckAuthcode.m_retcode;
        m_sessionId = cImRspCheckAuthcode.m_sessionId;
        m_authCode = cImRspCheckAuthcode.m_authCode;
        m_newSessionId = cImRspCheckAuthcode.m_newSessionId;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const string&  GetSessionId () const { return m_sessionId; }
    bool SetSessionId ( const string&  strSessionId )
    {
        m_sessionId = strSessionId;
        return true;
    }
    const string&  GetAuthCode () const { return m_authCode; }
    bool SetAuthCode ( const string&  strAuthCode )
    {
        m_authCode = strAuthCode;
        return true;
    }
    const string&  GetNewSessionId () const { return m_newSessionId; }
    bool SetNewSessionId ( const string&  strNewSessionId )
    {
        m_newSessionId = strNewSessionId;
        return true;
    }
private:
    uint8_t m_retcode;
    string m_sessionId;
    string m_authCode;
    string m_newSessionId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspCheckAuthcode::Size() const
{
    uint32_t nSize = 18;
    nSize += m_sessionId.length();
    nSize += m_authCode.length();
    nSize += m_newSessionId.length();
    return nSize;
}

struct SNotifyPlugin
{
public:
    SNotifyPlugin() : m_clickParam(""),
            m_clickType(0),
            m_extraFlag(0)
    {
    }

    ~SNotifyPlugin() { }
    SNotifyPlugin(const uint32_t&  dwPluginid, const string&  strItemid, const string&  strUid, const uint32_t&  dwNotifyTime, const uint32_t&  dwExpireTime, const uint32_t&  dwNotifyType, const string&  strTitle, const string&  strImageurl, const string&  strMsgbody, const string&  strDetailurl, const string&  strClickParam= "", const uint32_t&  dwClickType= 0, const uint32_t&  dwExtraFlag= 0)
    {
        m_pluginid = dwPluginid;
        m_itemid = strItemid;
        m_uid = strUid;
        m_notifyTime = dwNotifyTime;
        m_expireTime = dwExpireTime;
        m_notifyType = dwNotifyType;
        m_title = strTitle;
        m_imageurl = strImageurl;
        m_msgbody = strMsgbody;
        m_detailurl = strDetailurl;
        m_clickParam = strClickParam;
        m_clickType = dwClickType;
        m_extraFlag = dwExtraFlag;
    }
    SNotifyPlugin&  operator=( const SNotifyPlugin&  sNotifyPlugin )
    {
        m_pluginid = sNotifyPlugin.m_pluginid;
        m_itemid = sNotifyPlugin.m_itemid;
        m_uid = sNotifyPlugin.m_uid;
        m_notifyTime = sNotifyPlugin.m_notifyTime;
        m_expireTime = sNotifyPlugin.m_expireTime;
        m_notifyType = sNotifyPlugin.m_notifyType;
        m_title = sNotifyPlugin.m_title;
        m_imageurl = sNotifyPlugin.m_imageurl;
        m_msgbody = sNotifyPlugin.m_msgbody;
        m_detailurl = sNotifyPlugin.m_detailurl;
        m_clickParam = sNotifyPlugin.m_clickParam;
        m_clickType = sNotifyPlugin.m_clickType;
        m_extraFlag = sNotifyPlugin.m_extraFlag;
        return *this;
    }

    uint32_t m_pluginid;
    string m_itemid;
    string m_uid;
    uint32_t m_notifyTime;
    uint32_t m_expireTime;
    uint32_t m_notifyType;
    string m_title;
    string m_imageurl;
    string m_msgbody;
    string m_detailurl;
    string m_clickParam;
    uint32_t m_clickType;
    uint32_t m_extraFlag;

public:
    uint32_t Size() const;
};

inline uint32_t SNotifyPlugin::Size() const
{
    uint32_t nSize = 66;
    nSize += m_itemid.length();
    nSize += m_uid.length();
    nSize += m_title.length();
    nSize += m_imageurl.length();
    nSize += m_msgbody.length();
    nSize += m_detailurl.length();
    nSize += m_clickParam.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SNotifyPlugin&  sNotifyPlugin );
CPackData& operator>> ( CPackData& cPackData, SNotifyPlugin&  sNotifyPlugin );

class CImNtfNeedAuthcode : public CPackData
{
public:
    CImNtfNeedAuthcode()
    {
    }

    ~CImNtfNeedAuthcode() { }
    CImNtfNeedAuthcode(const string&  strCheckImgUrl, const string&  strOrigPacket)
    {
        m_checkImgUrl = strCheckImgUrl;
        m_origPacket = strOrigPacket;
    }
    CImNtfNeedAuthcode&  operator=( const CImNtfNeedAuthcode&  cImNtfNeedAuthcode )
    {
        m_checkImgUrl = cImNtfNeedAuthcode.m_checkImgUrl;
        m_origPacket = cImNtfNeedAuthcode.m_origPacket;
        return *this;
    }

    const string&  GetCheckImgUrl () const { return m_checkImgUrl; }
    bool SetCheckImgUrl ( const string&  strCheckImgUrl )
    {
        m_checkImgUrl = strCheckImgUrl;
        return true;
    }
    const string&  GetOrigPacket () const { return m_origPacket; }
    bool SetOrigPacket ( const string&  strOrigPacket )
    {
        m_origPacket = strOrigPacket;
        return true;
    }
private:
    string m_checkImgUrl;
    string m_origPacket;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfNeedAuthcode::Size() const
{
    uint32_t nSize = 11;
    nSize += m_checkImgUrl.length();
    nSize += m_origPacket.length();
    return nSize;
}

struct SUserGroup
{
public:
    SUserGroup()
    {
    }

    ~SUserGroup() { }
    SUserGroup(const int64_t&  llGroupId, const int64_t&  llParentId, const string&  strGroupName)
    {
        m_groupId = llGroupId;
        m_parentId = llParentId;
        m_groupName = strGroupName;
    }
    SUserGroup&  operator=( const SUserGroup&  sUserGroup )
    {
        m_groupId = sUserGroup.m_groupId;
        m_parentId = sUserGroup.m_parentId;
        m_groupName = sUserGroup.m_groupName;
        return *this;
    }

    int64_t m_groupId;
    int64_t m_parentId;
    string m_groupName;

public:
    uint32_t Size() const;
};

inline uint32_t SUserGroup::Size() const
{
    uint32_t nSize = 24;
    nSize += m_groupName.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SUserGroup&  sUserGroup );
CPackData& operator>> ( CPackData& cPackData, SUserGroup&  sUserGroup );

class CImReqChgstatus : public CPackData
{
public:
    CImReqChgstatus()
    {
    }

    ~CImReqChgstatus() { }
    CImReqChgstatus(const uint8_t&  chBasicStatus, const uint8_t&  chPredefStatus)
    {
        m_basicStatus = chBasicStatus;
        m_predefStatus = chPredefStatus;
    }
    CImReqChgstatus&  operator=( const CImReqChgstatus&  cImReqChgstatus )
    {
        m_basicStatus = cImReqChgstatus.m_basicStatus;
        m_predefStatus = cImReqChgstatus.m_predefStatus;
        return *this;
    }

    const uint8_t&  GetBasicStatus () const { return m_basicStatus; }
    bool SetBasicStatus ( const uint8_t&  chBasicStatus )
    {
        m_basicStatus = chBasicStatus;
        return true;
    }
    const uint8_t&  GetPredefStatus () const { return m_predefStatus; }
    bool SetPredefStatus ( const uint8_t&  chPredefStatus )
    {
        m_predefStatus = chPredefStatus;
        return true;
    }
private:
    uint8_t m_basicStatus;
    uint8_t m_predefStatus;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqChgstatus::Size() const
{
    return 5;
}
class CImReqGetContactsFlag : public CPackData
{
public:
    CImReqGetContactsFlag()
    {
    }

    ~CImReqGetContactsFlag() { }
    CImReqGetContactsFlag(const vector< string >&  vecContactList, const uint32_t&  dwType)
    {
        m_contactList = vecContactList;
        m_type = dwType;
    }
    CImReqGetContactsFlag&  operator=( const CImReqGetContactsFlag&  cImReqGetContactsFlag )
    {
        m_contactList = cImReqGetContactsFlag.m_contactList;
        m_type = cImReqGetContactsFlag.m_type;
        return *this;
    }

    const vector< string >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< string >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
    const uint32_t&  GetType () const { return m_type; }
    bool SetType ( const uint32_t&  dwType )
    {
        m_type = dwType;
        return true;
    }
private:
    vector< string > m_contactList;
    uint32_t m_type;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqGetContactsFlag::Size() const
{
    uint32_t nSize = 12;
    nSize += m_contactList.size() * 4;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].length();
    }
    return nSize;
}

class CImRspGetContactsFlag : public CPackData
{
public:
    CImRspGetContactsFlag()
    {
    }

    ~CImRspGetContactsFlag() { }
    CImRspGetContactsFlag(const uint32_t&  dwRetcode, const vector< string >&  vecContactList)
    {
        m_retcode = dwRetcode;
        m_contactList = vecContactList;
    }
    CImRspGetContactsFlag&  operator=( const CImRspGetContactsFlag&  cImRspGetContactsFlag )
    {
        m_retcode = cImRspGetContactsFlag.m_retcode;
        m_contactList = cImRspGetContactsFlag.m_contactList;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< string >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< string >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< string > m_contactList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspGetContactsFlag::Size() const
{
    uint32_t nSize = 12;
    nSize += m_contactList.size() * 4;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].length();
    }
    return nSize;
}

class CImReqTribe : public CPackData
{
public:
    CImReqTribe()
    {
    }

    ~CImReqTribe() { }
    CImReqTribe(const string&  strOperation, const string&  strReqData, const string&  strCliData)
    {
        m_operation = strOperation;
        m_reqData = strReqData;
        m_cliData = strCliData;
    }
    CImReqTribe&  operator=( const CImReqTribe&  cImReqTribe )
    {
        m_operation = cImReqTribe.m_operation;
        m_reqData = cImReqTribe.m_reqData;
        m_cliData = cImReqTribe.m_cliData;
        return *this;
    }

    const string&  GetOperation () const { return m_operation; }
    bool SetOperation ( const string&  strOperation )
    {
        m_operation = strOperation;
        return true;
    }
    const string&  GetReqData () const { return m_reqData; }
    bool SetReqData ( const string&  strReqData )
    {
        m_reqData = strReqData;
        return true;
    }
    const string&  GetCliData () const { return m_cliData; }
    bool SetCliData ( const string&  strCliData )
    {
        m_cliData = strCliData;
        return true;
    }
private:
    string m_operation;
    string m_reqData;
    string m_cliData;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqTribe::Size() const
{
    uint32_t nSize = 16;
    nSize += m_operation.length();
    nSize += m_reqData.length();
    nSize += m_cliData.length();
    return nSize;
}

class CImRspTribe : public CPackData
{
public:
    CImRspTribe()
    {
    }

    ~CImRspTribe() { }
    CImRspTribe(const uint32_t&  dwRetcode, const string&  strOperation, const string&  strRspData, const string&  strCliData)
    {
        m_retcode = dwRetcode;
        m_operation = strOperation;
        m_rspData = strRspData;
        m_cliData = strCliData;
    }
    CImRspTribe&  operator=( const CImRspTribe&  cImRspTribe )
    {
        m_retcode = cImRspTribe.m_retcode;
        m_operation = cImRspTribe.m_operation;
        m_rspData = cImRspTribe.m_rspData;
        m_cliData = cImRspTribe.m_cliData;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetOperation () const { return m_operation; }
    bool SetOperation ( const string&  strOperation )
    {
        m_operation = strOperation;
        return true;
    }
    const string&  GetRspData () const { return m_rspData; }
    bool SetRspData ( const string&  strRspData )
    {
        m_rspData = strRspData;
        return true;
    }
    const string&  GetCliData () const { return m_cliData; }
    bool SetCliData ( const string&  strCliData )
    {
        m_cliData = strCliData;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_operation;
    string m_rspData;
    string m_cliData;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspTribe::Size() const
{
    uint32_t nSize = 21;
    nSize += m_operation.length();
    nSize += m_rspData.length();
    nSize += m_cliData.length();
    return nSize;
}

class CImNtfTribe : public CPackData
{
public:
    CImNtfTribe()
    {
    }

    ~CImNtfTribe() { }
    CImNtfTribe(const string&  strOperation, const string&  strData)
    {
        m_operation = strOperation;
        m_data = strData;
    }
    CImNtfTribe&  operator=( const CImNtfTribe&  cImNtfTribe )
    {
        m_operation = cImNtfTribe.m_operation;
        m_data = cImNtfTribe.m_data;
        return *this;
    }

    const string&  GetOperation () const { return m_operation; }
    bool SetOperation ( const string&  strOperation )
    {
        m_operation = strOperation;
        return true;
    }
    const string&  GetData () const { return m_data; }
    bool SetData ( const string&  strData )
    {
        m_data = strData;
        return true;
    }
private:
    string m_operation;
    string m_data;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfTribe::Size() const
{
    uint32_t nSize = 11;
    nSize += m_operation.length();
    nSize += m_data.length();
    return nSize;
}

class CCntReqGetContact : public CPackData
{
public:
    CCntReqGetContact() : m_flag(0)
    {
    }

    ~CCntReqGetContact() { }
    CCntReqGetContact(const uint32_t&  dwTimestamp, const uint32_t&  dwCount, const uint32_t&  dwFlag= 0)
    {
        m_timestamp = dwTimestamp;
        m_count = dwCount;
        m_flag = dwFlag;
    }
    CCntReqGetContact&  operator=( const CCntReqGetContact&  cCntReqGetContact )
    {
        m_timestamp = cCntReqGetContact.m_timestamp;
        m_count = cCntReqGetContact.m_count;
        m_flag = cCntReqGetContact.m_flag;
        return *this;
    }

    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
    const uint32_t&  GetCount () const { return m_count; }
    bool SetCount ( const uint32_t&  dwCount )
    {
        m_count = dwCount;
        return true;
    }
    const uint32_t&  GetFlag () const { return m_flag; }
    bool SetFlag ( const uint32_t&  dwFlag )
    {
        m_flag = dwFlag;
        return true;
    }
private:
    uint32_t m_timestamp;
    uint32_t m_count;
    uint32_t m_flag;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqGetContact::Size() const
{
    return 16;
}
class CCntRspGetContact : public CPackData
{
public:
    CCntRspGetContact()
    {
    }

    ~CCntRspGetContact() { }
    CCntRspGetContact(const uint32_t&  dwRetcode, const vector< SContactInfo >&  vecContactList, const uint32_t&  dwTimestamp)
    {
        m_retcode = dwRetcode;
        m_contactList = vecContactList;
        m_timestamp = dwTimestamp;
    }
    CCntRspGetContact&  operator=( const CCntRspGetContact&  cCntRspGetContact )
    {
        m_retcode = cCntRspGetContact.m_retcode;
        m_contactList = cCntRspGetContact.m_contactList;
        m_timestamp = cCntRspGetContact.m_timestamp;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SContactInfo >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< SContactInfo >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SContactInfo > m_contactList;
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspGetContact::Size() const
{
    uint32_t nSize = 17;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].Size();
    }
    return nSize;
}

class CCntReqChgContact : public CPackData
{
public:
    CCntReqChgContact()
    {
    }

    ~CCntReqChgContact() { }
    CCntReqChgContact(const vector< SChgContactInfo >&  vecContactList)
    {
        m_contactList = vecContactList;
    }
    CCntReqChgContact&  operator=( const CCntReqChgContact&  cCntReqChgContact )
    {
        m_contactList = cCntReqChgContact.m_contactList;
        return *this;
    }

    const vector< SChgContactInfo >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< SChgContactInfo >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
private:
    vector< SChgContactInfo > m_contactList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqChgContact::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].Size();
    }
    return nSize;
}

class CCntRspChgContact : public CPackData
{
public:
    CCntRspChgContact()
    {
    }

    ~CCntRspChgContact() { }
    CCntRspChgContact(const uint32_t&  dwRetcode, const vector< SChgContactInfo >&  vecContactList, const uint32_t&  dwTimestamp)
    {
        m_retcode = dwRetcode;
        m_contactList = vecContactList;
        m_timestamp = dwTimestamp;
    }
    CCntRspChgContact&  operator=( const CCntRspChgContact&  cCntRspChgContact )
    {
        m_retcode = cCntRspChgContact.m_retcode;
        m_contactList = cCntRspChgContact.m_contactList;
        m_timestamp = cCntRspChgContact.m_timestamp;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SChgContactInfo >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< SChgContactInfo >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SChgContactInfo > m_contactList;
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspChgContact::Size() const
{
    uint32_t nSize = 17;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].Size();
    }
    return nSize;
}

class CCntReqDelContact : public CPackData
{
public:
    CCntReqDelContact()
    {
    }

    ~CCntReqDelContact() { }
    CCntReqDelContact(const vector< string >&  vecContactList)
    {
        m_contactList = vecContactList;
    }
    CCntReqDelContact&  operator=( const CCntReqDelContact&  cCntReqDelContact )
    {
        m_contactList = cCntReqDelContact.m_contactList;
        return *this;
    }

    const vector< string >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< string >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
private:
    vector< string > m_contactList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqDelContact::Size() const
{
    uint32_t nSize = 7;
    nSize += m_contactList.size() * 4;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].length();
    }
    return nSize;
}

class CCntRspDelContact : public CPackData
{
public:
    CCntRspDelContact()
    {
    }

    ~CCntRspDelContact() { }
    CCntRspDelContact(const uint32_t&  dwRetcode, const vector< string >&  vecContactList, const uint32_t&  dwTimestamp)
    {
        m_retcode = dwRetcode;
        m_contactList = vecContactList;
        m_timestamp = dwTimestamp;
    }
    CCntRspDelContact&  operator=( const CCntRspDelContact&  cCntRspDelContact )
    {
        m_retcode = cCntRspDelContact.m_retcode;
        m_contactList = cCntRspDelContact.m_contactList;
        m_timestamp = cCntRspDelContact.m_timestamp;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< string >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< string >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< string > m_contactList;
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspDelContact::Size() const
{
    uint32_t nSize = 17;
    nSize += m_contactList.size() * 4;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].length();
    }
    return nSize;
}

class CCntReqAddContact : public CPackData
{
public:
    CCntReqAddContact() : m_supportFlag(0)
    {
    }

    ~CCntReqAddContact() { }
    CCntReqAddContact(const SContactInfo&  sContact, const uint8_t&  chType, const string&  strMessage, const uint32_t&  dwSupportFlag= 0)
    {
        m_contact = sContact;
        m_type = chType;
        m_message = strMessage;
        m_supportFlag = dwSupportFlag;
    }
    CCntReqAddContact&  operator=( const CCntReqAddContact&  cCntReqAddContact )
    {
        m_contact = cCntReqAddContact.m_contact;
        m_type = cCntReqAddContact.m_type;
        m_message = cCntReqAddContact.m_message;
        m_supportFlag = cCntReqAddContact.m_supportFlag;
        return *this;
    }

    const SContactInfo&  GetContact () const { return m_contact; }
    bool SetContact ( const SContactInfo&  sContact )
    {
        m_contact = sContact;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const string&  GetMessage () const { return m_message; }
    bool SetMessage ( const string&  strMessage )
    {
        m_message = strMessage;
        return true;
    }
    const uint32_t&  GetSupportFlag () const { return m_supportFlag; }
    bool SetSupportFlag ( const uint32_t&  dwSupportFlag )
    {
        m_supportFlag = dwSupportFlag;
        return true;
    }
private:
    SContactInfo m_contact;
    uint8_t m_type;
    string m_message;
    uint32_t m_supportFlag;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqAddContact::Size() const
{
    uint32_t nSize = 14;
    nSize += m_contact.Size();
    nSize += m_message.length();
    return nSize;
}

class CCntRspAddContact : public CPackData
{
public:
    CCntRspAddContact() : m_question(""),
            m_answer("")
    {
    }

    ~CCntRspAddContact() { }
    CCntRspAddContact(const uint32_t&  dwRetcode, const uint8_t&  chType, const SContactInfo&  sContact, const uint32_t&  dwTimestamp, const string&  strCompanyname, const string&  strQuestion= "", const string&  strAnswer= "")
    {
        m_retcode = dwRetcode;
        m_type = chType;
        m_contact = sContact;
        m_timestamp = dwTimestamp;
        m_companyname = strCompanyname;
        m_question = strQuestion;
        m_answer = strAnswer;
    }
    CCntRspAddContact&  operator=( const CCntRspAddContact&  cCntRspAddContact )
    {
        m_retcode = cCntRspAddContact.m_retcode;
        m_type = cCntRspAddContact.m_type;
        m_contact = cCntRspAddContact.m_contact;
        m_timestamp = cCntRspAddContact.m_timestamp;
        m_companyname = cCntRspAddContact.m_companyname;
        m_question = cCntRspAddContact.m_question;
        m_answer = cCntRspAddContact.m_answer;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const SContactInfo&  GetContact () const { return m_contact; }
    bool SetContact ( const SContactInfo&  sContact )
    {
        m_contact = sContact;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
    const string&  GetCompanyname () const { return m_companyname; }
    bool SetCompanyname ( const string&  strCompanyname )
    {
        m_companyname = strCompanyname;
        return true;
    }
    const string&  GetQuestion () const { return m_question; }
    bool SetQuestion ( const string&  strQuestion )
    {
        m_question = strQuestion;
        return true;
    }
    const string&  GetAnswer () const { return m_answer; }
    bool SetAnswer ( const string&  strAnswer )
    {
        m_answer = strAnswer;
        return true;
    }
private:
    uint32_t m_retcode;
    uint8_t m_type;
    SContactInfo m_contact;
    uint32_t m_timestamp;
    string m_companyname;
    string m_question;
    string m_answer;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspAddContact::Size() const
{
    uint32_t nSize = 29;
    nSize += m_contact.Size();
    nSize += m_companyname.length();
    nSize += m_question.length();
    nSize += m_answer.length();
    return nSize;
}

class CCntReqAckContact : public CPackData
{
public:
    CCntReqAckContact()
    {
    }

    ~CCntReqAckContact() { }
    CCntReqAckContact(const uint8_t&  chOpcode, const string&  strContactId, const int64_t&  llGroupId, const string&  strNickName, const string&  strMessage)
    {
        m_opcode = chOpcode;
        m_contactId = strContactId;
        m_groupId = llGroupId;
        m_nickName = strNickName;
        m_message = strMessage;
    }
    CCntReqAckContact&  operator=( const CCntReqAckContact&  cCntReqAckContact )
    {
        m_opcode = cCntReqAckContact.m_opcode;
        m_contactId = cCntReqAckContact.m_contactId;
        m_groupId = cCntReqAckContact.m_groupId;
        m_nickName = cCntReqAckContact.m_nickName;
        m_message = cCntReqAckContact.m_message;
        return *this;
    }

    const uint8_t&  GetOpcode () const { return m_opcode; }
    bool SetOpcode ( const uint8_t&  chOpcode )
    {
        m_opcode = chOpcode;
        return true;
    }
    const string&  GetContactId () const { return m_contactId; }
    bool SetContactId ( const string&  strContactId )
    {
        if(strContactId.size() > 64) return false;
        m_contactId = strContactId;
        return true;
    }
    const int64_t&  GetGroupId () const { return m_groupId; }
    bool SetGroupId ( const int64_t&  llGroupId )
    {
        m_groupId = llGroupId;
        return true;
    }
    const string&  GetNickName () const { return m_nickName; }
    bool SetNickName ( const string&  strNickName )
    {
        m_nickName = strNickName;
        return true;
    }
    const string&  GetMessage () const { return m_message; }
    bool SetMessage ( const string&  strMessage )
    {
        m_message = strMessage;
        return true;
    }
private:
    uint8_t m_opcode;
    string m_contactId;
    int64_t m_groupId;
    string m_nickName;
    string m_message;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqAckContact::Size() const
{
    uint32_t nSize = 27;
    nSize += m_contactId.length();
    nSize += m_nickName.length();
    nSize += m_message.length();
    return nSize;
}

class CCntRspAckContact : public CPackData
{
public:
    CCntRspAckContact()
    {
    }

    ~CCntRspAckContact() { }
    CCntRspAckContact(const uint32_t&  dwRetcode, const uint8_t&  chOpcode, const int64_t&  llGroupId, const uint32_t&  dwTimestamp, const string&  strContactId)
    {
        m_retcode = dwRetcode;
        m_opcode = chOpcode;
        m_groupId = llGroupId;
        m_timestamp = dwTimestamp;
        m_contactId = strContactId;
    }
    CCntRspAckContact&  operator=( const CCntRspAckContact&  cCntRspAckContact )
    {
        m_retcode = cCntRspAckContact.m_retcode;
        m_opcode = cCntRspAckContact.m_opcode;
        m_groupId = cCntRspAckContact.m_groupId;
        m_timestamp = cCntRspAckContact.m_timestamp;
        m_contactId = cCntRspAckContact.m_contactId;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const uint8_t&  GetOpcode () const { return m_opcode; }
    bool SetOpcode ( const uint8_t&  chOpcode )
    {
        m_opcode = chOpcode;
        return true;
    }
    const int64_t&  GetGroupId () const { return m_groupId; }
    bool SetGroupId ( const int64_t&  llGroupId )
    {
        m_groupId = llGroupId;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
    const string&  GetContactId () const { return m_contactId; }
    bool SetContactId ( const string&  strContactId )
    {
        if(strContactId.size() > 64) return false;
        m_contactId = strContactId;
        return true;
    }
private:
    uint32_t m_retcode;
    uint8_t m_opcode;
    int64_t m_groupId;
    uint32_t m_timestamp;
    string m_contactId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspAckContact::Size() const
{
    uint32_t nSize = 27;
    nSize += m_contactId.length();
    return nSize;
}

class CCntReqGetGroup : public CPackData
{
public:
    CCntReqGetGroup()
    {
    }

    ~CCntReqGetGroup() { }
    CCntReqGetGroup(const uint32_t&  dwTimestamp)
    {
        m_timestamp = dwTimestamp;
    }
    CCntReqGetGroup&  operator=( const CCntReqGetGroup&  cCntReqGetGroup )
    {
        m_timestamp = cCntReqGetGroup.m_timestamp;
        return *this;
    }

    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqGetGroup::Size() const
{
    return 6;
}
class CCntRspGetGroup : public CPackData
{
public:
    CCntRspGetGroup()
    {
    }

    ~CCntRspGetGroup() { }
    CCntRspGetGroup(const uint32_t&  dwRetcode, const vector< SUserGroup >&  vecGroupList, const uint32_t&  dwTimestamp)
    {
        m_retcode = dwRetcode;
        m_groupList = vecGroupList;
        m_timestamp = dwTimestamp;
    }
    CCntRspGetGroup&  operator=( const CCntRspGetGroup&  cCntRspGetGroup )
    {
        m_retcode = cCntRspGetGroup.m_retcode;
        m_groupList = cCntRspGetGroup.m_groupList;
        m_timestamp = cCntRspGetGroup.m_timestamp;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SUserGroup >&  GetGroupList () const { return m_groupList; }
    bool SetGroupList ( const vector< SUserGroup >&  vecGroupList )
    {
        m_groupList = vecGroupList;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SUserGroup > m_groupList;
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspGetGroup::Size() const
{
    uint32_t nSize = 17;
    for(uint32_t i = 0; i < m_groupList.size(); i++)
    {
        nSize += m_groupList[i].Size();
    }
    return nSize;
}

struct SReadTimes
{
public:
    SReadTimes() : m_msgid(0)
    {
    }

    ~SReadTimes() { }
    SReadTimes(const string&  strContact, const uint32_t&  dwTimestamp, const uint32_t&  dwMsgCount, const int64_t&  llLastmsgTime, const string &  strLastMessage, const uint64_t&  ullMsgid= 0)
    {
        m_contact = strContact;
        m_timestamp = dwTimestamp;
        m_msgCount = dwMsgCount;
        m_lastmsgTime = llLastmsgTime;
        m_lastMessage = strLastMessage;
        m_msgid = ullMsgid;
    }
    SReadTimes&  operator=( const SReadTimes&  sReadTimes )
    {
        m_contact = sReadTimes.m_contact;
        m_timestamp = sReadTimes.m_timestamp;
        m_msgCount = sReadTimes.m_msgCount;
        m_lastmsgTime = sReadTimes.m_lastmsgTime;
        m_lastMessage = sReadTimes.m_lastMessage;
        m_msgid = sReadTimes.m_msgid;
        return *this;
    }

    string m_contact;
    uint32_t m_timestamp;
    uint32_t m_msgCount;
    int64_t m_lastmsgTime;
    string  m_lastMessage;
    uint64_t m_msgid;

public:
    uint32_t Size() const;
};

inline uint32_t SReadTimes::Size() const
{
    uint32_t nSize = 39;
    nSize += m_contact.length();
    nSize += m_lastMessage.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SReadTimes&  sReadTimes );
CPackData& operator>> ( CPackData& cPackData, SReadTimes&  sReadTimes );

class CImReqReadTimes : public CPackData
{
public:
    ~CImReqReadTimes() { }
    CImReqReadTimes(const uint32_t&  dwMaxRecords= 20, const uint32_t&  dwFlag= 0)
    {
        m_maxRecords = dwMaxRecords;
        m_flag = dwFlag;
    }
    CImReqReadTimes&  operator=( const CImReqReadTimes&  cImReqReadTimes )
    {
        m_maxRecords = cImReqReadTimes.m_maxRecords;
        m_flag = cImReqReadTimes.m_flag;
        return *this;
    }

    const uint32_t&  GetMaxRecords () const { return m_maxRecords; }
    bool SetMaxRecords ( const uint32_t&  dwMaxRecords )
    {
        m_maxRecords = dwMaxRecords;
        return true;
    }
    const uint32_t&  GetFlag () const { return m_flag; }
    bool SetFlag ( const uint32_t&  dwFlag )
    {
        m_flag = dwFlag;
        return true;
    }
private:
    uint32_t m_maxRecords;
    uint32_t m_flag;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqReadTimes::Size() const
{
    return 11;
}
class CImRspReadTimes : public CPackData
{
public:
    CImRspReadTimes()
    {
    }

    ~CImRspReadTimes() { }
    CImRspReadTimes(const uint32_t&  dwRetcode, const vector< SReadTimes >&  vecReadTimesList)
    {
        m_retcode = dwRetcode;
        m_readTimesList = vecReadTimesList;
    }
    CImRspReadTimes&  operator=( const CImRspReadTimes&  cImRspReadTimes )
    {
        m_retcode = cImRspReadTimes.m_retcode;
        m_readTimesList = cImRspReadTimes.m_readTimesList;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SReadTimes >&  GetReadTimesList () const { return m_readTimesList; }
    bool SetReadTimesList ( const vector< SReadTimes >&  vecReadTimesList )
    {
        m_readTimesList = vecReadTimesList;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SReadTimes > m_readTimesList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspReadTimes::Size() const
{
    uint32_t nSize = 12;
    for(uint32_t i = 0; i < m_readTimesList.size(); i++)
    {
        nSize += m_readTimesList[i].Size();
    }
    return nSize;
}

class CImReqMessageRead : public CPackData
{
public:
    CImReqMessageRead() : m_flag(0)
    {
    }

    ~CImReqMessageRead() { }
    CImReqMessageRead(const SReadTimes&  sReadTimes, const uint32_t&  dwFlag= 0)
    {
        m_readTimes = sReadTimes;
        m_flag = dwFlag;
    }
    CImReqMessageRead&  operator=( const CImReqMessageRead&  cImReqMessageRead )
    {
        m_readTimes = cImReqMessageRead.m_readTimes;
        m_flag = cImReqMessageRead.m_flag;
        return *this;
    }

    const SReadTimes&  GetReadTimes () const { return m_readTimes; }
    bool SetReadTimes ( const SReadTimes&  sReadTimes )
    {
        m_readTimes = sReadTimes;
        return true;
    }
    const uint32_t&  GetFlag () const { return m_flag; }
    bool SetFlag ( const uint32_t&  dwFlag )
    {
        m_flag = dwFlag;
        return true;
    }
private:
    SReadTimes m_readTimes;
    uint32_t m_flag;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqMessageRead::Size() const
{
    uint32_t nSize = 7;
    nSize += m_readTimes.Size();
    return nSize;
}

class CImReqBatchMessageRead : public CPackData
{
public:
    CImReqBatchMessageRead()
    {
    }

    ~CImReqBatchMessageRead() { }
    CImReqBatchMessageRead(const vector< SReadTimes >&  vecReadTimesList)
    {
        m_readTimesList = vecReadTimesList;
    }
    CImReqBatchMessageRead&  operator=( const CImReqBatchMessageRead&  cImReqBatchMessageRead )
    {
        m_readTimesList = cImReqBatchMessageRead.m_readTimesList;
        return *this;
    }

    const vector< SReadTimes >&  GetReadTimesList () const { return m_readTimesList; }
    bool SetReadTimesList ( const vector< SReadTimes >&  vecReadTimesList )
    {
        m_readTimesList = vecReadTimesList;
        return true;
    }
private:
    vector< SReadTimes > m_readTimesList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqBatchMessageRead::Size() const
{
    uint32_t nSize = 7;
    for(uint32_t i = 0; i < m_readTimesList.size(); i++)
    {
        nSize += m_readTimesList[i].Size();
    }
    return nSize;
}

class CImNtfMessageRead : public CPackData
{
public:
    CImNtfMessageRead()
    {
    }

    ~CImNtfMessageRead() { }
    CImNtfMessageRead(const SReadTimes&  sReadTimes)
    {
        m_readTimes = sReadTimes;
    }
    CImNtfMessageRead&  operator=( const CImNtfMessageRead&  cImNtfMessageRead )
    {
        m_readTimes = cImNtfMessageRead.m_readTimes;
        return *this;
    }

    const SReadTimes&  GetReadTimes () const { return m_readTimes; }
    bool SetReadTimes ( const SReadTimes&  sReadTimes )
    {
        m_readTimes = sReadTimes;
        return true;
    }
private:
    SReadTimes m_readTimes;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfMessageRead::Size() const
{
    uint32_t nSize = 2;
    nSize += m_readTimes.Size();
    return nSize;
}

class CCntReqGetblack : public CPackData
{
public:
    CCntReqGetblack() : m_reqCount(100),
            m_version(1)
    {
    }

    ~CCntReqGetblack() { }
    CCntReqGetblack(const uint32_t&  dwTimestamp, const uint32_t&  dwCount, const uint32_t&  dwReqCount= 100, const uint32_t&  dwVersion= 1)
    {
        m_timestamp = dwTimestamp;
        m_count = dwCount;
        m_reqCount = dwReqCount;
        m_version = dwVersion;
    }
    CCntReqGetblack&  operator=( const CCntReqGetblack&  cCntReqGetblack )
    {
        m_timestamp = cCntReqGetblack.m_timestamp;
        m_count = cCntReqGetblack.m_count;
        m_reqCount = cCntReqGetblack.m_reqCount;
        m_version = cCntReqGetblack.m_version;
        return *this;
    }

    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
    const uint32_t&  GetCount () const { return m_count; }
    bool SetCount ( const uint32_t&  dwCount )
    {
        m_count = dwCount;
        return true;
    }
    const uint32_t&  GetReqCount () const { return m_reqCount; }
    bool SetReqCount ( const uint32_t&  dwReqCount )
    {
        m_reqCount = dwReqCount;
        return true;
    }
    const uint32_t&  GetVersion () const { return m_version; }
    bool SetVersion ( const uint32_t&  dwVersion )
    {
        m_version = dwVersion;
        return true;
    }
private:
    uint32_t m_timestamp;
    uint32_t m_count;
    uint32_t m_reqCount;
    uint32_t m_version;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqGetblack::Size() const
{
    return 21;
}
class CCntRspGetblack : public CPackData
{
public:
    CCntRspGetblack() : m_totalCount(0)
    {
    }

    ~CCntRspGetblack() { }
    CCntRspGetblack(const uint32_t&  dwRetcode, const vector< string >&  vecBlackList, const uint32_t&  dwTimestamp, const uint32_t&  dwTotalCount= 0)
    {
        m_retcode = dwRetcode;
        m_blackList = vecBlackList;
        m_timestamp = dwTimestamp;
        m_totalCount = dwTotalCount;
    }
    CCntRspGetblack&  operator=( const CCntRspGetblack&  cCntRspGetblack )
    {
        m_retcode = cCntRspGetblack.m_retcode;
        m_blackList = cCntRspGetblack.m_blackList;
        m_timestamp = cCntRspGetblack.m_timestamp;
        m_totalCount = cCntRspGetblack.m_totalCount;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< string >&  GetBlackList () const { return m_blackList; }
    bool SetBlackList ( const vector< string >&  vecBlackList )
    {
        m_blackList = vecBlackList;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
    const uint32_t&  GetTotalCount () const { return m_totalCount; }
    bool SetTotalCount ( const uint32_t&  dwTotalCount )
    {
        m_totalCount = dwTotalCount;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< string > m_blackList;
    uint32_t m_timestamp;
    uint32_t m_totalCount;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspGetblack::Size() const
{
    uint32_t nSize = 22;
    nSize += m_blackList.size() * 4;
    for(uint32_t i = 0; i < m_blackList.size(); i++)
    {
        nSize += m_blackList[i].length();
    }
    return nSize;
}

class CCntReqAddblack : public CPackData
{
public:
    CCntReqAddblack() : m_flag(0),
            m_msg("")
    {
    }

    ~CCntReqAddblack() { }
    CCntReqAddblack(const string&  strBlackId, const uint8_t&  chFlag= 0, const string&  strMsg= "")
    {
        m_blackId = strBlackId;
        m_flag = chFlag;
        m_msg = strMsg;
    }
    CCntReqAddblack&  operator=( const CCntReqAddblack&  cCntReqAddblack )
    {
        m_blackId = cCntReqAddblack.m_blackId;
        m_flag = cCntReqAddblack.m_flag;
        m_msg = cCntReqAddblack.m_msg;
        return *this;
    }

    const string&  GetBlackId () const { return m_blackId; }
    bool SetBlackId ( const string&  strBlackId )
    {
        if(strBlackId.size() > 64) return false;
        m_blackId = strBlackId;
        return true;
    }
    const uint8_t&  GetFlag () const { return m_flag; }
    bool SetFlag ( const uint8_t&  chFlag )
    {
        m_flag = chFlag;
        return true;
    }
    const string&  GetMsg () const { return m_msg; }
    bool SetMsg ( const string&  strMsg )
    {
        m_msg = strMsg;
        return true;
    }
private:
    string m_blackId;
    uint8_t m_flag;
    string m_msg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqAddblack::Size() const
{
    uint32_t nSize = 13;
    nSize += m_blackId.length();
    nSize += m_msg.length();
    return nSize;
}

class CCntRspAddblack : public CPackData
{
public:
    CCntRspAddblack()
    {
    }

    ~CCntRspAddblack() { }
    CCntRspAddblack(const uint32_t&  dwRetcode, const string&  strBlackId, const uint32_t&  dwTimestamp)
    {
        m_retcode = dwRetcode;
        m_blackId = strBlackId;
        m_timestamp = dwTimestamp;
    }
    CCntRspAddblack&  operator=( const CCntRspAddblack&  cCntRspAddblack )
    {
        m_retcode = cCntRspAddblack.m_retcode;
        m_blackId = cCntRspAddblack.m_blackId;
        m_timestamp = cCntRspAddblack.m_timestamp;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetBlackId () const { return m_blackId; }
    bool SetBlackId ( const string&  strBlackId )
    {
        if(strBlackId.size() > 64) return false;
        m_blackId = strBlackId;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_blackId;
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspAddblack::Size() const
{
    uint32_t nSize = 16;
    nSize += m_blackId.length();
    return nSize;
}

class CCntReqDelblack : public CPackData
{
public:
    CCntReqDelblack() : m_flag(0),
            m_msg("")
    {
    }

    ~CCntReqDelblack() { }
    CCntReqDelblack(const string&  strBlackId, const uint32_t&  dwFlag= 0, const string&  strMsg= "")
    {
        m_blackId = strBlackId;
        m_flag = dwFlag;
        m_msg = strMsg;
    }
    CCntReqDelblack&  operator=( const CCntReqDelblack&  cCntReqDelblack )
    {
        m_blackId = cCntReqDelblack.m_blackId;
        m_flag = cCntReqDelblack.m_flag;
        m_msg = cCntReqDelblack.m_msg;
        return *this;
    }

    const string&  GetBlackId () const { return m_blackId; }
    bool SetBlackId ( const string&  strBlackId )
    {
        if(strBlackId.size() > 64) return false;
        m_blackId = strBlackId;
        return true;
    }
    const uint32_t&  GetFlag () const { return m_flag; }
    bool SetFlag ( const uint32_t&  dwFlag )
    {
        m_flag = dwFlag;
        return true;
    }
    const string&  GetMsg () const { return m_msg; }
    bool SetMsg ( const string&  strMsg )
    {
        m_msg = strMsg;
        return true;
    }
private:
    string m_blackId;
    uint32_t m_flag;
    string m_msg;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqDelblack::Size() const
{
    uint32_t nSize = 16;
    nSize += m_blackId.length();
    nSize += m_msg.length();
    return nSize;
}

class CCntRspDelblack : public CPackData
{
public:
    CCntRspDelblack()
    {
    }

    ~CCntRspDelblack() { }
    CCntRspDelblack(const uint32_t&  dwRetcode, const string&  strBlackId, const uint32_t&  dwTimestamp)
    {
        m_retcode = dwRetcode;
        m_blackId = strBlackId;
        m_timestamp = dwTimestamp;
    }
    CCntRspDelblack&  operator=( const CCntRspDelblack&  cCntRspDelblack )
    {
        m_retcode = cCntRspDelblack.m_retcode;
        m_blackId = cCntRspDelblack.m_blackId;
        m_timestamp = cCntRspDelblack.m_timestamp;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const string&  GetBlackId () const { return m_blackId; }
    bool SetBlackId ( const string&  strBlackId )
    {
        if(strBlackId.size() > 64) return false;
        m_blackId = strBlackId;
        return true;
    }
    const uint32_t&  GetTimestamp () const { return m_timestamp; }
    bool SetTimestamp ( const uint32_t&  dwTimestamp )
    {
        m_timestamp = dwTimestamp;
        return true;
    }
private:
    uint32_t m_retcode;
    string m_blackId;
    uint32_t m_timestamp;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspDelblack::Size() const
{
    uint32_t nSize = 16;
    nSize += m_blackId.length();
    return nSize;
}

class CCntReqSearchLatentContact : public CPackData
{
public:
    CCntReqSearchLatentContact() : m_longitude(0),
            m_latitude(0)
    {
    }

    ~CCntReqSearchLatentContact() { }
    CCntReqSearchLatentContact(const uint32_t&  dwAction, const double&  dLongitude= 0, const double&  dLatitude= 0)
    {
        m_action = dwAction;
        m_longitude = dLongitude;
        m_latitude = dLatitude;
    }
    CCntReqSearchLatentContact&  operator=( const CCntReqSearchLatentContact&  cCntReqSearchLatentContact )
    {
        m_action = cCntReqSearchLatentContact.m_action;
        m_longitude = cCntReqSearchLatentContact.m_longitude;
        m_latitude = cCntReqSearchLatentContact.m_latitude;
        return *this;
    }

    const uint32_t&  GetAction () const { return m_action; }
    bool SetAction ( const uint32_t&  dwAction )
    {
        m_action = dwAction;
        return true;
    }
    const double&  GetLongitude () const { return m_longitude; }
    bool SetLongitude ( const double&  dLongitude )
    {
        m_longitude = dLongitude;
        return true;
    }
    const double&  GetLatitude () const { return m_latitude; }
    bool SetLatitude ( const double&  dLatitude )
    {
        m_latitude = dLatitude;
        return true;
    }
private:
    uint32_t m_action;
    double m_longitude;
    double m_latitude;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntReqSearchLatentContact::Size() const
{
    return 24;
}
class CCntRspSearchLatentContact : public CPackData
{
public:
    CCntRspSearchLatentContact()
    {
    }

    ~CCntRspSearchLatentContact() { }
    CCntRspSearchLatentContact(const uint32_t&  dwRetcode, const vector< SLatentContact >&  vecContactList)
    {
        m_retcode = dwRetcode;
        m_contactList = vecContactList;
    }
    CCntRspSearchLatentContact&  operator=( const CCntRspSearchLatentContact&  cCntRspSearchLatentContact )
    {
        m_retcode = cCntRspSearchLatentContact.m_retcode;
        m_contactList = cCntRspSearchLatentContact.m_contactList;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
    const vector< SLatentContact >&  GetContactList () const { return m_contactList; }
    bool SetContactList ( const vector< SLatentContact >&  vecContactList )
    {
        m_contactList = vecContactList;
        return true;
    }
private:
    uint32_t m_retcode;
    vector< SLatentContact > m_contactList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CCntRspSearchLatentContact::Size() const
{
    uint32_t nSize = 12;
    for(uint32_t i = 0; i < m_contactList.size(); i++)
    {
        nSize += m_contactList[i].Size();
    }
    return nSize;
}

struct SLogonSessionInfo
{
public:
    SLogonSessionInfo()
    {
    }

    ~SLogonSessionInfo() { }
    SLogonSessionInfo(const uint8_t&  chAppId, const uint8_t&  chDevtype, const uint8_t&  chStatus, const uint8_t&  chExtraFlag, const string&  strVersion, const string&  strRemark)
    {
        m_appId = chAppId;
        m_devtype = chDevtype;
        m_status = chStatus;
        m_extraFlag = chExtraFlag;
        m_version = strVersion;
        m_remark = strRemark;
    }
    SLogonSessionInfo&  operator=( const SLogonSessionInfo&  sLogonSessionInfo )
    {
        m_appId = sLogonSessionInfo.m_appId;
        m_devtype = sLogonSessionInfo.m_devtype;
        m_status = sLogonSessionInfo.m_status;
        m_extraFlag = sLogonSessionInfo.m_extraFlag;
        m_version = sLogonSessionInfo.m_version;
        m_remark = sLogonSessionInfo.m_remark;
        return *this;
    }

    uint8_t m_appId;
    uint8_t m_devtype;
    uint8_t m_status;
    uint8_t m_extraFlag;
    string m_version;
    string m_remark;

public:
    uint32_t Size() const;
};

inline uint32_t SLogonSessionInfo::Size() const
{
    uint32_t nSize = 19;
    nSize += m_version.length();
    nSize += m_remark.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SLogonSessionInfo&  sLogonSessionInfo );
CPackData& operator>> ( CPackData& cPackData, SLogonSessionInfo&  sLogonSessionInfo );

class CImReqGetLogonInfo : public CPackData
{
public:
    ~CImReqGetLogonInfo() { }
public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqGetLogonInfo::Size() const
{
    return 1;
}
class CImRspGetLogonInfo : public CPackData
{
public:
    CImRspGetLogonInfo()
    {
    }

    ~CImRspGetLogonInfo() { }
    CImRspGetLogonInfo(const uint8_t&  chRetcode, const vector< SLogonSessionInfo >&  vecSessionList)
    {
        m_retcode = chRetcode;
        m_sessionList = vecSessionList;
    }
    CImRspGetLogonInfo&  operator=( const CImRspGetLogonInfo&  cImRspGetLogonInfo )
    {
        m_retcode = cImRspGetLogonInfo.m_retcode;
        m_sessionList = cImRspGetLogonInfo.m_sessionList;
        return *this;
    }

    const uint8_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint8_t&  chRetcode )
    {
        m_retcode = chRetcode;
        return true;
    }
    const vector< SLogonSessionInfo >&  GetSessionList () const { return m_sessionList; }
    bool SetSessionList ( const vector< SLogonSessionInfo >&  vecSessionList )
    {
        m_sessionList = vecSessionList;
        return true;
    }
private:
    uint8_t m_retcode;
    vector< SLogonSessionInfo > m_sessionList;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspGetLogonInfo::Size() const
{
    uint32_t nSize = 9;
    for(uint32_t i = 0; i < m_sessionList.size(); i++)
    {
        nSize += m_sessionList[i].Size();
    }
    return nSize;
}

class CImReportNetworkStatus : public CPackData
{
public:
    CImReportNetworkStatus()
    {
    }

    ~CImReportNetworkStatus() { }
    CImReportNetworkStatus(const string&  strUid, const uint8_t&  chDevtype, const string&  strStatus)
    {
        m_uid = strUid;
        m_devtype = chDevtype;
        m_status = strStatus;
    }
    CImReportNetworkStatus&  operator=( const CImReportNetworkStatus&  cImReportNetworkStatus )
    {
        m_uid = cImReportNetworkStatus.m_uid;
        m_devtype = cImReportNetworkStatus.m_devtype;
        m_status = cImReportNetworkStatus.m_status;
        return *this;
    }

    const string&  GetUid () const { return m_uid; }
    bool SetUid ( const string&  strUid )
    {
        if(strUid.size() > 64) return false;
        m_uid = strUid;
        return true;
    }
    const uint8_t&  GetDevtype () const { return m_devtype; }
    bool SetDevtype ( const uint8_t&  chDevtype )
    {
        m_devtype = chDevtype;
        return true;
    }
    const string&  GetStatus () const { return m_status; }
    bool SetStatus ( const string&  strStatus )
    {
        m_status = strStatus;
        return true;
    }
private:
    string m_uid;
    uint8_t m_devtype;
    string m_status;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReportNetworkStatus::Size() const
{
    uint32_t nSize = 13;
    nSize += m_uid.length();
    nSize += m_status.length();
    return nSize;
}

struct SVoipMessageBody
{
public:
    SVoipMessageBody()
    {
    }

    ~SVoipMessageBody() { }
    SVoipMessageBody(const map< string,string >&  mapSipMsg)
    {
        m_sipMsg = mapSipMsg;
    }
    SVoipMessageBody&  operator=( const SVoipMessageBody&  sVoipMessageBody )
    {
        m_sipMsg = sVoipMessageBody.m_sipMsg;
        return *this;
    }

    map< string,string > m_sipMsg;

public:
    uint32_t Size() const;
};

inline uint32_t SVoipMessageBody::Size() const
{
    uint32_t nSize = 5;
    nSize += m_sipMsg.size() * 8;
    {
        map< string,string >::const_iterator itr;
        for(itr = m_sipMsg.begin(); itr != m_sipMsg.end(); ++itr)
        {
            nSize += itr->first.length();
            nSize += itr->second.length();
        }
    }
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SVoipMessageBody&  sVoipMessageBody );
CPackData& operator>> ( CPackData& cPackData, SVoipMessageBody&  sVoipMessageBody );

class CImReqFwdMsg : public CPackData
{
public:
    CImReqFwdMsg()
    {
    }

    ~CImReqFwdMsg() { }
    CImReqFwdMsg(const string&  strFromid, const string&  strToid, const int64_t&  llMsgid, const uint8_t&  chType, const string&  strMessage)
    {
        m_fromid = strFromid;
        m_toid = strToid;
        m_msgid = llMsgid;
        m_type = chType;
        m_message = strMessage;
    }
    CImReqFwdMsg&  operator=( const CImReqFwdMsg&  cImReqFwdMsg )
    {
        m_fromid = cImReqFwdMsg.m_fromid;
        m_toid = cImReqFwdMsg.m_toid;
        m_msgid = cImReqFwdMsg.m_msgid;
        m_type = cImReqFwdMsg.m_type;
        m_message = cImReqFwdMsg.m_message;
        return *this;
    }

    const string&  GetFromid () const { return m_fromid; }
    bool SetFromid ( const string&  strFromid )
    {
        if(strFromid.size() > 64) return false;
        m_fromid = strFromid;
        return true;
    }
    const string&  GetToid () const { return m_toid; }
    bool SetToid ( const string&  strToid )
    {
        if(strToid.size() > 64) return false;
        m_toid = strToid;
        return true;
    }
    const int64_t&  GetMsgid () const { return m_msgid; }
    bool SetMsgid ( const int64_t&  llMsgid )
    {
        m_msgid = llMsgid;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const string&  GetMessage () const { return m_message; }
    bool SetMessage ( const string&  strMessage )
    {
        m_message = strMessage;
        return true;
    }
private:
    string m_fromid;
    string m_toid;
    int64_t m_msgid;
    uint8_t m_type;
    string m_message;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqFwdMsg::Size() const
{
    uint32_t nSize = 27;
    nSize += m_fromid.length();
    nSize += m_toid.length();
    nSize += m_message.length();
    return nSize;
}

class CImRspFwdMsg : public CPackData
{
public:
    CImRspFwdMsg()
    {
    }

    ~CImRspFwdMsg() { }
    CImRspFwdMsg(const string&  strFromid, const string&  strToid, const int64_t&  llMsgid)
    {
        m_fromid = strFromid;
        m_toid = strToid;
        m_msgid = llMsgid;
    }
    CImRspFwdMsg&  operator=( const CImRspFwdMsg&  cImRspFwdMsg )
    {
        m_fromid = cImRspFwdMsg.m_fromid;
        m_toid = cImRspFwdMsg.m_toid;
        m_msgid = cImRspFwdMsg.m_msgid;
        return *this;
    }

    const string&  GetFromid () const { return m_fromid; }
    bool SetFromid ( const string&  strFromid )
    {
        if(strFromid.size() > 64) return false;
        m_fromid = strFromid;
        return true;
    }
    const string&  GetToid () const { return m_toid; }
    bool SetToid ( const string&  strToid )
    {
        if(strToid.size() > 64) return false;
        m_toid = strToid;
        return true;
    }
    const int64_t&  GetMsgid () const { return m_msgid; }
    bool SetMsgid ( const int64_t&  llMsgid )
    {
        m_msgid = llMsgid;
        return true;
    }
private:
    string m_fromid;
    string m_toid;
    int64_t m_msgid;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspFwdMsg::Size() const
{
    uint32_t nSize = 20;
    nSize += m_fromid.length();
    nSize += m_toid.length();
    return nSize;
}

class CImNtfFwdMsg : public CPackData
{
public:
    CImNtfFwdMsg()
    {
    }

    ~CImNtfFwdMsg() { }
    CImNtfFwdMsg(const string&  strFromid, const string&  strToid, const int64_t&  llMsgid, const uint8_t&  chType, const string&  strMessage)
    {
        m_fromid = strFromid;
        m_toid = strToid;
        m_msgid = llMsgid;
        m_type = chType;
        m_message = strMessage;
    }
    CImNtfFwdMsg&  operator=( const CImNtfFwdMsg&  cImNtfFwdMsg )
    {
        m_fromid = cImNtfFwdMsg.m_fromid;
        m_toid = cImNtfFwdMsg.m_toid;
        m_msgid = cImNtfFwdMsg.m_msgid;
        m_type = cImNtfFwdMsg.m_type;
        m_message = cImNtfFwdMsg.m_message;
        return *this;
    }

    const string&  GetFromid () const { return m_fromid; }
    bool SetFromid ( const string&  strFromid )
    {
        if(strFromid.size() > 64) return false;
        m_fromid = strFromid;
        return true;
    }
    const string&  GetToid () const { return m_toid; }
    bool SetToid ( const string&  strToid )
    {
        if(strToid.size() > 64) return false;
        m_toid = strToid;
        return true;
    }
    const int64_t&  GetMsgid () const { return m_msgid; }
    bool SetMsgid ( const int64_t&  llMsgid )
    {
        m_msgid = llMsgid;
        return true;
    }
    const uint8_t&  GetType () const { return m_type; }
    bool SetType ( const uint8_t&  chType )
    {
        m_type = chType;
        return true;
    }
    const string&  GetMessage () const { return m_message; }
    bool SetMessage ( const string&  strMessage )
    {
        m_message = strMessage;
        return true;
    }
private:
    string m_fromid;
    string m_toid;
    int64_t m_msgid;
    uint8_t m_type;
    string m_message;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfFwdMsg::Size() const
{
    uint32_t nSize = 27;
    nSize += m_fromid.length();
    nSize += m_toid.length();
    nSize += m_message.length();
    return nSize;
}

class CImReqRenewal : public CPackData
{
public:
    CImReqRenewal()
    {
    }

    ~CImReqRenewal() { }
    CImReqRenewal(const string&  strUserId)
    {
        m_userId = strUserId;
    }
    CImReqRenewal&  operator=( const CImReqRenewal&  cImReqRenewal )
    {
        m_userId = cImReqRenewal.m_userId;
        return *this;
    }

    const string&  GetUserId () const { return m_userId; }
    bool SetUserId ( const string&  strUserId )
    {
        m_userId = strUserId;
        return true;
    }
private:
    string m_userId;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqRenewal::Size() const
{
    uint32_t nSize = 6;
    nSize += m_userId.length();
    return nSize;
}

class CImRspRenewal : public CPackData
{
public:
    CImRspRenewal()
    {
    }

    ~CImRspRenewal() { }
    CImRspRenewal(const uint32_t&  dwRetcode)
    {
        m_retcode = dwRetcode;
    }
    CImRspRenewal&  operator=( const CImRspRenewal&  cImRspRenewal )
    {
        m_retcode = cImRspRenewal.m_retcode;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
private:
    uint32_t m_retcode;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspRenewal::Size() const
{
    return 6;
}
class CImReqSubBiz : public CPackData
{
public:
    CImReqSubBiz()
    {
    }

    ~CImReqSubBiz() { }
    CImReqSubBiz(const vector< uint32_t >&  vecBizIds, const string&  strVersion)
    {
        m_bizIds = vecBizIds;
        m_version = strVersion;
    }
    CImReqSubBiz&  operator=( const CImReqSubBiz&  cImReqSubBiz )
    {
        m_bizIds = cImReqSubBiz.m_bizIds;
        m_version = cImReqSubBiz.m_version;
        return *this;
    }

    const vector< uint32_t >&  GetBizIds () const { return m_bizIds; }
    bool SetBizIds ( const vector< uint32_t >&  vecBizIds )
    {
        m_bizIds = vecBizIds;
        return true;
    }
    const string&  GetVersion () const { return m_version; }
    bool SetVersion ( const string&  strVersion )
    {
        m_version = strVersion;
        return true;
    }
private:
    vector< uint32_t > m_bizIds;
    string m_version;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqSubBiz::Size() const
{
    uint32_t nSize = 12;
    nSize += m_bizIds.size() * 4;
    nSize += m_version.length();
    return nSize;
}

class CImRspSubBiz : public CPackData
{
public:
    CImRspSubBiz()
    {
    }

    ~CImRspSubBiz() { }
    CImRspSubBiz(const uint32_t&  dwRetcode)
    {
        m_retcode = dwRetcode;
    }
    CImRspSubBiz&  operator=( const CImRspSubBiz&  cImRspSubBiz )
    {
        m_retcode = cImRspSubBiz.m_retcode;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
private:
    uint32_t m_retcode;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspSubBiz::Size() const
{
    return 6;
}
class CImReqUnsubBiz : public CPackData
{
public:
    CImReqUnsubBiz()
    {
    }

    ~CImReqUnsubBiz() { }
    CImReqUnsubBiz(const vector< uint32_t >&  vecBizIds)
    {
        m_bizIds = vecBizIds;
    }
    CImReqUnsubBiz&  operator=( const CImReqUnsubBiz&  cImReqUnsubBiz )
    {
        m_bizIds = cImReqUnsubBiz.m_bizIds;
        return *this;
    }

    const vector< uint32_t >&  GetBizIds () const { return m_bizIds; }
    bool SetBizIds ( const vector< uint32_t >&  vecBizIds )
    {
        m_bizIds = vecBizIds;
        return true;
    }
private:
    vector< uint32_t > m_bizIds;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImReqUnsubBiz::Size() const
{
    uint32_t nSize = 7;
    nSize += m_bizIds.size() * 4;
    return nSize;
}

class CImRspUnsubBiz : public CPackData
{
public:
    CImRspUnsubBiz()
    {
    }

    ~CImRspUnsubBiz() { }
    CImRspUnsubBiz(const uint32_t&  dwRetcode)
    {
        m_retcode = dwRetcode;
    }
    CImRspUnsubBiz&  operator=( const CImRspUnsubBiz&  cImRspUnsubBiz )
    {
        m_retcode = cImRspUnsubBiz.m_retcode;
        return *this;
    }

    const uint32_t&  GetRetcode () const { return m_retcode; }
    bool SetRetcode ( const uint32_t&  dwRetcode )
    {
        m_retcode = dwRetcode;
        return true;
    }
private:
    uint32_t m_retcode;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImRspUnsubBiz::Size() const
{
    return 6;
}
struct SScUserInfo
{
public:
    ~SScUserInfo() { }
    SScUserInfo(const string&  strUserId= "", const uint32_t&  dwFromApp= -1, const uint32_t&  dwBizId= -1, const uint32_t&  dwNotifyAppId= -1, const uint64_t&  ullUuid= -1)
    {
        m_userId = strUserId;
        m_fromApp = dwFromApp;
        m_bizId = dwBizId;
        m_notifyAppId = dwNotifyAppId;
        m_uuid = ullUuid;
    }
    SScUserInfo&  operator=( const SScUserInfo&  sScUserInfo )
    {
        m_userId = sScUserInfo.m_userId;
        m_fromApp = sScUserInfo.m_fromApp;
        m_bizId = sScUserInfo.m_bizId;
        m_notifyAppId = sScUserInfo.m_notifyAppId;
        m_uuid = sScUserInfo.m_uuid;
        return *this;
    }

    string m_userId;
    uint32_t m_fromApp;
    uint32_t m_bizId;
    uint32_t m_notifyAppId;
    uint64_t m_uuid;

public:
    uint32_t Size() const;
};

inline uint32_t SScUserInfo::Size() const
{
    uint32_t nSize = 30;
    nSize += m_userId.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SScUserInfo&  sScUserInfo );
CPackData& operator>> ( CPackData& cPackData, SScUserInfo&  sScUserInfo );

class CImNtfCommon : public CPackData
{
public:
    CImNtfCommon()
    {
    }

    ~CImNtfCommon() { }
    CImNtfCommon(const string&  strOperation, const string&  strData, const string&  strOrigPacket)
    {
        m_operation = strOperation;
        m_data = strData;
        m_origPacket = strOrigPacket;
    }
    CImNtfCommon&  operator=( const CImNtfCommon&  cImNtfCommon )
    {
        m_operation = cImNtfCommon.m_operation;
        m_data = cImNtfCommon.m_data;
        m_origPacket = cImNtfCommon.m_origPacket;
        return *this;
    }

    const string&  GetOperation () const { return m_operation; }
    bool SetOperation ( const string&  strOperation )
    {
        m_operation = strOperation;
        return true;
    }
    const string&  GetData () const { return m_data; }
    bool SetData ( const string&  strData )
    {
        m_data = strData;
        return true;
    }
    const string&  GetOrigPacket () const { return m_origPacket; }
    bool SetOrigPacket ( const string&  strOrigPacket )
    {
        m_origPacket = strOrigPacket;
        return true;
    }
private:
    string m_operation;
    string m_data;
    string m_origPacket;

public:
    void PackData(string& strData);
    PACKRETCODE UnpackData(const string& strData);
    uint32_t Size() const;
};

inline uint32_t CImNtfCommon::Size() const
{
    uint32_t nSize = 16;
    nSize += m_operation.length();
    nSize += m_data.length();
    nSize += m_origPacket.length();
    return nSize;
}

struct SNotifyMessage
{
public:
    SNotifyMessage()
    {
    }

    ~SNotifyMessage() { }
    SNotifyMessage(const uint8_t&  chType, const string&  strMessage)
    {
        m_type = chType;
        m_message = strMessage;
    }
    SNotifyMessage&  operator=( const SNotifyMessage&  sNotifyMessage )
    {
        m_type = sNotifyMessage.m_type;
        m_message = sNotifyMessage.m_message;
        return *this;
    }

    uint8_t m_type;
    string m_message;

public:
    uint32_t Size() const;
};

inline uint32_t SNotifyMessage::Size() const
{
    uint32_t nSize = 8;
    nSize += m_message.length();
    return nSize;
}

CPackData& operator<< ( CPackData& cPackData, const SNotifyMessage&  sNotifyMessage );
CPackData& operator>> ( CPackData& cPackData, SNotifyMessage&  sNotifyMessage );

#endif
