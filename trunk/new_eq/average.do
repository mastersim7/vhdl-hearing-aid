vsim work.average_if
restart -f -nowave
view wave
add wave sim:/average_if/*
force clk 0 0, 1 50ns -repeat 100ns
force ce 0 0, 1  150ns, 0 200ns -repeat 300ns
force OE_GAINAMP 0 0, 1  150ns, 0 200ns -repeat 300ns

force reset 0
run 300ns
force reset 1 
run 300ns
force reset 0 

force REQ 1     
          
force Gained_Samples(0) 0000000100000000
force Gained_Samples(1) 0000000100000000
force Gained_Samples(2) 0000000100000000
force Gained_Samples(3) 0000000100000000
force Gained_Samples(4) 0000000100000000
force Gained_Samples(5) 0000000100000000
force Gained_Samples(6) 0000000100000000
force Gained_Samples(7) 0000000100000000

 
run 900000


