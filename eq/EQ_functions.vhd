-- EQ_functions.vhd
-- Author:
-- Date: 2011-02-10
-- Description:
-- Function used together with the symmetrical filters to add together the newest and
-- oldest sample before multiplication with common coefficient.

-- CURRENTLY NOT WORKING!! May want to change the number of bits... 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;

PACKAGE EQ_functions IS 
    FUNCTION eq_adder(DI1,DI2 : sample ) RETURN sample;
END EQ_functions;


PACKAGE BODY EQ_functions IS 
FUNCTION eq_adder(DI1,DI2 : sample) RETURN  sample  IS
    VARIABLE DO : sample;
    CONSTANT MSB : NATURAL := DO'LEFT;
    CONSTANT LSB : NATURAL := DO'RIGHT;
    CONSTANT MAX : INTEGER := 2 ** (sample'LENGTH-1)-1;
    CONSTANT MIN : INTEGER := -2 ** (sample'LENGTH-1);
BEGIN 
    --DO := DI1 + DI2;
    --IF ((DI1(MSB) XOR DI2(MSB)) AND (DO(MSB) XOR DI1(MSB)))  = '0' THEN 
    --    IF DI1(MSB) = '1' THEN 	-- if negative owerflow accures make output smallest 
    --        DO(MSB):= '1';
    --       DO(MSB-1 DOWNTO LSB) := (OTHERS => '0');
    --    ELSE -- if positive owerflow accures make output biggest
    --        DO(MSB):= '0';
    --        DO(MSB-1 DOWNTO LSB) := (OTHERS => '1');
    --    END IF;
    --END IF; 
    
    IF TO_INTEGER(SIGNED(DI1)+SIGNED(DI2)) > MAX THEN
        DO := "011111111111";
    ELSIF TO_INTEGER(SIGNED(DI1)+SIGNED(DI2)) < MIN THEN
        DO := "100000000000";
    ELSE
        DO := STD_LOGIC_VECTOR( SIGNED(DI1) + SIGNED(DI2) );
    END IF;
    RETURN DO;
END eq_adder;
END EQ_functions;