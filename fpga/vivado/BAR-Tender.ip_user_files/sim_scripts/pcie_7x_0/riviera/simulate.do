onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+pcie_7x_0 -L xilinx_vip -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.pcie_7x_0 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {pcie_7x_0.udo}

run -all

endsim

quit -force
