LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
Package EQ_data_type IS 
	GENERIC(L:NATURAL := 12);	 
    TYPE taps_type IS ARRAY (1 to 8, 1 TO 111) OF STD_LOGIC_VECTOR( 23 downto 0 );
    TYPE sample IS  STD_LOGIC_VECTOR( L-1 DOWNTO 0 );
    TYPE Multi_Result IS STD_LOGIC_VECTOR( (2*L)-1 DOWNTO 0 );
    TYPE Multi_Result_Array is ARRAY (3 downto 0) of Multi_Result;
end EQ_data_type;
