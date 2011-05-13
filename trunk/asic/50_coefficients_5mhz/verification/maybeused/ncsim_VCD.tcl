database -open vcddb -vcd -default -into ALU.vcd -timescale ps
probe -create -vcd :test -all -depth all
run
exit
