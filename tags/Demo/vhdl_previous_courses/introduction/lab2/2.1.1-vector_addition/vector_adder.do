# vector_adder.do
# 100910 Mathias Lundell
restart -f -nowave 
view signals wave 
add wave a b y
 
force a 0000 0, 0001 50, 0010 100, 0111 150, 1000 200, 1010 250, 1100 300, 1111 350
force b 0000 0, 1000 50, 0010 100, 0111 150, 1000 200, 0010 250, 1100 300, 1111 350
run 400