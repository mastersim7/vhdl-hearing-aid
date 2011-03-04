quit -sim
# data_buffer.do
vsim work.regular_buffer 
restart -f -nowave

view wave

# Loading work.data_buffer(data_buffer_arch)#1
add wave sim:/regular_buffer/*

# 50 MHz clock
force clk 0 0ns, 1 10ns -repeat 20ns
force re 0 0
force we 0 0
force reset 0 0
force sample_in 000000000000 0

run 20ns
force reset 1
run 20ns
force reset 0
run 20ns
force sample_in 001110111111
run 20ns 
force WE 1
run 20ns 
force WE 0
force sample_in 110000000000
run 20ns
force WE 1
run 20ns
force WE 0
run 20ns
force WE 1
force sample_in 000110000000
run 20ns
force WE 0
run 20ns
force sample_in 010000001000
force WE 1
run 20ns
force WE 0
run 20ns
force WE 1
force sample_in 000011110001
run 20ns
force WE 0
run 20ns
force sample_in 101010101000
force WE 1
run 20ns
force WE 0
run 20ns
force RE 1 0
run 4us 



