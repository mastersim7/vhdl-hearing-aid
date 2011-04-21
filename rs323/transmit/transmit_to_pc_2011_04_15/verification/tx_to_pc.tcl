analyze -vhdl tx_to_pc.vhdl
analyze -vhdl -psl tx_to_pc.psl
elaborate -vhdl -parameter n 8  -top HIF_RS232_Transmit_to_PC(Behavioral)
reset "reset"
clock clk
