#pragma once
#include <windows.h>
#include <wdf.h>
#include "Device.h"
#include <atomic>

class KernelTools;

class MsgProcessor
{
private:
	PDEVICE_CONTEXT devC;
	KernelTools *ktools;
	ULONG64 readdata;
	ULONG64 FPGA_UPADDRESS;
	ULONG64 FPGA_CTRL;
	ULONG64 FPGA_STATUS;
	std::atomic<BOOL> IRQ = 0;

public:
	MsgProcessor(PDEVICE_CONTEXT devC);
	~MsgProcessor();
	int ProcessMsg(BAR_TENDER_REQ *reqIn, BAR_TENDER_REQ *reqOut);
	int ProcessIrq();
	inline int fpga_read64(ULONG64 addr, ULONG64 *data);
	inline int fpga_write64(ULONG64 addr, ULONG64 data);
	inline int mem_read64(ULONG64 addr, ULONG64 *data, DWORD *TLP_status);
	inline int mem_write64(ULONG64 addr, ULONG64 data);
	inline int mem_vread64(ULONG64 CR3, ULONG64 addr, ULONG64 *data, DWORD *TLP_status);
	inline int mem_vwrite64(ULONG64 CR3, ULONG64 addr, ULONG64 data);
};

