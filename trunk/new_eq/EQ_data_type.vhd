-- Author: Shwan Ciyako, Anandhavel Sakthivel, Mathias Lundell
-- Date: 2011-02-10

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
Package EQ_data_type IS 
    SUBTYPE sample IS  STD_LOGIC_VECTOR( 11 DOWNTO 0 );
    SUBTYPE extended_sample IS  STD_LOGIC_VECTOR( 12 DOWNTO 0 ); -- in order to nog get overflow
    --SUBTYPE extended_output IS  STD_LOGIC_VECTOR( 14 DOWNTO 0 ); -- not used ??
	
	--generated in matlab added as a constant in filterblock
	SUBTYPE coefficient_type IS STD_LOGIC_VECTOR(12 DOWNTO 0); 
	
	-- to be changed to have less number of taps
    TYPE taps_type IS ARRAY (0 to 7, 0 TO 19) OF coefficient_type; 
	
	-- The results are double the size of the inputs so the next type
	SUBTYPE Multi_Result IS STD_LOGIC_VECTOR(25 DOWNTO 0 ); -- from serial filter o/p 26bits
	  SUBTYPE Gain_Multi IS STD_LOGIC_VECTOR(25 DOWNTO 0 );   -- after multiplied with gain 26bits
	  SUBTYPE Gain_Multi_extended IS STD_LOGIC_VECTOR(25 DOWNTO 0 );   -- after multiplied with gain 26bits
    -- register arraies to store the ruslts after multiplications 
	 TYPE Multi_Result_array  IS ARRAY (0 to 7) OF STD_LOGIC_VECTOR(25 DOWNTO 0 );-- from serial filter o/p all values as array 26bits 
     TYPE Gain_Multi_Result IS ARRAY (0 to 7) OF STD_LOGIC_VECTOR(25 DOWNTO 0 );-- after multiplied with gain values as array 26bits
	TYPE Gain_Multi_Result_39 IS ARRAY (0 to 7) OF STD_LOGIC_VECTOR(38 DOWNTO 0 );
	-- Manly used in IF
	TYPE AVERAGE_SIG_LEV_type IS ARRAY (7 DOWNTO 0) OF STD_LOGIC_VECTOR( 12 downto 0 ); -- 13bits to the averageif to sum up 200 of them
    TYPE Gained_result_Array is ARRAY(0 to 7) OF STD_LOGIC_VECTOR( 12 downto 0 ); -- 13 bits 
    -- is to be used in later
	TYPE Gained_result_Array_16 is ARRAY(0 to 7) OF STD_LOGIC_VECTOR( 15 downto 0 );
    TYPE Gained_result_Array_8 is ARRAY(0 to 7) OF STD_LOGIC_VECTOR( 7 downto 0 );
    
	TYPE Gain_Array is ARRAY(0 to 7) OF STD_LOGIC_VECTOR( 12 downto 0 ); 
    --TYPE state_type_eq IS (IDLE, COMPUTE_DATA, GAIN_DATA,SUM_DATA); -- not used?
    --CONSTANT TAPS_CONST: taps_type;
	-- REMOVE ME ?? 
	--TYPE gain_type IS ARRAY (0 to 7) OF STD_LOGIC_VECTOR( 11 downto 0 ); -- not used ?
end EQ_data_type;

Package BODY EQ_data_type IS
END EQ_data_type;
