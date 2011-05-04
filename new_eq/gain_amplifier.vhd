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
            RAW_OUTPUT : IN Multi_Result_array ;-- 0 to 7 of 25 to 0 
            GAIN    : IN Gained_result_Array;
            OE      : OUT STD_LOGIC; 
            OUTPUT_TO_CLASSD: OUT sample;--output to class d
            select_filters:STD_LOGIC_VECTOR( 7 DOWNTO 0 );
            GAIND_Q_OUT: OUT  Gained_result_Array_16);
END;

ARCHITECTURE gain_amplifier_arch OF gain_amplifier IS
	SIGNAL started : STD_LOGIC;
    SIGNAL temp3   : Gain_Multi_Result_12;
BEGIN

PROCESS(clk)
    VARIABLE GAIND_Q :Gain_Multi_Result; 
    VARIABLE temp2 :Gain_Multi_Result_39; 
    --VARIABLE SUMMED : Gain_Multi_extended; -- 53 bits added extra 3 bits to account for overflow ,
    VARIABLE SUMMED : STD_LOGIC_VECTOR(25 DOWNTO 0); 
	--a as we r doing 8 addition 3 bit is enough to cover all overflow
    VARIABLE i : INTEGER:=0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
	IF reset ='1' THEN 
	    --OUTPUT_TO_CLASSD<= (others=>'0');
	    SUMMED := (others=>'0'); --initialised  to zero/anand
	    i:=0;-- i should be 1 as array start from 1 (to 8)/anand 
	    OE<='0';
		 FOR k IN 0 TO 7 LOOP
	    GAIND_Q(k) := (OTHERS => '0');
	    END LOOP;
	    started <='0'; -- we wait for a enable signal to stert
	    
	ELSE
	
	  --  IF CE = '1' THEN --slower clock
	            IF started = '1' THEN 
        	    	IF (i /= (NUM_OF_GAINS)) THEN --+1
                        OE <= '0';
                        --temp2 <=  RAW_OUTPUT(25) & RAW_OUTPUT(24 DOWNTO 14) ; only msb 12 of rawoutput does not give any output 
		               temp2(i) := STD_LOGIC_VECTOR(SHIFT_LEFT(SIGNED(RAW_OUTPUT(i)) * SIGNED(GAIN(i)),1));
