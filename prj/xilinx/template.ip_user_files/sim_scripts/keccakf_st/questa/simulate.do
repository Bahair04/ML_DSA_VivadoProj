onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib keccakf_st_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {keccakf_st.udo}

run -all

quit -force
