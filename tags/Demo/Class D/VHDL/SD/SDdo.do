
restart -f -nowave 
view signals wave 
add wave input clk reset output sign addout1 addout2 latchout1 latchout2 sign1 sign2
 
force clk 0 0ns, 1 50ns -repeat 100ns
force reset 1 0, 0 50 ns
 
force input 000000000000 0
force input 010011010101 90 ns
force input 100100110110 140 ns
force input 110010111011 190 ns
force input 111100010000 240 ns 
force input 111101101011 290 ns
force input 110101101001 340 ns
force input 101000100110 390 ns
force input 010111110000 440 ns

run 500 ns