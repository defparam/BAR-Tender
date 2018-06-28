# BAR-Tender 

Welcome everyone! BAR-Tender is a physical FPGA I/O Device which services physical memory reads/writes via UMDF2 driver. This project is a succesor to [pciworm](http://github.com/defparam/pciworm.git "pciworm") and is enhanced with much more features.

Features:
- Perfect Windows FPGA UMDF2 driver example to fork
- Framework and examples written for **Python 3.5** (Ctypes WinAPI Interface)
- **fpgaRead64()** and **fpgaWrite64()** to FPGA BAR0 region
- **memRead64()** and **memWrite64()**
	-These functions instruct the FPGA/Driver to perform physical memory access
- **vmemRead64()** and **vmemWrite64()**
	-These functions instruct the FPGA/Driver to perform a virtual memory access
- **find_KPCR()** - Searches Kernel memory for the Kernel Processor Control Region structure which is used for finding other Kernel structures of interest
- **va2pa()** - Translates a virtual address to its physical address
- **get_dirbase()** - Walks the EPROCESS list and finds CR3 for a specific PID
- **swap_pa()** - (DANGEROUS) - Allows you to swap the physical address pointer in the PTE of a given virtual address and returns the old physical address
- And more...

# Install
This project is completely open-source so feel free to install Vivado and Visual Studio to compile your own binaries. However for those who would like to quick use the existing binaries I have releases the FPGA bitstream/drivers/test certificate in the /release area
1. Once you get the PicoEVB you will need to load the BAR-Tender.bit file onto the device. There are many guides that exist on how to do this.
2. In order to install the UMDF2 driver you will need to load the test certificate and then after install the inf file by right clicking and selecting install
3. If you do not trust the certificate and binaries feel free to compile from source!

# Hardware
The FPGA platform used on this project is the [PicoEVB](http://www.picoevb.com/ "PicoEVB"). The PicoEVB is a relatively inexpensive FPGA PCIe card that fits into an M.2 A+E slots. You can purchase your own PicoEVB for **$219** dollars. The hardware specs are as follows:

<center>

| Feature | Specification |
| --- | --- |
| FPGA | Xilinx Artix XC7A50T-2CSG325C |
| Form Factor | M.2 (NGFF), keyed for A and E slots |
| Dimensions | 22x30x3.8 mm |
| Host Interface | PCIe x1 gen 2 (5 Gb/s) |
| Host Tools | Vivado 2017.3 preferred |
| MGT Loopback | Yes |
| Built-in JTAG | Yes |
| External I/O configurations <BR/> via I/O connector | (digital+ differential analog) <BR/> 4+0 <BR/> 2+1 <BR/> 0+2 |
| External I/O via PCIe connector | 4x 3.3V digital I/O (configurable) |
| External MGT connection | 1x MGT via U.FL connectors |
| External clock ref | 1x clkin via U.FL connectors |
| User-controllable LEDs | 3 |


![](https://i.imgur.com/JJrGQGq.png) </center>

