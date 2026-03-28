onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib w1_bytes_fifo_24_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {w1_bytes_fifo_24.udo}

run -all

quit -force
