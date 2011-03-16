-- gain_amplifier.vhd
-- Author: Mathias Lundell,Shwan Ciyako
-- Date: 2011-03-16
-- Description:
-- basic amplifier
--
-- It is still in the implementation phase. 
-- This component will give one output every 8 CEs 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY gain_amplifier IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 12; --mathias is this number ok?
            NUM_OF_GAINS : NATURAL := 8;
            NUM_OF_FILTERS);
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            RAW_OUTPUT : IN sample;
            GAIN : IN sample;
            OE      : OUT STD_LOGIC; 
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;
ARCHITECTURE gain_amplifier_arch OF gain_amplifier IS
    

BEGIN

PROCESS(clk, CE)
    VARIABLE GAIND_Q : STD_LOGIC_VECTOR( 2*sample'LENGTH-1 DOWNTO 0 );
    VARIABLE SUMMED : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0);
    VARIABLE i : INTEGER;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
	IF reset ='1' THEN 
	    Q <= (others=>'0');
	    i:=0;
	    OE<='0';
	ELSE
	
           IF CE = '1' THEN --slower clock

              IF i /= NUM_OF_GAINS THEN 
                 GAIND_Q := eq_multiply(RAW_OUTPUT,GAIN);
                 SUMMED := eq_addition(SUMMED, GAIND_Q);
                 i := i+1;
              ELSE 
                 i:=0;
                 Q<=SUMMED(NUM_BITS_OUT-1 DOWNTO 0);
                 OE<='1'
              END IF;
