# top.do
vsim work.top_main 
restart -f -nowave
view wave
add wave sim:/top_main/*

# 50 MHz clock
force clk 0 0ns, 1 10ns -repeat 20ns
#force in 000000000000
force reset 1 20ns, 0 40ns
force ADC_DIN 0 50ns, 1 200ns, 0 300ns, 1 400ns -repeat 500ns
run 80ns
run 200000000ns