--                       temp3(i) <= temp2(i)(38 downto 27);
                        GAIND_Q(i) := temp2(i)(35 downto 10);
                        --output goes noisy at gain states more than 14  when this  range is 25 to 0
                        --output goes noisy at gain states more than 25  when this  range is 30 to 5
                          --output  goes noisy at gain states more than  31 when this  range is 35 to 10 but o/p dies at low gain states
                        --output never goes noisy  when this  range is 38 to 13 but o/p dies at low gain states
                        
                                
                SUMMED := STD_LOGIC_VECTOR(SIGNED(SUMMED) + SIGNED(GAIND_Q(i)));
               --  SUMMED := STD_LOGIC_VECTOR( SIGNED(SUMMED) + SIGNED(GAIND_Q(i)(25)) & '0' & SIGNED(GAIND_Q(i)(23 downto 0)) );
						--SUMMED := STD_LOGIC_VECTOR(SIGNED(SUMMED) + SIGNED(RAW_OUTPUT(i)));
                        i := i+1;
	                ELSE
		                i:=0; -- ready restart
		                OUTPUT_TO_CLASSD <= NOT(SUMMED((SUMMED'LEFT))) & SUMMED(24 DOWNTO 14); -- concantinated to 13 bits a signle value out
                	        FOR m IN 0 TO 7 LOOP -- update the output for the interface at once
--OBS has to be changed by hand 
               				GAIND_Q_OUT(m)<= GAIND_Q(m)(25 downto 10);
		                END LOOP;
		                SUMMED := (others=>'0'); --initialised  to zero/anand
                	 	OE<='1';
							
--							FOR k IN 0 TO 7 LOOP
--	                   GAIND_Q(k) := (OTHERS => '0');
--	                  END LOOP;
							 started <= '0' ;
	                END IF;-- i
          	    ELSE --Started 
		        started <= FB_OE ;-- sleep until the Fiters output gets updated
				  SUMMED := (others=>'0');
				  FOR k IN 0 TO 7 LOOP
	           GAIND_Q(k) := (OTHERS => '0');
	           END LOOP;
	            END IF; -- STARTED 
          --  END IF; --CE
        END IF; --reset
    END IF; --clk
END process;

--	   PROCESS(clk)
--	     BEGIN
--	case select_filters is
--	
--                            WHEN "00000001" => 
--                               OUTPUT_TO_CLASSD<= NOT temp3(0)(11) & temp3(0)(10 downto 0); -- APPROXIMATELY 0-75 SWITCH 0
--                            WHEN "00000010" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(1)(11) & temp3(1)(10 downto 0); -- APPROXIMATELY 75-150 SWITCH 1
--                            WHEN "00000100" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(2)(11) & temp3(2)(10 downto 0); -- APPROXIMATELY 150-300 SWITCH 2
--                            WHEN "00001000" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(3)(11) & temp3(3)(10 downto 0);  -- APPROXIMATELY 300- 600SWITCH 3
--                            WHEN "00010000" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(4)(11) & temp3(4)(10 downto 0); -- APPROXIMATELY 600-1200 SWITCH 4
--                            WHEN "00100000" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(5)(11) & temp3(5)(10 downto 0); -- APPROXIMATELY 1200-2500 SWITCH 5
--                            WHEN "01000000" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(6)(11) & temp3(6)(10 downto 0); -- APPROXIMATELY 2500-5000 SWITCH 6
--                            WHEN "10000000" => 
--                                OUTPUT_TO_CLASSD<= NOT temp3(7)(11) & temp3(7)(10 downto 0);  -- APPROXIMATELY 5000-10000 SWITCH 7
--                            
--	                         WHEN OTHERS => 
--                                 NULL;
--   END CASE;
--
--	end process; 
    
--    
--    	   PROCESS(clk)
--	     BEGIN
--	case select_filters is
--	
--                            WHEN "00000001" => 
--                               OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(0)(25) & RAW_OUTPUT(0)(24 downto 14); -- APPROXIMATELY 0-75 SWITCH 0
--                            WHEN "00000010" => 
--                                OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(1)(25) & RAW_OUTPUT(1)(24 downto 14); -- APPROXIMATELY 75-150 SWITCH 1
--                            WHEN "00000100" => 
--                                OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(2)(25) & RAW_OUTPUT(2)(24 downto 14); -- APPROXIMATELY 150-300 SWITCH 2
--                            WHEN "00001000" => 
--                                OUTPUT_TO_CLASSD<=  NOT RAW_OUTPUT(3)(25) & RAW_OUTPUT(3)(24 downto 14);  -- APPROXIMATELY 300- 600SWITCH 3
--                            WHEN "00010000" => 
--                                OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(4)(25) & RAW_OUTPUT(4)(24 downto 14); -- APPROXIMATELY 600-1200 SWITCH 4
--                            WHEN "00100000" => 
--                                OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(5)(25) & RAW_OUTPUT(5)(24 downto 14); -- APPROXIMATELY 1200-2500 SWITCH 5
--                            WHEN "01000000" => 
--                                OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(6)(25) & RAW_OUTPUT(6)(24 downto 14); -- APPROXIMATELY 2500-5000 SWITCH 6
--                            WHEN "10000000" => 
--                                OUTPUT_TO_CLASSD<= NOT RAW_OUTPUT(7)(25) & RAW_OUTPUT(7)(24 downto 14);  -- APPROXIMATELY 5000-10000 SWITCH 7
--                            
--	                         WHEN OTHERS => 
--                                 NULL;
--   END CASE;
--
--	end process;

--	   PROCESS(clk)-- to check dac  
--	     BEGIN
--	case select_filters is
--	
--                            WHEN "00000001" => 
--                               OUTPUT_TO_CLASSD<="111111111111"; -- 4.2 v
--                            WHEN "00000010" => 
--                                OUTPUT_TO_CLASSD<="011111111111"; -- 2.1 v
--                            WHEN "00000100" => 
--                                OUTPUT_TO_CLASSD<="001111111111"; -- appro1.1 v 
--                            WHEN "00001000" => 
--                                OUTPUT_TO_CLASSD<="000111111111";  --.52v
--                            WHEN "00010000" => 
--                                OUTPUT_TO_CLASSD<="000011111111"; -- .26v
--                            WHEN "00100000" => 
--                                OUTPUT_TO_CLASSD<="000001111111"; -- .12v
--                            WHEN "01000000" => 
--                                OUTPUT_TO_CLASSD<="000000001111"; -- appro 10mv
--                            WHEN "10000000" => 
--                                OUTPUT_TO_CLASSD<="000000000000";  -- 0v
--                            
--	                         WHEN OTHERS => 
--                                 NULL;
--   END CASE;
--
--	end process;

END ARCHITECTURE;



              
