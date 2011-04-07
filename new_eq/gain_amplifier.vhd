--##########################################################
--#THIS FILE IS NOT TO BE EDITTED IF NOT ROBIN IS CONTACTED# 
--##########################################################
-- gain_amplifier.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- Date: 2011-03-16
-- Description:
-- basic amplifier
--
-- It is still in the implementation phase. 
-- This component will give one output every 8 CEs 
--
--Verified by Robin Andersson 2011-03-21
--However, the input wordlength is needlessly large
-- removed CE no need in asic or FPGA right now /Shwan

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY gain_amplifier IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_GAINS : NATURAL := 8;
            NUM_OF_FILTERS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
           -- CE      : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            FB_OE   : IN STD_LOGIC;
            RAW_OUTPUT : IN Multi_Result_array ;-- 0 to 8 of 36 to 0 
            GAIN    : IN Gain_Array;
            OE      : OUT STD_LOGIC; 
            OUTPUT_TO_CLASSD: OUT sample;--output to class d
            GAIND_Q_OUT: OUT  Gained_result_Array_16);
END;

ARCHITECTURE gain_amplifier_arch OF gain_amplifier IS
	SIGNAL started : STD_LOGIC;
BEGIN

PROCESS(clk)
    VARIABLE GAIND_Q :Gain_Multi_Result; 
    --VARIABLE SUMMED : Gain_Multi_extended; -- 53 bits added extra 3 bits to account for overflow ,
    VARIABLE SUMMED : STD_LOGIC_VECTOR(36 DOWNTO 0); 
	--as we r doing 8 addition 3 bit is enough to cover all overflow
    VARIABLE i : INTEGER;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
	IF reset ='1' THEN 
	    OUTPUT_TO_CLASSD<= (others=>'0');
	    SUMMED := (others=>'0'); --initialised  to zero/anand
	    i:=1;-- i should be 1 as array start from 1 (to 8)/anand 
	    OE<='0';
	    started <='0'; -- we wait for a enable signal to stert
	    
	ELSE
	
	  --  IF CE = '1' THEN --slower clock
	            IF started = '1' THEN 
        	    	IF (i /= (NUM_OF_GAINS)) THEN --+1
                        OE <= '0';
		               -- GAIND_Q(i):= STD_LOGIC_VECTOR(SHIFT_LEFT(SIGNED(RAW_OUTPUT(i)) * SIGNED(GAIN(i)),1));
                		--SUMMED := STD_LOGIC_VECTOR(SIGNED(SUMMED) + SIGNED(GAIND_Q(i)));
						SUMMED := STD_LOGIC_VECTOR(SIGNED(SUMMED) + SIGNED(RAW_OUTPUT(i)));
                        i := i+1;
	                ELSE
		                i:=1; -- ready restart
		                OUTPUT_TO_CLASSD <= NOT(SUMMED((SUMMED'LEFT))) & SUMMED((SUMMED'LEFT-1) DOWNTO (SUMMED'LEFT - 11)); -- concantinated to 13 bits a signle value out
                	        FOR m IN 0 TO 7 LOOP -- update the output for the interface at once
               				GAIND_Q_OUT(m)<= GAIND_Q(m)(49 downto 34);
		                END LOOP;
		                SUMMED := (others=>'0'); --initialised  to zero/anand
                	 	OE<='1';
	                END IF;-- i
          	    ELSE --Started 
		        started <= FB_OE ;-- sleep until the Fiters output gets updated
	            END IF; -- STARTED 
          --  END IF; --CE
        END IF; --reset
    END IF; --clk
END process;
END ARCHITECTURE;
              
