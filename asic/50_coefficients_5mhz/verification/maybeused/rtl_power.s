set_attribute library {{
/chalmers/sw/sup/cds/hcmos9gp-9.2/CORE9GPHS_SNPS_AVT_4.1.a/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/CORE9GPHS_Nom.lib
/chalmers/sw/sup/cds/hcmos9gp-9.2/CORX9GPHS_SNPS_AVT_7.1.a/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/CORX9GPHS_Nom.lib
/chalmers/sw/sup/cds/hcmos9gp-9.2/CLOCK9GPHS_SNPS_AVT_4.1/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/CLOCK9GPHS_Nom.lib
/chalmers/sw/sup/cds/hcmos9gp-9.2/PR9M6_SNPS_AVT_2.1.a/SNPS/bc_1.32V_0C_wc_1.08V_105C/PHS/PR9M6_Nom.lib
}}

read_hdl -vhdl ALU_RCA.vhdl FA.vhdl shifter.vhdl bitwise.vhdl RCA.vhdl 
	
elaborate

define_clock -name main_clk -period 5000 [find / -port Clk]

synthesize -to_mapped -effort low

set_attribute lp_asserted_probability 0.5 /designs/ALU_RCA/ports_in/A*
set_attribute lp_asserted_probability 0.5 /designs/ALU_RCA/ports_in/B*
set_attribute lp_asserted_probability 0.5 /designs/ALU_RCA/ports_in/Op*
set_attribute lp_asserted_probability 1.0 /designs/ALU_RCA/ports_in/Reset*

set_attribute lp_asserted_toggle_rate 0.1 /designs/ALU_RCA/ports_in/A*
set_attribute lp_asserted_toggle_rate 0.1 /designs/ALU_RCA/ports_in/B*
set_attribute lp_asserted_toggle_rate 0.1 /designs/ALU_RCA/ports_in/Op*
set_attribute lp_asserted_toggle_rate 1.0 /designs/ALU_RCA/ports_in/Reset*

set_attribute lp_power_analysis_effort medium /


#define_clock -name main_clk -period 1250 clk
#synthesize -to_mapped -effort medium
#report timing
#ncvhdl -messages -linedebug -v93 read_from_file.vhdl
#ncvhdl -messages -linedebug -v93 adder_rca.vhdl
#ncvhdl -messages -linedebug -v93 alu_rca.vhdl
#ncvhdl -messages -linedebug -v93 alu_rca_tb.vhdl


#ncelab -messages -v93 WORKLIB.alu_rca_tb:arch_alu_rca_tb

#ncsim -input ./ncsim.tcl WORKLIB.alu_rca_tb:arch_alu_rca_tb
