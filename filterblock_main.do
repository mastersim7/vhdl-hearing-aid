# data_buffer.do
restart -f -nowave

view wave

# Loading work.data_buffer(data_buffer_arch)#1
add wave sim:/regular_buffer/*

# 50 MHz clock
force clk 0 0ns, 1 10ns -repeat 20ns
force new_sample_ready 0 0
force reset 0 0
force sample_in 000000000000
run 20ns
force reset 1
run 20ns
force reset 0
run 20ns
force sample_in 001110111111
run 20ns 
force new_sample_ready 1
run 20ns 
force new_sample_ready 0
run 2us