# fulladd_ovf.do
# 100910 Mathias Lundell
restart -f -nowave 
view signals wave 
add wave cin a b s overflow
radix -decimal

force a   0000 0, 0001 50, 0010 100, 0111 150, 1000 200, 1010 250
force b   0000 0, 1000 50, 0010 100, 0111 150, 1000 200, 0010 250
force cin    1 0,    0 50,    1 100,    1 150,    1 200,    0 250
run 300

force a   1100 0, 1111 50, 1001 100, 1011 150
force b   1100 0, 1111 50, 1001 100, 1011 150
force cin    0 0,    0 50,    0 100,    0 150
run 200
