# filterblock_main.do
vsim -voptargs=+acc work.filterblock_main
restart -f -nowave
view wave
add wave sim:/filterblock_main/*

# 50 MHz clock
force clk 0 0ns, 1 10ns -repeat 20ns
force sample1 100000000001
force sample2 000001100000
force updated 0 0, 1 200ns, 0 220ns
run 20us
