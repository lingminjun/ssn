/*---------------------------------------------------------------------------
// Filename:        mimsc_enum.h
// Date:            2013-12-12 16:02:24
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//                  created by muhua
//---------------------------------------------------------------------------*/
#ifndef __MIMSC_ENUM_H__
#define __MIMSC_ENUM_H__

#include <string>
#include <vector>
#include <map>
#include "packdata.h"

using namespace std;

enum ALI_IM_P2P_MSG_TYPE
{
    ALI_IM_TEXT                 = 0,
    ALI_IM_BUZZ                 = 0x1,
    ALI_IM_P2P                  = 0x2,
    ALI_IM_AUTO_REPLY           = 0x3,
    ALI_IM_MSG_ACK              = 0x4,
    ALI_IM_CONTACT              = 0x5,
    ALI_IM_TYPING_NOTIFY        = 0x6,
    ALI_IM_GROUP_BROADCAST      = 0x7,

};

enum IM_SERVER_NOTIFY_TYPE
{
    IM_NOTIFY_OFFMSG            = 0,
    IM_NOTIFY_CONTACT           = 0x1,
    IM_NOTIFY_PLUGIN            = 0x2,
    IM_NOTIFY_FRIEND_RECOMMEND  = 0x3,

};

enum IM_SERVER_NOTIFY_SUB_TYPE
{
    IM_VERIFY_ADD_CONTACT_REQUEST= 0x1,
    IM_VERIFY_ADD_CONTACT_RESPONSE= 0x2,

};

enum P2P_MSG_TYPE
{
    MSG_RICHTEXT                = 0,
    MSG_INPUTSTATUS             = 0x1,
    MSG_ACK                     = 0x2,
    MSG_CONTACT                 = 0x3,
    MSG_PLUGINNTF               = 0x4,
    MSG_OPERATION_NTF           = 0x5,
    MSG_NOTIFY                  = 0x6,
    MSG_ACK_NEW                 = 0x12,
    MSG_VOIP_INVITE             = 0x13,

};

enum SUB_MSG_TYPE
{
    IM_TEXT                     = 0,
    IM_IMAGE                    = 0x1,
    IM_VIDEO                    = 0x2,
    IM_AUDIO                    = 0x3,

};

enum CONTACT_OPERATE
{
    CHGNICK_NAME                = 0x1,
    MOVE_CONTACT                = 0x2,
    CHG_IMPORTANCE              = 0x4,

};

enum CONTACT_ADD_TYPE
{
    NOMAL_ADD                   = 0,
    VERIFY_ADD                  = 0x1,
    CHATED_ADD                  = 0x2,
    QUESTION_ADD                = 0x10,

};

enum IMAddContactResult_T
{
    IMADDCONTACTRESULT_SUCCESS  = 0,
    IMADDCONTACTRESULT_ADDED    = 0x1,
    IMADDCONTACTRESULT_NOID     = 0x2,
    IMADDCONTACTRESULT_FULL     = 0x3,
    IMADDCONTACTRESULT_FULLTODAY= 0x4,
    IMADDCONTACTRESULT_NEEDAUTH = 0x5,
    IMADDCONTACTRESULT_NORIGHT  = 0x6,
    IMADDCONTACTRESULT_NOTACTIVEID= 0x7,
    IMADDCONTACTRESULT_WAITAUTH = 0x8,
    IMADDCONTACTRESULT_DENYALL  = 0x9,
    IMADDCONTACTRESULT_HIGHFRENQ= 0xa,
    IMADDCONTACTRESULT_ESERVICETEAMMATE= 0xc,
    IMADDCONTACTRESULT_WRONGANSWER= 0x20,
    IMADDCONTACTRESULT_FILTMSG  = 0x21,
    IMADDCONTACTRESULT_NEEDANSWER= 0x22,
    IMADDCONTACTRESULT_OTHERERROR= 0xff,

};

