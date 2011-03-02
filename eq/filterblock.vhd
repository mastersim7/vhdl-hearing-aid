LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.all;
USE work.EQ_functions.all;
ENTITY filterblock IS  
	PORT	( 	clk : IN STD_LOGIC ;
			DI1 : IN sample; 
			DI2 : IN sample; 
			DO  : OUT  sample;
			READ : OUT STD_LOGIC;
			OE	:  OUT STD_LOGIC
		);
END filterblock;

ARCHITECTURE filterblock_arch of filterblock IS 
	--Components

	
	--Signals
	 
	
	
BEGIN 



COMPUTER: PROCESS(clk,DI1,DI2) IS 

	VARIABLE DISUM : sample;
	VARIABLE TMP1: Multi_Result;
	VARIABLE TMP_BAND : Multi_Result_Array;
	
	VARIABLE i,m : INTEGER;
	
	BEGIN 
	If rising_edge(clk) then 
	
	-- VARIABLES 
		
		if i /=110 then 
		DISUM := eq_adder(DI1,DI2);
		TMP1 := DISUM * CO(m,i);
		TMP_BAND(m) := TMP1+TMP_BAND(m)
		i := i+1;
		elsif m /= 4 then 
			m := m+1;
		else 
		DO <= '1';
		TMP_BAND
				
 
		






END IF ; --clk
END filterblock_arch; 

			

