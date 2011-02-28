quit -sim
# data_buffer.do
vsim work.data_buffer 
restart -f -nowave

view wave

# Loading work.data_buffer(data_buffer_arch)#1
add wave sim:/data_buffer/*
add wave 
force clk 0 0ns, 1 50ns -repeat 100ns

run 100ns
force reset 1
run 200ns
force reset 0
run 1ns
force ce  1 
run 1ns
force sample_in 001110111111
run 1ns 
force load 1
run 500ns 
force load 0 
run 1 ns 
force read 1 
run 500ns 


