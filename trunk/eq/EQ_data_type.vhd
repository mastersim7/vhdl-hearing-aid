LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
Package EQ_data_type IS 
 
    TYPE taps_type IS ARRAY (1 to 8, 1 TO 111) OF STD_LOGIC_VECTOR( 23 downto 0 );
    TYPE gain_type IS ARRAY (1 to 8) OF STD_LOGIC_VECTOR( 23 downto 0 );
    SUBTYPE sample IS  STD_LOGIC_VECTOR( 11 DOWNTO 0 );
    SUBTYPE Multi_Result IS STD_LOGIC_VECTOR(35 DOWNTO 0 );
    TYPE Gain_Multi_Result IS ARRAY (1 to 8) OF STD_LOGIC_VECTOR(59 DOWNTO 0 );
    TYPE Multi_Result_Array is ARRAY (8 downto 1) of Multi_Result;
    TYPE state_type_eq IS ( IDLE, COMPUTE_DATA, GAIN_DATA,GAIN_DATA2, SUM_DATA);
    
end EQ_data_type;
