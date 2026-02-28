onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib VectorY_CoeffRAM_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {VectorY_CoeffRAM.udo}

run -all

quit -force
