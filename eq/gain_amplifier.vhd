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
--USE ieee.std_logic_signed.ALL;
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
		FB_OE   : IN STD_LOGIC;
            RAW_OUTPUT : IN Multi_Result_array ;-- 1 to 8 of 36 to 0 
            GAIN : IN Gain_Array;
            OE      : OUT STD_LOGIC; 
            OUTPUT_TO_CLASSD: OUT sample;--output to class d
            GAIND_Q_OUT: OUT  Gained_result_Array_16);
END;

ARCHITECTURE gain_amplifier_arch OF gain_amplifier IS
SIGNAL started : STD_LOGIC;
BEGIN

PROCESS(clk, CE)
    VARIABLE GAIND_Q :Gain_Multi_Result; 
    VARIABLE SUMMED : Gain_Multi; -- 50 bits
    VARIABLE i : INTEGER;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
	IF reset ='1' THEN 
	    OUTPUT_TO_CLASSD<= (others=>'0');
	    i:=0;
	    OE<='0';
	    started <='0';
	ELSE
	    IF CE = '1' THEN --slower clock
            IF started = '1' THEN 
              IF i /= NUM_OF_GAINS THEN 
                 GAIND_Q(i) := eq_gain_multiply(RAW_OUTPUT(i),GAIN(i));
                 SUMMED := STD_LOGIC_VECTOR(SIGNED(SUMMED) + SIGNED(GAIND_Q(i)));
                 i := i+1;
              ELSE 
                 i:=0;
                 OUTPUT_TO_CLASSD <= SUMMED(SUMMED'LEFT DOWNTO (SUMMED'LEFT - 11));
                FOR m IN 1 TO 8 LOOP
                 GAIND_Q_OUT(m)<= GAIND_Q(m)(49 downto 34);
                END LOOP;

                 OE<='1';
              END IF;-- i
            ELSE 
            started <= FB_OE ;
            END IF; -- STARTED 
          END IF; --CE
     END IF; --reset
    END IF; --clk
END process;
END ARCHITECTURE;
              
