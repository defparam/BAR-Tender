/*++

Module Name:

public.h

Abstract:

This module contains the common declarations shared by driver
and user applications.

Environment:

driver and application

--*/


#define WHILE(a) \
__pragma(warning(suppress:4127)) while(a)
//
// Define an Interface Guid so that apps can find the device and talk to it.
//

DEFINE_GUID(GUID_DEVINTERFACE_BARTender, 0x5fb65a4e, 0x46ad, 0x45db, 0xa3, 0x04, 0xdc, 0x0c, 0x45, 0xba, 0x8e, 0x98);
// {5fb65a4e-46ad-45db-a304-dc0c45ba8e98}

#define IOCTL_BAR_TENDER 0x02A01000

#define BARTCMD_FPGAREAD64  0x00000000
#define BARTCMD_FPGAWRITE64 0x00000001
#define BARTCMD_MEMREAD64   0x00000002
#define BARTCMD_MEMWRITE64  0x00000003
#define BARTCMD_FIND_KPCR   0x00000004
#define BARTCMD_VA2PA       0x00000005
#define BARTCMD_SWAP_PA     0x00000006
#define BARTCMD_VMEMREAD64  0x00000007
#define BARTCMD_VMEMWRITE64 0x00000008
#define BARTCMD_GET_DIRBASE 0x00000009

typedef struct _BAR_TENDER_REQ
{
	DWORD CMD; // comand code
	DWORD RET; // return code

	ULONG64 PADDR;
	ULONG64 VADDR;
	ULONG64 CR3;
	ULONG64 DATA;
	DWORD PID;

} BAR_TENDER_REQ;
