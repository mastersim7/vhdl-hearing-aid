-- Description:
-- average_if.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- It is still in the implementation phase. 
-- This component will give one output every 8 CEs 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;


ENTITY average_if IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 16;
            NUM_OF_SAMPLES : NATURAL := 200;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   :IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            OE_GAINAMP : IN STD_LOGIC;
            REQ     :IN STD_LOGIC;
            Gained_Samples: IN Gained_result_Array_16; --an 8-array of 16 bit vectors
            OE      : OUT STD_LOGIC; 
            Q       : OUT Gained_result_Array_8); -- changed down to 8 bits/amit
END;


ARCHITECTURE average_if_arch OF average_if IS
    signal started : std_logic;

BEGIN

PROCESS(clk, CE)
    VARIABLE Gained_Samples_var: Gained_result_Array_16;
    VARIABLE i,m : INTEGER;
BEGIN
    IF clk'EVENT AND clk = '1' THEN

	IF reset ='1' THEN 
	   FOR k IN 1 TO 8 LOOP
	   Q(k) <= (OTHERS => '0');
	   END LOOP;
	   i:=0;
	   OE<='0';
 	   started <='0'; 
	ELSE
		IF CE = '1' THEN --slower clock
			IF started = '1' THEN -- makes sure the entire calculation is being done once per req signal
				IF OE_GAINAMP = '1' THEN  -- waits until the gain is multiplied to the output and the output updated
					IF i /= NUM_OF_SAMPLES THEN
					      OE<='0';
					      FOR k IN 1 TO NUM_OF_BANDS LOOP -- parallel of 8 additions ?
				              	Gained_Samples_var(k) := STD_LOGIC_VECTOR(SIGNED(Gained_Samples(k))+SIGNED(Gained_Samples_var(k)));
				              END LOOP;
				              i := i+1;
				        ELSE
				              Q<=Gained_Samples_var(Gained_SAmple_var'LEFT downto Gained_SAmple_var'LEFT - 7); -- the entire array of 8 bits gets updated per one clock
                 		  OE<='1';
                 		  i := 0;
                 		  started <='0';  -- turn off this component until next req
                 		  FOR k IN 1 TO 8 LOOP -- zero the temp variable
                 			    Gained_Samples_var(k) := (OTHERS => '0');
                 		  END LOOP;
				        END IF;--i
			        END IF; --OE_GSINSMP
		        ELSE --STARTED
		        	started <= REQ;
		        END IF; --started
		END IF; --CE
        END IF; --reset
    END IF; --cl
END PROCESS;
END ARCHITECTURE;
