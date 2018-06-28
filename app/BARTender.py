from ctypes import *
from ctypes.wintypes import *
import time
import os

ULONG_PTR = c_ulonglong 
ULONG64 = c_ulonglong # /home/evan/Downloads/ctypesgen/test.h: 32
ULONG = c_ulong # /home/evan/Downloads/ctypesgen/test.h: 33
PULONG = POINTER(ULONG) # /home/evan/Downloads/ctypesgen/test.h: 34
UCHAR = c_ubyte # /home/evan/Downloads/ctypesgen/test.h: 35
WCHAR = c_wchar # /home/evan/Downloads/ctypesgen/test.h: 36
PWCHAR = POINTER(WCHAR) # /home/evan/Downloads/ctypesgen/test.h: 37
BOOL = c_int # /home/evan/Downloads/ctypesgen/test.h: 39
DWORD = c_ulong # /home/evan/Downloads/ctypesgen/test.h: 40
EMPTY_WCHAR = pointer(WCHAR())
LPCWSTR = PWCHAR # /home/evan/Downloads/ctypesgen/test.h: 58
LPVOID = POINTER(None) # /home/evan/Downloads/ctypesgen/test.h: 59
PVOID = POINTER(None) # /home/evan/Downloads/ctypesgen/test.h: 59

class struct__GUID(Structure):
    pass

struct__GUID.__slots__ = [
    'Data1',
    'Data2',
    'Data3',
    'Data4',
]
struct__GUID._fields_ = [
    ('Data1', c_ulong),
    ('Data2', c_ushort),
    ('Data3', c_ushort),
    ('Data4', c_ubyte * 8),
]

class struct__BAR_TENDER_REQ(Structure):
    pass

struct__BAR_TENDER_REQ.__slots__ = [
    'CMD',
    'RET',
    'PADDR',
	'VADDR',
	'CR3',
	'DATA',
	'PID',
]
struct__BAR_TENDER_REQ._fields_ = [
    ('CMD',  DWORD),
    ('RET',  DWORD),
    ('PADDR', ULONG64),
	('VADDR', ULONG64),
	('CR3', ULONG64),
    ('DATA', ULONG64),
	('PID', DWORD),
]

BAR_TENDER_REQ = struct__BAR_TENDER_REQ
GUID = struct__GUID
LPGUID = POINTER(GUID) 

OPEN_EXISTING = 3
FILE_SHARE_READ = 1
FILE_SHARE_WRITE = 2
GENERIC_READ = 0x80000000
GENERIC_WRITE = 0x40000000
INVALID_HANDLE_VALUE = 0xFFFFFFFFFFFFFFFF

IOCTL_BAR_TENDER = 0x02A01000
BARTCMD_FPGAREAD64 = 0x00000000
BARTCMD_FPGAWRITE64 = 0x00000001
BARTCMD_MEMREAD64 = 0x00000002
BARTCMD_MEMWRITE64  = 0x00000003
BARTCMD_FIND_KPCR = 0x00000004
BARTCMD_VA2PA = 0x00000005
BARTCMD_SWAP_PA = 0x00000006
BARTCMD_VMEMREAD64 = 0x00000007
BARTCMD_VMEMWRITE64 = 0x00000008
BARTCMD_GET_DIRBASE = 0x00000009



