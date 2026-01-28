onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib ExpandY_sipo_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {ExpandY_sipo.udo}

run -all

quit -force
