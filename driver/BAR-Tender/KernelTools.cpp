#include "KernelTools.h"
#include "MsgProcessor.h"


KernelTools::KernelTools(MsgProcessor * MsgP)
{
	this->MsgP = MsgP;
}


class pagewalker {
private:
	MsgProcessor * MsgP;
	ULONG64 CR3;

	ULONG64 PML4e;
	ULONG64 PDPTe;
	ULONG64 PDe;
	ULONG64 PTe;
	inline ULONG64 read64(ULONG64 addr) {
		ULONG64 buf = 0;
		DWORD tmp;
		MsgP->mem_read64(addr, &buf, &tmp);
		return buf;
	}


public:
	USHORT PML4i;
	USHORT PDPTi;
	USHORT PDi;
	USHORT PTi;
	USHORT PML4ir;
	USHORT PDPTir;
	USHORT PDir;
	USHORT PTir;
	ULONG64 PA, VA;
	enum pagetype { _4KB, _2MB, _1GB, _INIT } type;

	pagewalker(MsgProcessor *MsgP, ULONG64 CR3) {
		this->CR3 = CR3;
		this->MsgP = MsgP;
		type = _INIT;
		PML4i = 0x0;
	}

	int next_pml4i() {
		ULONG64 tmp;
		if (PML4i >= 0x1FF) {
			return 0;
		}
		while (1) {
			tmp = read64(CR3 + (PML4i * 8));
			PML4i = PML4i + 1;
			if (tmp & 0x1) {
				PML4ir = PML4i - 1;
				PML4e = tmp;
				return 1;
			}
			if (PML4i > 0x1FF) {
				return 0;
			}
		}
		return 0;
	}

	int next_pdpti() {
		ULONG64 tmp;
		ULONG64 PDPT = ((PML4e >> 12) & 0xffffffffff) << 12;
		if (PDPTi >= 0x1FF) {
			return 0;
		}
		while (1) {
			tmp = read64(PDPT + (PDPTi * 8));
			PDPTi = PDPTi + 1;
			if (tmp & 0x1) {
				PDPTir = PDPTi - 1;
				PDPTe = tmp;
				return 1;
			}
			if (PDPTi > 0x1FF) {
				return 0;
			}
		}
		return 0;
	}

	int next_pdi() {
		ULONG64 tmp;
		ULONG64 PD = ((PDPTe >> 12) & 0xffffffffff) << 12;
		if (PDi >= 0x1FF) {
			return 0;
		}
		while (1) {
			tmp = read64(PD + (PDi * 8));
			PDi = PDi + 1;
			if (tmp & 0x1) {
				PDir = PDi - 1;
				PDe = tmp;
				return 1;
			}
			if (PDi > 0x1FF) {
				return 0;
			}
		}
		return 0;
	}

	int next_pti() {
		ULONG64 tmp;
		ULONG64 PT = ((PDe >> 12) & 0xffffffffff) << 12;
		if (PTi >= 0x1FF) {
			return 0;
		}
		while (1) {
			tmp = read64(PT + (PTi * 8));
			PTi = PTi + 1;
			if (tmp & 0x1) {
				PTir = PTi - 1;
				PTe = tmp;
				return 1;
			}
			if (PTi > 0x1FF) {
				return 0;
			}
		}
		return 0;
	}

	int kick(int table) {
		switch (table) {
		case 0:
			type = _4KB;
			if (!next_pti()) {
				return kick(1);
			}
			else return 1;
		case 1:
			if (!next_pdi()) {
				return kick(2);
			}
			else {
				if (PDe & 0x80) {
					type = _2MB;
					return 1;
				}
				PTi = 0;
				return kick(0);
			}
		case 2:
			if (!next_pdpti()) {
				return kick(3);
			}
			else {
				if (PDPTe & 0x80) {
					type = _1GB;
					return 1;
				}
				PDi = 0;
				return kick(1);
			}
		case 3:
			if (!next_pml4i()) {
				return NULL;
			}
			else {
				PDPTi = 0;
				return kick(2);
			}
		default:
			return NULL;
		}
	}

	int next_page() {
		VA = 0;
		PA = 0;

		switch (type) {
		case _4KB:
			if (!kick(0)) return NULL;
			break;
		case _2MB:
			if (!kick(1)) return NULL;
			break;
		case _1GB:
			if (!kick(2)) return NULL;
			break;
		case _INIT:
			if (!kick(3)) return NULL;
			break;
		default: return NULL;
		}

		VA = ((ULONG64)PML4ir << 39);
		if (PML4ir & 0x100) VA |= 0xFFFF000000000000;
		VA |= ((ULONG64)PDPTir << 30);
		if (type == _1GB) {
			PA = ((PDPTe >> 12) & 0xFFFFFFFFFF) << 12;
			return 1;
		}
		VA |= ((ULONG64)PDir << 21);
		if (type == _2MB) {
			PA = ((PDe >> 12) & 0xFFFFFFFFFF) << 12;
			return 1;
		}
		VA |= ((ULONG64)PTir << 12);
		PA = ((PTe >> 12) & 0xFFFFFFFFFF) << 12;
		return 1;
	}
};

inline ULONG64 KernelTools::vread64(ULONG64 CR3, ULONG64 vaddr) {
	ULONG64 buf = 0;
	DWORD tmp;
	MsgP->mem_vread64(CR3, vaddr, &buf, &tmp);
	return buf;
}

