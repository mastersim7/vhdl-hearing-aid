

set_attribute library {{
/chalmers/sw/sup/cds/hcmos9gp-9.2/CORE9GPHS_SNPS_AVT_4.1.a/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/CORE9GPHS_Nom.lib
/chalmers/sw/sup/cds/hcmos9gp-9.2/CORX9GPHS_SNPS_AVT_7.1.a/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/CORX9GPHS_Nom.lib
/chalmers/sw/sup/cds/hcmos9gp-9.2/CLOCK9GPHS_SNPS_AVT_4.1/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/CLOCK9GPHS_Nom.lib
/chalmers/sw/sup/cds/hcmos9gp-9.2/PR9M6_SNPS_AVT_2.1.a/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/PR9M6_Nom.lib
}}

read_hdl -vhdl EQ_data_type.vhd average_if.vhd eq_main.vhd filterblock_main.vhd gain_amplifier.vhd new_adc.vhd regular_buffer.vhd rxfrompc.vhd serial_filter.vhd top_main.vhd tx_to_pc.vhdl SD2.vhd Latch.vhd Full_adder.vhd ripple_addsub.vhd


elaborate
define_clock -name main_clk -period 50000 [find / -port clk]
synthesize -to_mapped -effort low
report timing > timing_20MHZ.txt 
report gates > gates_20mhz.txt
report area > area_20mhz.txt

