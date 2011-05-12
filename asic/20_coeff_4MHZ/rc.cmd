# Cadence Encounter(R) RTL Compiler
#   version v09.10-p104_1 (32-bit) built Jun 18 2009
#


source test.s
define_clock -name main_clk -period 20000 [find / -port clk]
synthesize -to_mapped -effort low
