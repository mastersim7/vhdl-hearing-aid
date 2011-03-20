-- Description:
-- average_if.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- It is still in the implementation phase. 
-- This component will give one output every 8 CEs 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--USE ieee.std_logic_signed.ALL;
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
            Gained_Samples: IN Gained_result_Array_16; --an 8 array of 16 bit vectors
            OE      : OUT STD_LOGIC; 
            Q       : OUT Gained_result_Array_16);
END;
ARCHITECTURE average_if_arch OF average_if IS
    signal started : std_logic;

BEGIN

PROCESS(clk, CE)
    VARIABLE Gained_Samples_var: Gained_result_Array_16;
    
    VARIABLE i,m,mo : INTEGER;
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
           
	      IF started = '1' THEN 
	
             IF (REQ and OE_GAINAMP) = '1' THEN 
              

              IF i /= NUM_OF_SAMPLES THEN 
				      OE<='0';
                  IF m /= NUM_OF_BANDS THEN 
                -- Gained_Samples_var(m) := if_adder(Gained_Samples(m),Gained_Samples_var(m));
                  
						Gained_Samples_var(m) := STD_LOGIC_VECTOR(SIGNED(Gained_Samples(m))+SIGNED(Gained_Samples_var(m)));
						
						m:=m+1;
                  ELSE
                  m:=0;
                  i := i+1;
                  end IF; --m
              ELSE 
                 Q<=Gained_Samples_var;
                 OE<='1';
                 i := 0;
                 started <='0';
					 END IF;--i
              END IF; --req
      ELSE
      started <=OE_GAINAMP ; 
      END IF; --started
          END IF; --CE
     END IF; --reset
    END IF; --clk
	 End Process;
END ARCHITECTURE;
