
restart -f -nowave
view wave
add wave a b clk reset output


force reset 0 0, 1  50ns, 0 100ns


# Clock signal, period 100 unit seconds
force clk 0 0ns, 1 50ns -repeat 100ns

force a 010001000000 0, 001000011000 210 ns
force b 000000000000 0, 000011001010 310 ns


run 400ns