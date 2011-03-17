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
            CE      : IN STD_LOGIC;
            REQ     :IN STD_LOGIC;
            Gained_Samples: IN Gained_result_Array; --an 8 array of 13 bit vectors
            OE      : OUT STD_LOGIC; 
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;
ARCHITECTURE average_if_arch OF average_if IS
    

BEGIN

PROCESS(clk, CE)
    VARIABLE Gained_Samples_var: IN Gained_result_Array;
    
    VARIABLE i,m,mo : INTEGER;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
	IF reset ='1' THEN 
	    Q <= (others=>'0');
	    i:=0;
	    OE<='0';
	ELSE
	
           IF CE = '1' THEN --slower clock
             IF REQ = '1' THEN 

              IF i /= NUM_OF_SAMPLES THEN 
                  IF m /= NUM_OF_BANDS THEN 
                 Gained_Samples_var(m)= if_adder(Gained_Samples(m),Gained_Samples_var(m));
                  m:=m+1;
                  ELSE
                  m:=0;
                  i := i+1;
                  end IF; --m
              ELSE 
                 IF mo /= NUM_OF_BANDS THEN
                 Q<=Gained_Samples_var(mo);
                 OE<='1'
                 ELSE 
                 OE<='0';
                 END IF; --output
              END IF;--i
              END IF; --req
          END IF; --CE
     END IF; --reset
    END IF; --clk
END ARCHITECTURE;
