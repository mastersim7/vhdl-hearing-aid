# serial_adder.do
# 100914 Mathias Lundell
restart -f -nowave 
view signals wave 
add wave add clk start a b y finished started
radix -decimal

force clk 0 0, 1 50 -repeat 100

# sdfdf
force start 0 0, 1 50, 0 150, 1 500, 0 600, 1 1000, 0 1100, 1 1500, 0 1600, 1 2000, 0 2100, 1 2500, 0 2600
force a   0100 0, 0001 400, 0010 800, 0111 1200, 1000 1600, 1010 2000
force b   0001 0, 1000 400, 0010 800, 0111 1200, 1000 1600, 0010 2000
force add    0 0,    0 50,    0 100,     0  150,    0  200,    0  250
run 3200