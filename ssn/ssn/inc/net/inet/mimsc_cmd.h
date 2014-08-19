/*---------------------------------------------------------------------------
// Filename:        mimsc_cmd.h
// Date:            2013-12-12 16:02:24
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//                  created by muhua
//---------------------------------------------------------------------------*/
#ifndef __MIMSC_CMD_H__
#define __MIMSC_CMD_H__

#include <string>
#include <vector>
#include <map>
#include "packdata.h"

using namespace std;

enum MIMSC_REQUEST
{
    IM_HELTH_CHECK              = 0x1000001,
    IM_REQ_CHECKVERSION         = 0x1000002,
    IM_REQ_LOGIN                = 0x1000003,
    IM_REQ_MLS                  = 0x1000004,
    IM_REQ_POSTLOGIN            = 0x1000005,
    IM_REQ_GET_TOKEN            = 0x1000006,
    IM_REQ_LOGOFF               = 0x1000007,
    IM_REQ_GETGROUP             = 0x1000008,
    IM_REQ_CHGSTATUS            = 0x100001c,
    IM_REQ_OFFLINEMSG           = 0x100001d,
    IM_REQ_DELOFFLINEMSG        = 0x100001f,
    IM_REQ_SENDIMMESSAGE        = 0x1000021,
    IM_REQ_SENDMULTIUSERMSG     = 0x1000022,
    IM_REQ_USERUDBPROFILE       = 0x1000035,
    IM_REQ_SUBSCRIBE_INFO       = 0x1000027,
    IM_REQ_SEARCH_LATENT_CONTACT= 0x1000061,
    IM_REQ_CHECK_AUTHCODE       = 0x1000040,
    IM_REQ_GET_CONTACTS_FLAG    = 0x1000053,
    IM_REQ_TRIBE                = 0x1000101,
    IM_REQ_SENDMULIMMESSAGE     = 0x1000080,
    IM_REPORT_NETWORK_STATUS    = 0x1000090,
    IM_REQ_READ_TIMES           = 0x1000211,
    IM_REQ_MESSAGE_READ         = 0x1000212,
    IM_REQ_BATCH_MESSAGE_READ   = 0x1000213,
    IM_REQ_GET_LOGON_INFO       = 0x4000001,
    CNT_REQ_GET_CONTACT         = 0x2000001,
    CNT_REQ_ADD_CONTACT         = 0x2000002,
    CNT_REQ_CHG_CONTACT         = 0x2000003,
    CNT_REQ_DEL_CONTACT         = 0x2000004,
    CNT_REQ_ACK_CONTACT         = 0x2000005,
    CNT_REQ_GET_GROUP           = 0x2000006,
    CNT_REQ_SEARCH_LATENT_CONTACT= 0x3000007,
    CNT_REQ_GETBLACK            = 0x2000008,
    CNT_REQ_ADDBLACK            = 0x2000009,
    CNT_REQ_DELBLACK            = 0x200000a,
    IM_REQ_FWD_MSG              = 0x1000091,
    IM_REQ_RENEWAL              = 0x1000300,
    IM_REQ_SUB_BIZ              = 0x1001001,
    IM_REQ_UNSUB_BIZ            = 0x1001002,

};

enum MIMSC_RESPONSE
{
    IM_RSP_CHECKVERSION         = 0x1010002,
    IM_RSP_LOGIN                = 0x1010003,
    IM_RSP_MLS                  = 0x1010004,
    IM_RSP_GET_TOKEN            = 0x1010006,
    IM_RSP_LOGOFF               = 0x1010007,
    IM_RSP_GETGROUP             = 0x1010008,
    IM_RSP_DELOFFLINEMSG        = 0x101001f,
    IM_RSP_SENDIMMESSAGE        = 0x1010021,
    IM_RSP_SUBSCRIBE_INFO       = 0x1010027,
    IM_RSP_USERUDBPROFILE       = 0x1010035,
    IM_RSP_SEARCH_LATENT_CONTACT= 0x1010061,
    IM_RSP_CHECK_AUTHCODE       = 0x1010040,
    IM_RSP_OFFLINEMSG           = 0x101001d,
    IM_RSP_GET_CONTACTS_FLAG    = 0x1010053,
    IM_RSP_READ_TIMES           = 0x1010211,
    IM_RSP_GET_LOGON_INFO       = 0x4010001,
    IM_RSP_TRIBE                = 0x1010101,
    IM_RSP_SENDMULIMMESSAGE     = 0x1010080,
    CNT_RSP_GET_CONTACT         = 0x2010001,
    CNT_RSP_ADD_CONTACT         = 0x2010002,
    CNT_RSP_CHG_CONTACT         = 0x2010003,
    CNT_RSP_DEL_CONTACT         = 0x2010004,
    CNT_RSP_ACK_CONTACT         = 0x2010005,
    CNT_RSP_GET_GROUP           = 0x2010006,
    CNT_RSP_SEARCH_LATENT_CONTACT= 0x3010007,
    CNT_RSP_GETBLACK            = 0x2010008,
    CNT_RSP_ADDBLACK            = 0x2010009,
    CNT_RSP_DELBLACK            = 0x201000a,
    IM_RSP_FWD_MSG              = 0x1010091,
    IM_RSP_RENEWAL              = 0x1010300,
    IM_RSP_SUB_BIZ              = 0x1101001,
    IM_RSP_UNSUB_BIZ            = 0x1101002,

};

enum MIMSC_NOTIFY
{
    IM_NTF_LOGIN_AGAIN          = 0x1020004,
    IM_NTF_FORCEDISCONNECT      = 0x1020005,
    IM_NTF_STATUS               = 0x102000f,
    IM_NTF_IMMESSAGE            = 0x1020010,
    IM_NTF_OPERATIONTIP         = 0x102002b,
    IM_NTF_UPDATE_USREXTINFO    = 0x102002c,
    IM_NTF_REFRESH_CONTACT      = 0x1020030,
    IM_NTF_NEED_AUTHCODE        = 0x1020040,
    IM_NTF_TRIBE                = 0x1020101,
    IM_NTF_MESSAGE_READ         = 0x1020212,
    IM_NTF_FWD_MSG              = 0x1020091,
    IM_TEST                     = 0,
    IM_NTF_COMMON               = 0x1020041,

};

#endif
