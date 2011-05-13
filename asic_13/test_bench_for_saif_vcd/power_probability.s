set_attribute lp_asserted_probability 0.5 /designs/top_main/ports_in/sample_in*       
set_attribute lp_asserted_probability 0.002 /designs/top_main/ports_in/new_sample_ready*       
set_attribute lp_asserted_probability 1.0 /designs/top_main/ports_in/reset*       
set_attribute lp_asserted_toggle_rate 0.4 /designs/top_main/ports_in/sample_in*
set_attribute lp_asserted_toggle_rate 0.4 /designs/top_main/ports_in/new_sample_ready*
set_attribute lp_asserted_toggle_rate 1.0 /designs/top_main/ports_in/reset*
set_attribute lp_power_analysis_effort medium /
report power clk >clk_power_10mhz_100coeff.txt
report power > power_toggle0.4_10mhz_100coeff.txt