# serial_fir_filter.do
# Mathias Lundell
# 2010-10-25
restart -f -nowave
view wave
add wave clk x reset start y finished

# Reset and set starting signals
force start 0 0ns
force reset 0 0ns, 1  50ns, 0 100ns
force x 00000000 0ns

# Clock signal, period 100 unit seconds
force clk 0 0ns, 1 50ns -repeat 100ns

#Run 
# 0.5
force x 01000000 300ns
force start 1 400ns, 0 500ns

# -0.25
force x 11100000 900ns 
force start 1 1000ns, 0 1100ns

# 0.375
force x 00110000 1500ns 
force start 1 1600ns, 0 1700ns

# -0.75
force x 10100000 2100ns
force start 1 2200ns, 0 2300ns

run 3200ns