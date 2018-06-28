#pragma once
#include "Device.h"

#ifdef __cplusplus
extern "C" {
#endif

	int CreateMsgProc(PDEVICE_CONTEXT devC);
	int ProcessMsg(BAR_TENDER_REQ *reqIn, BAR_TENDER_REQ *reqOut);
	int ProcessIrq();
	int DestroyMsgProc();

#ifdef __cplusplus
}
#endif