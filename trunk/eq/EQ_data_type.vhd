
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
    SUBTYPE Multi_Result IS STD_LOGIC_VECTOR(36 DOWNTO 0 );
    TYPE Gain_Multi_Result IS ARRAY (1 to 8) OF STD_LOGIC_VECTOR(36 DOWNTO 0 );
    TYPE Gained_result_Array is ARRAY (11 downto 0) of Multi_Result;
    TYPE state_type_eq IS ( IDLE, COMPUTE_DATA, GAIN_DATA,SUM_DATA);
    --CONSTANT TAPS_CONST: taps_type;
end EQ_data_type;

Package BODY EQ_data_type IS
END EQ_data_type;