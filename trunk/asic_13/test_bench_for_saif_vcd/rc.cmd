# Cadence Encounter(R) RTL Compiler
#   version v09.10-p104_1 (32-bit) built Jun 18 2009
#


source test.s
write_hdl > top_main.v
read_vcd -static -vcd_module top_main_comp /chalmers/users/anasak/vhdl-hearing-aid/asic/test_bench_for_saif_vcd/verification/vcd/top.vcd
report power > power.txt
report power 
report power 
