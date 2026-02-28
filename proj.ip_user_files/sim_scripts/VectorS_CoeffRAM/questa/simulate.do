onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib VectorS_CoeffRAM_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {VectorS_CoeffRAM.udo}

run -all

quit -force
