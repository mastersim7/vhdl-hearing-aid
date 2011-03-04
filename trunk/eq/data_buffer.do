quit -sim
# data_buffer.do
vsim work.data_buffer 
restart -f -nowave

view wave

# Loading work.data_buffer(data_buffer_arch)#1
add wave sim:/data_buffer/*
# 50 MHz clock
force clk 0 0ns, 1 10ns -repeat 20ns

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
force RE 1 0, 0 400ns 
run 4us 


