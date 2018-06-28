from BARTender import *


x = BARTender()
vkpcr = x.find_KPCR()
print("")
print("Found KPCR:             0x%016x" % vkpcr)
print("Found KPRCB:            0x%016x" % vkpcr.KPRCB())
print("Found CurrentThread:    0x%016x" % vkpcr.KPRCB().CurrentThread())

print ("\nTest 2: Print out all EPROCESS pointers in kernel memory\n")

proc = vkpcr.KPRCB().CurrentThread().Process()
next = proc
while (next.mmProcessLinks_flink().EPROCESS != proc.EPROCESS):
	param = next.Peb().ProcessParameters()
	if (param.ProcessParameters == 0):
		print("Found EPROCESS: 0x%016x PID: 0x%04X Name: %s (NO PEB)" 
		% (next,next.UniqueProcessID(),next.ImageFileName()))
	else:
		print("Found EPROCESS: 0x%016x PID: 0x%04X ImagePathName: %s CR3: 0x%016x" 
		% (next,next.UniqueProcessID(),next.Peb().ProcessParameters().ImagePathName(), next.DirectoryTableBase()))
	next = next.mmProcessLinks_flink()
	if next.EPROCESS == 0: break


x.Close()

