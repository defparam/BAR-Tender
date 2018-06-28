#pragma once
#include <windows.h>
#include <wdf.h>
#include "Device.h"

class MsgProcessor;

class KernelTools
{
public:
	KernelTools(MsgProcessor *MsgP);
	ULONG64 find_KPCR();
	ULONG64 va2pa(ULONG64 cr3, ULONG64 vaddr);
	int swap_pa(ULONG64 cr3, ULONG64 vaddr, ULONG64 new_pa, ULONG64 *old_pa);
	int get_dirbase(DWORD PID, PULONG64 dirbase);
private:
	MsgProcessor *MsgP;
	ULONG64 KPCR = 0;
	inline ULONG64 vread64(ULONG64 CR3, ULONG64 vaddr);
	inline ULONG64 read64(ULONG64 addr);
	inline void write64(ULONG64 addr, ULONG64 data);
};