enum CLIENT_DEVICE_TYPE
{
    CLIENT_DEVICE_TYPE_IPHONE   = 0x1,
    CLIENT_DEVICE_TYPE_ANDROIDPHONE= 0x2,
    CLIENT_DEVICE_TYPE_SYMBIAN  = 0x3,
    CLIENT_DEVICE_TYPE_IPAD     = 0x4,
    CLIENT_DEVICE_TYPE_IPHONE_WANGWANG= 0x7,
    CLIENT_DEVICE_TYPE_ANDROIDPHONE_WANGWANG= 0x8,

};

enum MSG_STATUS
{
    SEND_OK                     = 0x1,
    RECV_OK                     = 0x2,
    READ_OK                     = 0x4,

};

enum CONTACT_OPERATE_MSG_TYPE
{
    VERIFY_ADD_REQUEST          = 0x1,
    ACCEPT_VERIFY_REQUEST       = 0x2,
    DENY_VERIFY_REQUEST         = 0x3,
    NOTIFY_ADD_OK               = 0x4,
    NOTIFY_SERVER_ADD           = 0x5,
    NOTIFY_SUGGEST_ADD          = 0x6,
    NOTIFY_CONTACT_NEED_SYNC    = 0x7,
    NOTIFY_BLACKLIST_ADD        = 0x8,
    NOTIFY_BLACKLIST_DEL        = 0x9,
    NOTIFY_ACCEPT_OK            = 0xa,
    NOTIFY_ACCEPT_DENY          = 0xb,
    NOTIFY_SYNC_ADD_OK          = 0xc,

};

enum VERIFY_FLAG
{
    ADDCNT_OK                   = 0,
    ADDCNT_VERIFY               = 0x1,
    ADDCNT_DENY                 = 0x2,
    ADDCNT_NOUID                = 0x3,
    ADDCNT_UNKNOWN              = 0x4,
    ADDCNT_QUESTION             = 0x10,

};

enum LOGONTYPE
{
    LOGON_OK                    = 0x1,
    LOGON_FAIL_INVALIDUSER      = 0x1,
    LOGON_FAIL_INVALIDPWD       = 0x2,
    LOGON_FAIL_SYSBLOCK         = 0x3,
    LOGON_FAIL_NOAUTHORITY      = 0x4,
    LOGON_FAIL_TOOMANYID        = 0x5,
    LOGON_FAIL_INVALIDSERVER    = 0x6,
    LOGON_FAIL_WANGHAO_PROHIBITED= 0x7,
    LOGON_FAIL_LONGID_PROHIBITED= 0x8,
    LOGON_FAIL_INVALID_WANGHAO  = 0x9,
    LOGON_FAIL_NOT_SUPPORT      = 0xa,
    LOGON_FAIL_LONGID_NOTBIND   = 0xb,
    LOGON_FAIL_OTHER_BINDED     = 0xc,
    LOGON_FAIL_OTHER_ADDEDLIST  = 0xd,
    LOGON_FAIL_MOBILE_NOTACTIVE = 0xe,
    LOGON_FAIL_MOBILE_NOTBIND   = 0xf,
    LOGON_FAIL_ENUID_DISABLED   = 0x10,
    LOGON_FAIL_CHILD_ACCOUNT_EXPIRED= 0x15,
    LOGON_FAIL_CHILD_ACCOUNT_STOPED= 0x16,
    LOGON_FAIL_CHILD_ACCOUNT_PAUSED= 0x17,
    LOGIN_FAIL_RID              = 0x18,
    LOGON_FAIL_CTU_PROHIBITED   = 0x1f,
    LOGON_FAIL_NEEDAUTHCHECK    = 0x20,
    LOGON_FAIL_NEED2NDAUTH      = 0x21,
    LOGON_FAIL_OLD_VERSION      = 0x22,
    LOGON_FAIL_NO_TB_PHONE      = 0x23,
    LOGON_FAIL_TB_PHONE_USED    = 0x24,
    LOGON_FAIL_NOT_FIT_SERVER   = 0x25,
    LOGIN_FAIL_NEED_AUTH        = 0x26,
    LOGIN_FAIL_WRONG_AUTH       = 0x27,
    LOGON_FAIL_SSOTOKEN_INVALID_PARAMETER= 0x80,
    LOGIN_FAIL_MULTIPLE_ACCOUNT = 0xf4,
    LOGOFF_OK                   = 0xfa,
    LOGON_FAIL_UNKNOWN          = 0xfe,
    LOGOFF_FAIL_UNKNOWN         = 0xff,

};

