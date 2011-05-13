source /chalmers/sw/sup/cse/userinit/bash
module add DAT110

ncvhdl -messages -linedebug /chalmers/sw/sup/cds/hcmos9gp-9.2/CORE9GPHS_SNPS_AVT_4.1.a/VHDL_FUNCT/CORE9GPHS_VHDL_FUNCT.vhd
ncvhdl -messages -linedebug /chalmers/sw/sup/cds/hcmos9gp-9.2/CORE9GPHS_SNPS_AVT_4.1.a/VHDL_FUNCT/CORE9GPHS_COMPONENTS.vhd
ncvhdl -messages -linedebug /chalmers/sw/sup/cds/hcmos9gp-9.2/CORX9GPHS_SNPS_AVT_7.1.a/VHDL_FUNCT/CORX9GPHS_VHDL_FUNCT.vhd
ncvhdl -messages -linedebug /chalmers/sw/sup/cds/hcmos9gp-9.2/CORX9GPHS_SNPS_AVT_7.1.a/VHDL_FUNCT/CORX9GPHS_COMPONENTS.vhd
ncvlog top_main.v
ncvhdl -messages -linedebug -v93 test_bench.vhd
ncelab -messages -v93 WORKLIB.tb:tb_arch
ncsim -input ./ncsim_VCD.tcl WORKLIB.tb:tb_arch
