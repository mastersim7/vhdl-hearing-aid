
-- Author: Shwan Ciyako, Anandhavel Sakthivel, Mathias Lundell
-- Date: 2011-02-10

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
Package EQ_data_type IS 
    SUBTYPE coefficient_type IS STD_LOGIC_VECTOR(23 DOWNTO 0);
    TYPE taps_type IS ARRAY (1 to 8, 1 TO 111) OF coefficient_type;
    TYPE AVERAGE_SIG_LEV_type IS ARRAY (8 DOWNTO 1) OF STD_LOGIC_VECTOR( 15 downto 0 ); --not sure
    TYPE gain_type IS ARRAY (1 to 8) OF STD_LOGIC_VECTOR( 11 downto 0 );
    SUBTYPE sample IS  STD_LOGIC_VECTOR( 11 DOWNTO 0 );
    SUBTYPE extended_sample IS  STD_LOGIC_VECTOR( 12 DOWNTO 0 );
    SUBTYPE extended_output IS  STD_LOGIC_VECTOR( 14 DOWNTO 0 );
    SUBTYPE Multi_Result IS STD_LOGIC_VECTOR(36 DOWNTO 0 ); -- from serial filter o/p
	 SUBTYPE Gain_Multi IS STD_LOGIC_VECTOR(49 DOWNTO 0 );   -- after multiplied with gain 
	 SUBTYPE Gain_Multi_extended IS STD_LOGIC_VECTOR(52 DOWNTO 0 );   -- after multiplied with gain 
	 
    TYPE Multi_Result_array  IS ARRAY (1 to 8) OF STD_LOGIC_VECTOR(36 DOWNTO 0 );-- from serial filter o/p all values as array
    TYPE Gain_Multi_Result IS ARRAY (1 to 8) OF STD_LOGIC_VECTOR(49 DOWNTO 0 );-- after multiplied with gain values as array
	 
    TYPE Gained_result_Array is ARRAY(1 to 8) OF STD_LOGIC_VECTOR( 12 downto 0 );
    TYPE Gain_Array is ARRAY(1 to 8) OF STD_LOGIC_VECTOR( 12 downto 0 );
    
	TYPE Gained_result_Array_16 is ARRAY(1 to 8) OF STD_LOGIC_VECTOR( 15 downto 0 );
    --TYPE state_type_eq IS (IDLE, COMPUTE_DATA, GAIN_DATA,SUM_DATA); -- not used?
    --CONSTANT TAPS_CONST: taps_type;
end EQ_data_type;

Package BODY EQ_data_type IS
END EQ_data_type;
