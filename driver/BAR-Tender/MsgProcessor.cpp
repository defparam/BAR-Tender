#include "MsgProcessor.h"

#include <windows.h>
#include <wdf.h>

#include "MsgInterface.h"
#include "KernelTools.h"


static MsgProcessor * proc = nullptr;

MsgProcessor::MsgProcessor(PDEVICE_CONTEXT devC)
{
	this->devC = devC;
	this->ktools = new KernelTools(this);
	FPGA_UPADDRESS = (ULONG64)devC->paddr + 0x10;
	FPGA_CTRL = (ULONG64)devC->paddr + 0x28;
	FPGA_STATUS = (ULONG64)devC->paddr + 0x30;
	

	DbgPrint("!!MsgProcessor!! Message Proccessor is Alive!\n");
}

MsgProcessor::~MsgProcessor()
{
	DbgPrint("!!MsgProcessor!! Message Proccessor is Dead!\n");
	delete this->ktools;
}


inline int MsgProcessor::fpga_read64(ULONG64 addr, ULONG64 *data)
{
	ULONG64 fulladdr = (ULONG64)devC->paddr + addr;
	WDF_READ_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)fulladdr, data, 1);
	return 0;
}

inline int MsgProcessor::fpga_write64(ULONG64 addr, ULONG64 data)
{
	ULONG64 fulladdr = (ULONG64)devC->paddr + addr;
	WDF_WRITE_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)fulladdr, &data, 1);
	return 0;
}

inline int MsgProcessor::mem_vread64(ULONG64 CR3, ULONG64 addr, ULONG64 *data, DWORD *TLP_status)
{
	ULONG64 tmp1, tmp2;
	ULONG64 paddr = ktools->va2pa(CR3, addr);
	if (paddr == 0)
	{
		*TLP_status = 1;
		*data = 0;
		return 0;
	}
	int j = paddr & 0x7;
	paddr &= 0xFFFFFFFFFFFFFFF8;
	if (j)
	{
		mem_read64(paddr, &tmp1, TLP_status);
		mem_read64(paddr+8, &tmp2, TLP_status);
		*data = (tmp1 >> (j * 8)) | (tmp2 << (64 - (j * 8)));
	}
	else mem_read64(paddr, data, TLP_status);

	
	return 0;
}

inline int MsgProcessor::mem_vwrite64(ULONG64 CR3, ULONG64 addr, ULONG64 data)
{
	ULONG64 paddr = ktools->va2pa(CR3, addr);
	mem_write64(paddr, data);
	return 0;
}

inline int MsgProcessor::mem_read64(ULONG64 addr, ULONG64 *data, DWORD *TLP_status)
{

	ULONG64 val = 0x2; // upstream read command
	// Set the Physical memory address in the FPGA
	WDF_WRITE_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)FPGA_UPADDRESS, &addr, 1);

	// Issue a upstream read command to the FPGA
	WDF_WRITE_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)FPGA_CTRL, &val, 1);

	// Spin loop until in_progress bit equals 0
	while (IRQ == 0) {};
	*data = readdata;
	IRQ = 0;

	//Report back the status of the upstream TLP read operation
	*TLP_status = (val & 0x7);

	
	return 0;
}

inline int MsgProcessor::mem_write64(ULONG64 addr, ULONG64 data)
{
	ULONG64 FPGA_UPWRITEDATA = (ULONG64)devC->paddr + 0x18;
	ULONG64 val = 0x1; // upstream write command

	WDF_WRITE_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)FPGA_UPADDRESS, &addr, 1);
	WDF_WRITE_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)FPGA_UPWRITEDATA, &data, 1);

	// Issue a upstream write command to the FPGA
	WDF_WRITE_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)FPGA_CTRL, &val, 1);
	return 0;
}

int MsgProcessor::ProcessMsg(BAR_TENDER_REQ *reqIn, BAR_TENDER_REQ *reqOut)
{
	switch (reqIn->CMD) {
	case BARTCMD_FPGAREAD64:
		reqOut->PADDR = reqIn->PADDR;
		return fpga_read64(reqIn->PADDR, &reqOut->DATA);
	case BARTCMD_FPGAWRITE64:
		return fpga_write64(reqIn->PADDR, reqIn->DATA);
	case BARTCMD_MEMREAD64:
		reqOut->PADDR = reqIn->PADDR;
		return mem_read64(reqIn->PADDR, &reqOut->DATA, &reqOut->RET);
	case BARTCMD_MEMWRITE64:
		return mem_write64(reqIn->PADDR, reqIn->DATA);
	case BARTCMD_FIND_KPCR:
		reqOut->VADDR = ktools->find_KPCR();
		return 0;
	case BARTCMD_VA2PA:
		reqOut->PADDR = ktools->va2pa(reqIn->CR3, reqIn->VADDR);
		return 0;
	case BARTCMD_VMEMREAD64:
		mem_vread64(reqIn->CR3, reqIn->VADDR, &reqOut->DATA, &reqOut->RET);
		return 0;
	case BARTCMD_VMEMWRITE64:
		mem_vwrite64(reqIn->CR3, reqIn->VADDR, reqIn->DATA);
		return 0;
	case BARTCMD_SWAP_PA:
		reqOut->RET = ktools->swap_pa(reqIn->CR3, reqIn->VADDR, reqIn->PADDR, &reqOut->PADDR);
		return 0;
	case BARTCMD_GET_DIRBASE:
		reqOut->RET = ktools->get_dirbase(reqIn->PID, &reqOut->CR3);
		return 0;
	default:
		return -1; // invalid parameter
	}
}

int MsgProcessor::ProcessIrq()
{
	LONG64 FPGA_UPREADDATA = (ULONG64)devC->paddr + 0x20;

	if (IRQ) return 1;

	// Report back the read data
	WDF_READ_REGISTER_BUFFER_ULONG64(devC->Device, (PULONG64)FPGA_UPREADDATA, &readdata, 1);
	IRQ = 1;

	return 0;
}

int CreateMsgProc(PDEVICE_CONTEXT devC)
{
	if (proc == nullptr)
	{
		proc = new MsgProcessor(devC);
		return 0;
	}
	return 1;
}
// From C to C++ Class Singleton
int ProcessMsg(BAR_TENDER_REQ *reqIn, BAR_TENDER_REQ *reqOut)
{
	if (proc == nullptr) return -1;
	return proc->ProcessMsg(reqIn, reqOut);
}

int ProcessIrq()
{
	return proc->ProcessIrq();
}

int DestroyMsgProc()
{
	if (proc != nullptr)
	{
		delete proc;
		proc = nullptr;
		return 0;
	}
	return 1;
}
