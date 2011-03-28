restart -f -nowave
view wave
add wave sim:/eq_main/*
force clk 0 0, 1 50ns -repeat 100ns
force ce 0 0, 1  150ns, 0 200 -repeat 300ns
force reset 0
run 300
force reset 1 
run 300
force reset 0 
run 300
#force GAIN(1) 0111111111111
#force GAIN(2) 0111111111111
#force GAIN(3) 0111111111111
#force GAIN(4) 0111111111111
#force GAIN(5) 0111111111111
#force GAIN(6) 0111111111111
#force GAIN(7) 0111111111111
#force GAIN(8) 0111111111111
force sample_in 000000000000 0, 011111111111 300 , 000000000000 900
#, 000111111110 90000, 000111111110 180300, 000111111110 360300 -repeat 360300
#run 300
force we 0 0 ,1 301
#,0 601,1 90001,0 90301,1 180301,0 180601, 1 360301, 0 360601 -repeat 360601           
#run 300

#force we 0 
#run 300
#run 720000

#run 300
#force we 1        
#run 300
#force we 0 
#run 300
run 1000000ns



