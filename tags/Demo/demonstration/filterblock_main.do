restart -f -nowave
view wave
add wave sim:/filterblock_main/*
force clk 0 0, 1 50ns -repeat 100ns
force ce 0 0, 1  150ns -repeat 300ns
force reset 0
run 300 ns
force reset 1 
run 300 ns
force reset 0 
force sample1 011111111111
force sample2 011111111111
run 900 ns
force updated 1
run 300 ns
force updated 0
run 132000 ns
