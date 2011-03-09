-- EQ_functions.vhd
-- Author:
-- Date:
-- Description:
-- Function used together with the symmetrical filters to add together the newest and
-- oldest sample before multiplication with common coefficient.

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
    CONSTANT MSB := DO'LEFT;
    CONSTANT LSB := DO'RIGHT;
BEGIN 
    DO := DI1 + DI2;
    IF ((DI1(MSB) XOR DI2(MSB)) AND (DO(MSB) XOR DI1(MSB)))  = '0' THEN 
        IF DI1(MSB) = '1' THEN 	-- if negative owerflow accures make output smallest 
            DO(MSB):= '1';
            DO(MSB-1 DOWNTO LSB) := (OTHERS => '0');
        ELSE -- if positive owerflow accures make output biggest
            DO(MSB):= '0';
            DO(MSB-1 DOWNTO LSB) := (OTHERS => '1');
        END IF;
    END IF; 
    RETURN DO;
END eq_adder;
END EQ_functions;