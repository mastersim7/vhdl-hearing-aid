restart -f -nowave
view wave
#add wave clk reset CO CE sample1 sample2 OE Q
add wave sim:/serial_filter/*
force clk 0 0, 1 50ns -repeat 100ns
force reset 0
run 100
force reset 1 
run 200
force reset 0 
run 100

force CO 000000000000000000000001
force CE 1
run 200
force updated 1 
run 100

force sample1 000000000001
force sample2 000000000001

run 13000ns
