# multiplier.do
# 100920 Mathias Lundell
restart -f -nowave 
view signals wave 
add wave clk start a b y finished
radix -binary

force clk 0 0, 1 50 -repeat 100
# a positive, b positive
force a "0100"  0
force b "0010"  0
force start 0 0, 1 50, 0 100
run 1000

# a negative, b positive
force a "1100"  0
force b "0010"  0
force start 0 0, 1 50, 0 100
run 1000

# a positive, b negative
force a "0100"  0
force b "1010"  0
force start 0 0, 1 50, 0 100
run 1000

# a negative, b negative
force a "1001"  0
force b "1010"  0
force start 0 0, 1 50, 0 100
run 1000

# a almost most negative, b almost most negative
force a "1001"  0
force b "1001"  0
force start 0 0, 1 50, 0 100
run 1000

# a most positive, b most positive
force a "0111"  0
force b "0111"  0
force start 0 0, 1 50, 0 100
run 1000

radix -decimal