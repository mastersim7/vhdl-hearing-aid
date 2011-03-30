# eq_main.do

restart -f -nowave
view wave
add wave sim:/eq_main/*

# 50 MHz clock
force clk 0 0ns, 1 10ns -repeat 20ns
force sample_in 000000000000
force reset 1 20ns, 0 40ns
run 40ns
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns

run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 50us
force new_sample_ready 0 0, 1 10ns, 0 20ns
run 20us