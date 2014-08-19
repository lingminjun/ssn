/*---------------------------------------------------------------------------
// Filename:        mpcsc_cmd.h
// Date:            2013-10-14 23:19:05
// Author:          autogen 
// Note:            this is a auto-generated file, DON'T MODIFY IT!
//---------------------------------------------------------------------------*/
#ifndef __MPCSC_CMD_H__
#define __MPCSC_CMD_H__

#include <string>
#include <vector>
#include <map>
#include "packdata.h"

using namespace std;

enum MPCSC_REQUEST
{
    MPCS_REQ_CREATEROOM         = 0xd000001,
    MPCS_REQ_JOINROOM           = 0xd000002,
    MPCS_REQ_EXITROOM           = 0xd000003,
    MPCS_REQ_GETROOMINFO        = 0xd000004,
    MPCS_REQ_SEND_MSG           = 0xd000005,
    MPCS_REQ_OFFMSG_COUNT       = 0xd000006,
    MPCS_REQ_INVITEROOM         = 0xd000007,
    MPCS_REQ_ROOMIDLIST         = 0xd000008,

};

enum MPCSC_RESPONSE
{
    MPCS_RSP_CREATEROOM         = 0xd010001,
    MPCS_RSP_JOINROOM           = 0xd010002,
    MPCS_RSP_EXITROOM           = 0xd010003,
    MPCS_RSP_GETROOMINFO        = 0xd010004,
    MPCS_RSP_SEND_MSG           = 0xd010005,
    MPCS_RSP_OFFMSG_COUNT       = 0xd010006,
    MPCS_RSP_INVITEROOM         = 0xd000007,
    MPCS_RSP_ROOMIDLIST         = 0xd010008,

};

enum MPCSC_NOTIFY
{
    MPCS_NTF_MESSAGE            = 0xd020005,
    MPCS_NTF_USERSTS            = 0xd020101,
    MPCS_NTF_CREATEROOM         = 0xd020001,

};

#endif
