# fir_filter2.do
# Mathias Lundell
# 2010-10-25
restart -f -nowave
view wave
add wave x reset start y

#Run
force reset 0 0, 1  50ns, 0 100ns
force start 0 0ns
force x 00000000 0ns

# 0.5
force x 01000000 300ns

force start 1 400ns, 0 500ns

# -0.25
force x 11100000 600ns
#force x 01000000 600ns
force start 1 700ns, 0 800ns

# 0.375
force x 00110000 900ns
#force x 01000000 900ns
force start 1 1000ns, 0 1100ns

# -0.75
force x 10100000 1200ns
#force x 01000000 1200ns
force start 1 1300ns, 0 1400ns
run 2000ns