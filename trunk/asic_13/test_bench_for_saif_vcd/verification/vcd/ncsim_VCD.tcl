database -open vcddb -vcd -default -into top.vcd -timescale ps
probe -create -vcd :top_main_comp -all -depth all
run
exit
