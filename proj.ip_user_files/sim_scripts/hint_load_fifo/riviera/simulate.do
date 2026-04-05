onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+hint_load_fifo -L xpm -L fifo_generator_v13_2_5 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.hint_load_fifo xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {hint_load_fifo.udo}

run -all

endsim

quit -force
