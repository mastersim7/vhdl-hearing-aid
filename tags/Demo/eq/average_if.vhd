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
    
    VARIABLE i,m : INTEGER;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
	IF reset ='1' THEN 
	   FOR k IN 1 TO 8 LOOP
          Q(k) <= (OTHERS => '0');
     END LOOP;
	    i:=0;
	   -- m:=1; -- array starts from 1
	    OE<='0';
 	    started <='0';
	ELSE
      IF CE = '1' THEN --slower clock
           
	    IF started = '1' THEN 
	
      --
  
      --IF REQ  = '1' THEN 
              

      IF OE_GAINAMP = '1' THEN 
      IF i /= NUM_OF_SAMPLES THEN 
				      OE<='0';
				      
              --IF m /= (NUM_OF_BANDS+1) THEN 
             
              FOR k IN 1 TO NUM_OF_BANDS LOOP
                Gained_Samples_var(k) := STD_LOGIC_VECTOR(SIGNED(Gained_Samples(k))+SIGNED(Gained_Samples_var(k)));
              END LOOP;
             
              -- Gained_Samples_var(m) := if_adder(Gained_Samples(m),Gained_Samples_var(m));
               
                --m:=m+1;
            
              --ELSE
                --m:=1;
                i := i+1;
              --end IF; --m
              
      ELSE 
                 Q<=Gained_Samples_var;
                 
	             FOR k IN 1 TO 8 LOOP
                 Gained_Samples_var(k) := (OTHERS => '0');
                END LOOP;
                 OE<='1';
                 i := 0;
                 started <='0'; 
        END IF;--i
      
        END IF; --OE_GSINSMP
       ELSE
      ---started <=OE_GAINAMP ;  this one should wait for req
      started <= REQ;
      END IF; --started
          END IF; --CE
     END IF; --reset
    END IF; --clk
	 End Process;
END ARCHITECTURE;
