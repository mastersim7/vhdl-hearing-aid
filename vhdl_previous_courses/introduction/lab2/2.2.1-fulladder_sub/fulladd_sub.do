# fulladd_sub.do
# 100910 Mathias Lundell
restart -f -nowave 
view signals wave 
add wave add saturate a b s overflow
radix -decimal

# Saturation deactivated
force saturate 0 0
force a   0000 0, 0001 50, 0010 100, 0111 150, 1000 200, 1010 250
force b   0000 1, 1000 51, 0010 101, 0101 151, 1010 201, 0010 251
force add    0 0,    1 52,    0 102,    1 152,    0 202,    0 252
run 300

force a   1100 0, 1111 50, 1001 100, 1011 150
force b   1100 1, 1110 51, 1101 101, 1001 151
force add    0 2,    0 52,    0 102,    0 152
run 200

# Make some space...
force a 0 0
force b 0 0
force add 0 0
run 200

# Saturation activated
force saturate 1 0
force a   0000 0, 0001 50, 0010 100, 0111 150, 1000 200, 1010 250
force b   0000 1, 1000 51, 0010 101, 0101 151, 1010 201, 0010 251
force add    0 2,    1 52,    0 102,    1 152,    0 202,    0 252
run 300

force a   1100 0, 1111 50, 1001 100, 1011 150
force b   1100 1, 1110 51, 1101 101, 1001 151
force add    0 0,    0 50,    0 100,    0 150
run 200

# Make some space...
force a 0 0
force b 0 0
force add 0 0
run 200