class BARTender():
	BARTender_GUID = GUID(
	0x5fb65a4e, 
	0x46ad, 
	0x45db, 
	(c_ubyte * 8)(*[0xa3, 0x04, 0xdc, 0x0c, 0x45, 0xba, 0x8e, 0x98]));

	def __init__(self):
		self.GetInterfaceListSize = cdll.Cfgmgr32.CM_Get_Device_Interface_List_SizeW
		self.GetInterfaceListSize.argtypes = [PULONG, LPGUID, PWCHAR, ULONG]
		self.GetInterfaceListSize.restype = DWORD

		self.GetInterfaceList = cdll.Cfgmgr32.CM_Get_Device_Interface_ListW
		self.GetInterfaceList.argtypes = [LPGUID, PWCHAR, PWCHAR, ULONG, ULONG]
		self.GetInterfaceList.restype = DWORD
		
		self.CreateFile = cdll.Kernel32.CreateFileW
		self.CreateFile.argtypes = [LPCWSTR, DWORD, DWORD, LPVOID, DWORD, DWORD, HANDLE]
		self.CreateFile.restype = HANDLE
		
		self.CloseHandle = cdll.Kernel32.CloseHandle
		self.CloseHandle.argtypes = [HANDLE]
		self.CloseHandle.restype = BOOL
		
		self.DeviceIoControl = cdll.Kernel32.DeviceIoControl
		self.DeviceIoControl.argtypes = [HANDLE, DWORD, LPVOID, DWORD, LPVOID, DWORD, LPDWORD, LPVOID]
		self.DeviceIoControl.restype = BOOL

		self.device = -1
		
		intf = self._Get_Interface()
		print ("Found Interface: %s" %(intf))
		print ("Opening Interface...")
		self._Open(intf)
		if (self.device == -1):
			exit(1)
		print ("Interface Opened. Handle: 0x%08x" %self.device)


		
	def _Get_Interface(self):
		l = ULONG()
		ret = self.GetInterfaceListSize(pointer(l),pointer(self.BARTender_GUID),EMPTY_WCHAR,0);
		if (ret != 0):
			print("Error: CM_Get_Device_Interface_List_Size Failed with 0x%x",ret)
			return ""
			
		if (l.value == 0):
			print("Error: No interfaces found. Is the driver loaded?",ret)
			return ""
			
		devListSize = l.value;
		deviceInterfaceList = (WCHAR*devListSize)()
		
		ret = self.GetInterfaceList(pointer(self.BARTender_GUID),
		EMPTY_WCHAR,
		deviceInterfaceList,
		devListSize,
		0)
		
		if (ret != 0):
			print("Error: CM_Get_Device_Interface_List Failed with 0x%x",ret)
			return ""
		
		return deviceInterfaceList.value
		
	def _Open(self,devName):
		ret = self.CreateFile(devName,
		GENERIC_READ | GENERIC_WRITE,
		FILE_SHARE_READ | FILE_SHARE_WRITE,
		None,
		OPEN_EXISTING,
		0,
		None)
		
		if (ret == INVALID_HANDLE_VALUE):
			print("Error: CreateFile failed with invalid handle")
			return
		
		self.device = ret
		
	def Close(self):
		ret = self.CloseHandle(self.device)
		if (ret == 0):
			print("Error: CloseHandle failed")
			return
		print ("Interface Closed")
			
	def fpgaRead64(self,addr):
		req = BAR_TENDER_REQ(BARTCMD_FPGAREAD64,0,addr,0,0,0,0)
		

		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		

		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
			
		return req.DATA
		
	
	def fpgaWrite64(self,addr, data):
		req = BAR_TENDER_REQ(BARTCMD_FPGAWRITE64,0,addr,0,0,data,0)
				
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return
		
	def memRead64(self,addr):
		req = BAR_TENDER_REQ(BARTCMD_MEMREAD64,0,addr,0,0,0,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return req.DATA
		
	def memWrite64(self,addr, data):
		req = BAR_TENDER_REQ(BARTCMD_MEMWRITE64,0,addr,0,0,data,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return
		
	def vmemRead64(self,CR3,addr):
		req = BAR_TENDER_REQ(BARTCMD_VMEMREAD64,0,0,addr,CR3,0,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
			
		#if (req.RET != 0): req.DATA = 0
		
		return req.DATA
		
	def vmemWrite64(self,CR3,addr,data):
		req = BAR_TENDER_REQ(BARTCMD_VMEMWRITE64,0,0,addr,CR3,data,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return
		
	def find_KPCR(self):
		req = BAR_TENDER_REQ(BARTCMD_FIND_KPCR,0,0,0,0,0,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return _KPCR(self,req.VADDR)

	def va2pa(self,CR3,VADDR):
		req = BAR_TENDER_REQ(BARTCMD_VA2PA,0,0,VADDR,CR3,0,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return req.PADDR
		
	def swap_pa(self,dirbase,vaddr,new_pa):
		req = BAR_TENDER_REQ(BARTCMD_SWAP_PA,0,new_pa,vaddr,dirbase,0,0)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
		
		return req.PADDR;
		
	def get_dirbase(self,pid):
		req = BAR_TENDER_REQ(BARTCMD_GET_DIRBASE,0,0,0,0,0,pid)
		bytesRet = DWORD()
		
		ret = self.DeviceIoControl( self.device,
		IOCTL_BAR_TENDER,
		pointer(req),
		sizeof(req),
		pointer(req),
		sizeof(req),
		pointer(bytesRet),
		None)
		
		if (ret == 0):
			print ("Error: DeviceIoControl returned error")
			exit(1)
			
		if (req.RET == 1):
			return 0x0
		
		return req.CR3;
		
class _ProcessParameters():
	def __init__(self,BARTender, CR3, ProcessParameters):
		self.BART = BARTender
		self.ProcessParameters = ProcessParameters
		self.CR3 = CR3
	def __int__(self):
		return self.ProcessParameters
	def ImagePathName(self):
		len = self.BART.vmemRead64(self.CR3,self.ProcessParameters+0x60)&0xFFFF
		wchar_ptr = self.BART.vmemRead64(self.CR3,self.ProcessParameters+0x68)
		name = ""
		for i in range(int(len/8)+1):
			buf = self.BART.vmemRead64(self.CR3,wchar_ptr+(i*8))
			if i == int(len/8):
				j = int(len/2)%4
			else: 
				j = 4
			if (j >= 1): name = name + chr((buf>>0)&0xFFFF)
			if (j >= 2): name = name + chr((buf>>16)&0xFFFF)
			if (j >= 3): name = name + chr((buf>>32)&0xFFFF)
			if (j == 4): name = name + chr((buf>>48)&0xFFFF)
		return name
		
class _PEB():
	def __init__(self, BARTender, CR3, PEB):
		self.BART = BARTender
		self.PEB = PEB
		self.CR3 = CR3
	def __int__(self):
		return self.PEB
	def ImageBaseAddress(self):
		return self.BART.vmemRead64(self.CR3,self.PEB+0x10)
	def ProcessParameters(self):
		ptr = self.BART.vmemRead64(self.CR3,self.PEB+0x20)
		if ((self.PEB == 0)or(ptr == 0)):
			return _ProcessParameters(self.BART,0,0)
		return _ProcessParameters(self.BART,self.CR3,ptr)
			
class _EPROCESS():
	def __init__(self, BARTender, EPROCESS):
		self.BART = BARTender
		self.EPROCESS = EPROCESS
	def __int__(self):
		return self.EPROCESS
		
	def mmProcessLinks_flink(self):
		flink = self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x610)
		if flink == 0:
			return _EPROCESS(self.BART,0)
		else:
			return _EPROCESS(self.BART,flink-0x610)
		
	def Peb(self):
		peb_ptr = self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x3f8)
		if peb_ptr == 0: 
			return _PEB(self.BART,0,0)
		return _PEB(self.BART,self.DirectoryTableBase(),peb_ptr)
		
	def ActiveProcessLinks_flink(self):
		flink = self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x2e8)
		if flink == 0:
			return _EPROCESS(self.BART,0)
		else:
			return _EPROCESS(self.BART,flink-0x2e8)
			
	def UniqueProcessID(self):
		return self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x2e0)
		
	def OwnerProcessID(self):
		return self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x3f0)
		
	def DirectoryTableBase(self):
		return self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x28)
		
	def ImageFileName(self):
		name = ""
		tmp = self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x458)
		for i in range(0,8):
			name = chr((tmp >> 8*(7-i))&0xFF) + name
		tmp = self.BART.vmemRead64(0x1aa000,self.EPROCESS+0x450)
		for i in range(0,8):
			name = chr((tmp >> 8*(7-i))&0xFF) + name
		name = name[0:15]


		return name

class _KTHREAD():
	def __init__(self, BARTender, KTHREAD):
		self.BART = BARTender
		self.KTHREAD = KTHREAD
	def __int__(self):
		return self.KTHREAD
	def Process(self):
		return _EPROCESS(self.BART,self.BART.vmemRead64(0x1aa000,self.KTHREAD+0x220))

class _KPRCB():
	def __init__(self, BARTender, KPRCB):
		self.BART = BARTender
		self.KPRCB = KPRCB
	def __int__(self):
		return self.KPRCB
	def CurrentThread(self):
		return _KTHREAD(self.BART,self.BART.vmemRead64(0x1aa000,self.KPRCB+0x8))
	def NextThread(self):
		return _KTHREAD(self.BART,self.BART.vmemRead64(0x1aa000,self.KPRCB+0x10))
	def IdleThread(self):
		return _KTHREAD(self.BART,self.BART.vmemRead64(0x1aa000,self.KPRCB+0x18))
			
class _KPCR():
	def __init__(self, BARTender, KPCR):
		self.BART = BARTender
		self.KPCR = KPCR
	def __int__(self):
		return self.KPCR
	def KPRCB(self):
		return _KPRCB(self.BART,self.KPCR+0x180)

		
		