inline ULONG64 KernelTools::read64(ULONG64 addr) {
	ULONG64 buf = 0;
	DWORD tmp;
	MsgP->mem_read64(addr, &buf, &tmp);
	return buf;
}

inline void KernelTools::write64(ULONG64 addr, ULONG64 data) {
	MsgP->mem_write64(addr, data);
}

ULONG64 KernelTools::va2pa(ULONG64 cr3, ULONG64 vaddr) {
	ULONG64 PML4_i = (vaddr >> 39) & 0x1FF;
	ULONG64 PDPTE_i = (vaddr >> 30) & 0x1FF;
	ULONG64 PDE_i = (vaddr >> 21) & 0x1FF;
	ULONG64 PTE_i = (vaddr >> 12) & 0x1FF;
	ULONG64 BO_i = vaddr & 0xFFF;
	ULONG64 tmp = cr3 + (PML4_i << 3);

	tmp = read64(tmp);

	if (!(tmp & 0x1)) return 0x0;
	if (tmp & 0x80) return (tmp & 0xFFFFFFFFFF000);

	tmp = (tmp & 0xFFFFFFFFFF000) + (PDPTE_i << 3);
	tmp = read64(tmp);

	if (!(tmp & 0x1)) return 0x0;
	if (tmp & 0x80) return (tmp & 0xFFFFFFFFFF000);

	tmp = (tmp & 0xFFFFFFFFFF000) + (PDE_i << 3);
	tmp = read64(tmp);

	if (!(tmp & 0x1)) return 0x0;
	if (tmp & 0x80) return (tmp & 0xFFFFFFFFFF000) + (vaddr & 0x1FFFFF);
	tmp = (tmp & 0xFFFFFFFFFF000) + (PTE_i << 3);
	tmp = read64(tmp);
	return (tmp & 0xFFFFFFFFFF000) + BO_i;
}

int KernelTools::swap_pa(ULONG64 cr3, ULONG64 vaddr, ULONG64 new_pa, ULONG64 *old_pa) {
	ULONG64 PML4_i = (vaddr >> 39) & 0x1FF;
	ULONG64 PDPTE_i = (vaddr >> 30) & 0x1FF;
	ULONG64 PDE_i = (vaddr >> 21) & 0x1FF;
	ULONG64 PTE_i = (vaddr >> 12) & 0x1FF;
	ULONG64 tmp = cr3 + (PML4_i << 3);
	ULONG64 pte;

	tmp = read64(tmp);

	if (!(tmp & 0x1)) return 0x1;
	if (tmp & 0x80) return 0x1;

	tmp = (tmp & 0xFFFFFFFFFF000) + (PDPTE_i << 3);
	tmp = read64(tmp);

	if (!(tmp & 0x1)) return 0x1;
	if (tmp & 0x80) return 0x1;

	tmp = (tmp & 0xFFFFFFFFFF000) + (PDE_i << 3);
	tmp = read64(tmp);

	if (!(tmp & 0x1)) return 0x1;
	if (tmp & 0x80) return 0x1;
	tmp = (tmp & 0xFFFFFFFFFF000) + (PTE_i << 3);
	pte = read64(tmp);
	*old_pa = (pte & 0xFFFFFFFFFF000);
	new_pa = (pte & 0xFFF0000000000FFF) | (new_pa & 0x000FFFFFFFFFF000);

	write64(tmp, new_pa);

	return 0;
}

ULONG64 KernelTools::find_KPCR() {
	ULONG64 tmp;
	ULONG64 tmp2;

	if (KPCR != 0) return KPCR; // Cache KPCR once it is found

	pagewalker * pw = new pagewalker(MsgP, read64(0x10a0));
	pw->PML4i = 0x1EF;
	//int limit = 0;

	while (pw->next_page()) {
		for (int i = 0; i < 0x1000; i = i + 8) {
			tmp = read64((pw->PA) + i);
			tmp2 = va2pa(0x1aa000, tmp);
			if (tmp2 == 0) continue;
			if (tmp2 == ((pw->PA + i) - 0x18)) {
				tmp2 = va2pa(0x1aa000, tmp + 0x20);
				if (read64(tmp2) == (tmp + 0x180)) {
					KPCR = tmp; // Cache KPCR once it is found
					return KPCR;
				}
				//if (limit++ >= 20) return 0;
				break;
			}
		}
	}
	return 0;
}

int KernelTools::get_dirbase(DWORD PID, PULONG64 dirbase)
{
	ULONG64 KDirBase = 0x1aa000;
	if (KPCR == 0) find_KPCR();
	ULONG64 KTHREAD = vread64(KDirBase,KPCR + 0x180 + 0x8);
	ULONG64 EPROCESS = vread64(KDirBase, KTHREAD + 0x220);
	ULONG64 NEXT_EPROCESS = EPROCESS;
	do {
		ULONG64 iPID = vread64(KDirBase, NEXT_EPROCESS + 0x2e0);
		if (PID == iPID)
		{
			// return the dirbase
			*dirbase = vread64(KDirBase, NEXT_EPROCESS + 0x28);
			return 0;
		}
		NEXT_EPROCESS = vread64(KDirBase, (NEXT_EPROCESS + 0x610)) - 0x610;
	} while (NEXT_EPROCESS != EPROCESS);

	return 1; // PID not found
}