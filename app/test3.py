from sys import stdout
from os import getpid
from BARTender import *
from ctypes import *


def show(ptr):
	for i in range(32):
		if ((i%4) == 0):
			stdout.write('\n')
		stdout.write("%s"%ptr[i])
		stdout.write(' ')
	stdout.write('\n')

x = BARTender()

print ("Test 3: Allocate 2 pages of memory and swap their PTEs")

a_mem = ctypes.windll.kernel32.VirtualAlloc(ctypes.c_int(0),
     ctypes.c_int(0x1000),
     ctypes.c_int(0x3000),
     ctypes.c_int(0x40))
	 
a = cast(a_mem, POINTER(c_char))
	 
b_mem = ctypes.windll.kernel32.VirtualAlloc(ctypes.c_int(0),
     ctypes.c_int(0x1000),
     ctypes.c_int(0x3000),
     ctypes.c_int(0x40))
	 
b = cast(b_mem, POINTER(c_char))

for i in range(0x1000):
	a[i] = 1
	b[i] = 2

print ("\nDisplaying A...")
show(a)
print ("\nDisplaying B...")
show(b)
print("")

dirbase = x.get_dirbase(getpid())
print("Local dirbase: 0x%016x\n"%dirbase)
a_pmem = x.va2pa(dirbase,a_mem)
b_pmem = x.va2pa(dirbase,b_mem)
print("A - Vaddr: 0x%016x Paddr: 0x%016x"%(a_mem,a_pmem))
print("B - Vaddr: 0x%016x Paddr: 0x%016x\n"%(b_mem,b_pmem))

print("Swapping A and B's physical pointers in their PTEs...\n")
x.swap_pa(dirbase,a_mem,b_pmem)
x.swap_pa(dirbase,b_mem,a_pmem)
print ("\nDisplaying A...")
show(a)
print ("\nDisplaying B...")
show(b)
print("")
print("Swapping them back...\n")
x.swap_pa(dirbase,a_mem,a_pmem)
x.swap_pa(dirbase,b_mem,b_pmem)
print ("\nDisplaying A...")
show(a)
print ("\nDisplaying B...")
show(b)

x.Close()

