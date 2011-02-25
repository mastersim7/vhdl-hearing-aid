
restart -f -nowave 
view signals wave 
add wave input clk reset output sign addout1 addout2 latchout1 latchout2 sign1
 
force clk 0 0ns, 1 50ns -repeat 100ns
force reset 1 0, 0 400 ns
 
force input 000000000000 0
                 
force input 01000000000000 0,
01000000011010 510 ns, 
01000000110100 610 ns,
01000001001101 710 ns,
01000001100111 810 ns,
01000010000001 910 ns,
01000010011011 1010 ns,
01000010110100 1110 ns,


run 1400 ns