enum OFFMSG_DB_TYPE
{
    OFFMSG_P2P                  = 0,
    OFFMSG_CONTACT              = 0x1,
    OFFMSG_MPC                  = 0x2,
    OFFMSG_SERVER_NOTIFY        = 0x3,
    OFFMSG_PLUGIN               = 0x4,
    OFFMSG_FRIEND_RECOMMEND     = 0x5,
    OFFMSG_TRIBE_SYSMSG         = 0x6,
    OFFMSG_OPERATION_MSG        = 0x8,
    OFFMSG_SYNC_SCREEM          = 0x11,
    OFFMSG_VOIP_CALL            = 0x13,

};

enum DEL_OFFMSG_RESULT_TYPE
{
    OFFMSG_DEL_OK               = 0,
    OFFMSG_IMS_ERROR            = 0x1,
    OFFMSG_OFFSRV_ERROR         = 0x2,

};

enum GET_CONTACT_RESULT_TYPE
{
    CONTACT_GET_DATA_OK         = 0,
    CONTACT_CLIENT_DATA_OK      = 0x1,
    CONTACT_SERVER_ERROR        = 0x2,

};

enum SEARCH_LATENT_CONTACT_TYPE
{
    SEARCH_SNS_CONTACT          = 0,
    SEARCH_LBS_NEIGHBOUR        = 0x1,
    SEARCH_LBS_ONEKEY_ADD       = 0x2,
    CLEAR_GPS_DATA              = 0x3,
    SEARCH_LBS_ONEKEY_ADD_FAKE  = 0x4,
    TB_SEARCH_SNS_CONTACT       = 0x8,
    TB_SEARCH_LBS_NEIGHBOUR     = 0x9,
    TB_SEARCH_LBS_ONEKEY_ADD    = 0xa,
    TB_SEARCH_LBS_ONEKEY_ADD_FAKE= 0xc,

};

enum MSG_LAYER_SECURITY_REQ_TYPE
{
    CLIENT_HELLO                = 0,
    CLIENT_KEY_EXCHANGE         = 0x1,

};

enum MSG_LAYER_SECURITY_RSP_TYPE
{
    SERVER_HELLO                = 0,
    SERVER_KEY_EXCHANGE         = 0x1,

};

enum INPUT_STATUS
{
    INPUT_STATUS_STOP           = 0,
    INPUT_STATUS_TEXT           = 0x1,
    INPUT_STATUS_AUDIO          = 0x2,
    INPUT_STATUS_PICTURE        = 0x4,

};

enum MSG_RECEIVER_FLAG
{
    RECEIVER_WANGXING           = 0x1,
    RECEIVER_PC                 = 0x2,
    RECEIVER_QIANNIU            = 0x4,
    RECEIVER_ALL                = 0xffff,

};

enum APPLICATION_TYPE
{
    APP_TYPE_DEFAULT            = 0,
    APP_TYPE_QIANNIU            = 0x1,
    APP_TYPE_WANGXIN            = 0x2,
    APP_TYPE_MOBILE_TB          = 0x3,
    APP_TYPE_IOS_ENT            = 0x5,
    APP_TYPE_PC                 = 0x6,

};

enum LOGON_STATUS
{
    LOGON_STATUS_OFFLINE        = 0,
    LOGON_STATUS_ONLINE         = 0x1,
    LOGON_STATUS_INVISIBLE      = 0x2,

};

enum BizID
{
    BIZ_DEFAULT                 = 0,
    BIZ_WW_P2P                  = 0x1,
    BIZ_BG_P2P                  = 0x2,
    BIZ_WX_P2P                  = 0x3,
    BIZ_OTHER                   = 0xffffffff,
    BIZ_VOIP                    = 0x4,
    BIZ_PAMSG                   = 0x5,
    BIZ_TRIBE                   = 0x7,
    BIZ_MPC                     = 0x8,
    BIZ_SYSMSG                  = 0x9,

};

#endif
