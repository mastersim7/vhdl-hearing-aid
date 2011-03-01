LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
Package EQ_data_type IS 
    TYPE taps_type IS ARRAY (1 to 8, 1 TO 111) OF STD_LOGIC_VECTOR( 23 downto 0 );
end EQ_data_type;
