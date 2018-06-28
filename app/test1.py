from BARTender import *
import sys

x = BARTender()

print ("\nTest 1a: Writing to FPGA Bar 0 Scratch\n")
tmp = x.fpgaRead64(8)
print ("(0x%04x): 0x%016x" % (0x8,tmp))
print ("Writing 0xa5a5a5a5cafecafe to Scratch...")
x.fpgaWrite64(8,0xa5a5a5a5cafecafe)
print ("(0x%04x): 0x%016x" % (0x8,x.fpgaRead64(8)))
print ("Reverting Scratch...")
x.fpgaWrite64(8,tmp)
print ("(0x%04x): 0x%016x" % (0x8,x.fpgaRead64(8)))
print ("")

print ("\nTest 1b: Writing to physical memory address 0x0000\n")
tmp2 = x.memRead64(0)
print ("(0x%04x): 0x%016x" % (0x0,tmp2))
print ("Writing 0xa5a5a5a5cafecafe to 0x0000...")
x.memWrite64(0,0xa5a5a5a5cafecafe)
print ("(0x%04x): 0x%016x" % (0x0,x.memRead64(0)))
print ("Reverting memory...")
x.memWrite64(0,tmp2)
print ("(0x%04x): 0x%016x" % (0x0,x.memRead64(0)))
print ("")

print ("\nTest 1c: Dumping the beginning of physical memory\n")
for i in range(0,0x180,16):
	tmp = (x.memRead64(i+1)<<64)|x.memRead64(i)
	for j in range(16):
		if ((j%16)==0):
			sys.stdout.write("(0x%04X) "%(i))
		sys.stdout.write("%02X "%(tmp&0xff))
		tmp >>= 8
		if ((j%16)==7):
			sys.stdout.write("- ")
		if ((j%16)==15):
			sys.stdout.write("\n")
	


x.Close()
