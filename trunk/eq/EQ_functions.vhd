LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
Package EQ_functions IS 

    	FUNCTION eq_adder(DI1,DI2 : sample )RETURN  sample;

end EQ_data_type;
Package BODY EQ_functions IS 

FUNCTION eq_adder(DI1,DI2 : sample) RETURN  sample  IS
		VARIBALE DO : sample; 
		BEGIN 
		DO := DI1 + DI2; 
		IF (DI1(N-1) XOR DI2(N-1)) AND (DO(N-1) XOR DI1(N-1))  = '0' THEN 
		IF DI1(N-1) = '1' THEN 	-- if negative owerflow accures make output smallest 
		  DO(N-1):= '1';
		  DO(N-2 DOWNTO 0) := (others => '0');
		ELSE -- if positive owerflow accures make output biggest
		DO(N-1):= '0';
		DO(N-2 DOWNTO 0) := (others => '1')
		END IF;
		END IF; 
		RETURN DO;
		END eq_adder;
END Package EQ_fuctions;

