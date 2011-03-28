# distributed_fir_filter.do
# Mathias Lundell
# 2010-10-25
restart -f -nowave
view wave
add wave clk x reset start y finished

# Reset and set starting signals
force start 0 0ns
force reset 0 0, 1  50ns, 0 100ns
force x 00000000 0ns

# Clock signal, period 100 unit seconds
force clk 0 0ns, 1 50ns -repeat 100ns

#Run 
# 0.5
force x 01000000 300ns
force start 1 400ns, 0 500ns

# -0.25
force x 11100000 1300ns 
force start 1 1400ns, 0 1500ns

# 0.375
force x 00110000 2300ns 
force start 1 2400ns, 0 2500ns

# -0.75
force x 10100000 3300ns 
force start 1 3400ns, 0 3500ns

run 5000ns