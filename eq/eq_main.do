restart -f -nowave
view wave
add wave sim:/eq_main/*
force clk 0 0, 1 50ns -repeat 100ns
force ce 0 0, 1  150ns -repeat 300ns
force reset 0
run 300
force reset 1 
run 300
force reset 0 
force GAIN(1) 0111111111111
force GAIN(2) 0111111111111
force GAIN(3) 0111111111111
force GAIN(4) 0111111111111
force GAIN(5) 0111111111111
force GAIN(6) 0111111111111
force GAIN(7) 0111111111111
force GAIN(8) 0111111111111
run 900
force we 1
force sample_in 000000000001
run 900
force we 0 
run 9000
