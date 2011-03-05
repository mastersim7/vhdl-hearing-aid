LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;
Package EQ_functions IS 

    	FUNCTION eq_adder(DI1,DI2 : sample )RETURN  sample;

end EQ_functions;
Package BODY EQ_functions IS 

FUNCTION eq_adder(DI1,DI2 : sample) RETURN  sample  IS
		VARIaBLE DO : sample; 
		BEGIN 
		DO := DI1 + DI2; 
		IF ((DI1(11) XOR DI2(11)) AND (DO(11) XOR DI1(11)))  = '0' THEN 
		IF DI1(11) = '1' THEN 	-- if negative owerflow accures make output smallest 
		  DO(11):= '1';
		  DO(10 DOWNTO 0) := (others => '0');
		ELSE -- if positive owerflow accures make output biggest
		DO(11):= '0';
		DO(10 DOWNTO 0) := (others => '1');
		END IF;
		END IF; 
		RETURN DO;
		END eq_adder;
END EQ_functions;

