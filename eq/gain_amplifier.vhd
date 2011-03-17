-- gain_amplifier.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
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
            NUM_BITS_OUT : NATURAL := 13; --mathias is this number ok?
            NUM_OF_GAINS : NATURAL := 8;
            NUM_OF_FILTERS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
				reset   : IN STD_LOGIC;
            RAW_OUTPUT : IN extended_sample; --13 bits
            GAIN : IN extended_sample;
            SUMMED_OUT_TO_AVERAGE : OUT extended_sample;
            OE      : OUT STD_LOGIC; 
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;
ARCHITECTURE gain_amplifier_arch OF gain_amplifier IS
    

BEGIN

PROCESS(clk, CE)
    VARIABLE GAIND_Q : STD_LOGIC_VECTOR( 2*extended_sample'LENGTH-1 DOWNTO 0 );
    VARIABLE SUMMED : extended_sample;
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
                 GAIND_Q := eq_gain_multiply(RAW_OUTPUT,GAIN);
                 SUMMED := eq_adder(SUMMED, GAIND_Q(GAIND_Q'LEFT DOWNTO (GAIND_Q'LEFT - 13)));-- how this adder should be need details about saturation 
                  
                 i := i+1;
              ELSE 
                 i:=0;
					  SUMMED_OUT_TO_AVERAGE <= SUMMED;
                 Q<=SUMMED(NUM_BITS_OUT-1 DOWNTO 0);
                 OE<='1';
              END IF;-- i
          END IF; --CE
     END IF; --reset
    END IF; --clk
END process;
END ARCHITECTURE;
              
