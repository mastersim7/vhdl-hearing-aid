LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.all;
USE work.EQ_data_type.all;
USE work.EQ_functions.all;
ENTITY filterblock IS  
	PORT	( 	clk : IN STD_LOGIC ;
			DI1 : IN sample; 
			DI2 : IN sample;
			DIN : IN STD_LOGIC; -- shows that newdata has been added in register
			DO  : OUT  sample;
			READ: OUT STD_LOGIC;
			OE  : OUT STD_LOGIC;
			co  : IN  taps_type
		);
END filterblock;

ARCHITECTURE filterblock_arch of filterblock IS 
	--Components

	
	--Signals
  SIGNAL   state        : state_type_eq := IDLE;
  SIGNAL   next_state   : state_type_eq := IDLE;
	
      --constants 
      CONSTANT number_of_filters: NATURAL :=	8;
BEGIN 

update_state: PROCESS ( clk )
BEGIN
    IF clk'EVENT and clk = '1' THEN
        state <= next_state;
    END IF;
END PROCESS update_state;

COMPUTER: PROCESS(clk,DI1,DI2,state,next_state) IS 

	VARIABLE DISUM : sample;
	VARIABLE TMP: Multi_Result;
	VARIABLE DO_Var: Multi_Result;
  VARIABLE TMP_BAND : Multi_Result_Array;
  VARIABLE Gain_multiplied : Gain_Multi_Result;
  VARIABLE GAIN : gain_type;
	VARIABLE i,m : INTEGER;
	
	BEGIN 
	If rising_edge(clk) then 
	
	-- VARIABLES 
		
	CASE state IS
                    
        -- Idle state is wating for the new sample to arrive
        WHEN IDLE =>
            m:=1;
            DO<=(others=>'0');
	      IF DIN = '1' then 
	        READ <= '1';
	        next_state <= COMPUTE_DATA ;
	      END if;
	      -- Compute state takes the new data set and does computing we want to have two parallel computing going on at the same time , filters 1-4 5-8
	      WHEN COMPUTE_DATA =>
	                   IF i /=110 THEN 
	               	      DISUM := eq_adder(DI1,DI2);
		                  TMP := DISUM * CO(m,i); -- 36 bits of result
    		                  TMP_BAND(m) := TMP+TMP_BAND(m); -- multiresult array starts from 0 
                                  i := i+1;
		             ELSIF m /= 4 then 
      		                   m := m+1;
		                   i :=0;
		                 else 
		                 READ <='0' ;
		                 next_state <= GAIN_DATA;
		             END IF;
		                 
		             -- some signal to the summer to make the avarage   should be added here

            -- loop should be changed to a serial one using if as above, if this one is not working well
		WHEN (GAIN_DATA and GAIN_DATA2) =>

		FOR i IN 1 TO number_of_filters LOOP
		       Gain_multiplied(i) := TMP_BAND(i) * GAIN(i);				-- 60 bits of result
		END LOOP;
		

	        
		     next_state <= SUM_DATA;
		     
		WHEN SUM_DATA =>
		FOR i IN 1 TO number_of_filters LOOP
		 DO_Var:= DO_Var+(Gain_multiplied(i)(59 downto 27));-- length of DO_VAR??
		END LOOP;
		DO <= DO_Var(35 downto 24) ;
		OE <='1';
		next_state <= IDLE;
				
        END CASE;
END IF ; --clk
END PROCESS COMPUTER;

COMPUTER2: PROCESS(clk,DI1,DI2,state,next_state) IS 

	VARIABLE DISUM : sample;
	VARIABLE TMP: Multi_Result;
	VARIABLE DO_Var: Multi_Result;
  VARIABLE TMP_BAND : Multi_Result_Array;
  VARIABLE Gain_multiplied : Gain_Multi_Result;
  VARIABLE GAIN : gain_type;
	VARIABLE i,m : INTEGER;
	
	BEGIN 
	If rising_edge(clk) then 
	
	-- VARIABLES 
		
	CASE state IS
                    
        -- Idle state is wating for the new sample to arrive
        WHEN IDLE =>
                  m:=5;
	      -- Compute state takes the new data set and does computing we want to have two parallel computing going on at the same time , filters 1-4 5-8
	      WHEN COMPUTE_DATA =>
	                   IF i /=110 THEN 
	               	      DISUM := eq_adder(DI1,DI2);
		                  TMP := DISUM * CO(m,i); -- 36 bits of result
    		                  TMP_BAND(m) := TMP+TMP_BAND(m); -- multiresult array starts from 0 
                                  i := i+1;
		             ELSIF m /= 8 then 
      		                   m := m+1;
		                   i :=0;
		                 else 
		                 --READ <='0' ;
		                 next_state <= GAIN_DATA2;
		             END IF;
		                 
		             -- some signal to the summer to make the avarage   should be added here


END IF ; --clk
END PROCESS COMPUTER2;


END filterblock_arch; 

			
