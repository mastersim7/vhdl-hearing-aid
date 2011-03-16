-- EQ_functions.vhd
-- Author: Shwan Ciyako, Anandhavel Sakthivel, Mathias Lundell
-- Date: 2011-02-10

-- Description:
-- Function eq_adder used together with the symmetrical filters to add together the 
-- newest and oldest sample before multiplication with common coefficient. Input
-- parameters are n bits and output is n+1 bits in order to avoid overflow

-- Comments:
-- Function eq_adder behaviourally tested using 1000 test vectors.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;

PACKAGE EQ_functions IS 
    FUNCTION eq_adder(DI1,DI2 : sample ) RETURN STD_LOGIC_VECTOR;
    
    FUNCTION eq_multiply(input : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0); coeff : coefficient_type)
        RETURN STD_LOGIC_VECTOR;
END EQ_functions;


PACKAGE BODY EQ_functions IS 
    FUNCTION eq_adder(DI1,DI2 : sample) RETURN  STD_LOGIC_VECTOR IS
        VARIABLE DO : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0);
        CONSTANT MSB : NATURAL := DI1'LEFT;
        VARIABLE p1, p2 : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0);
    BEGIN   
        -- Extend incoming parameters.
        IF DI1(MSB) = '1' THEN
            p1 := '1' & DI1;
        ELSE
            p1 := '0' & DI1;
        END IF;
        
        IF DI2(MSB) = '1' THEN
            p2 := '1' & DI2;
        ELSE
            p2 := '0' & DI2;
        END IF;
        
        -- Perform signed addition
        DO := STD_LOGIC_VECTOR( SIGNED(p1) + SIGNED(p2) );
        
        RETURN DO;
    END eq_adder;
    
    -- Function for multiplying two signed values
    FUNCTION eq_multiply(input : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0); coeff : coefficient_type)
    RETURN STD_LOGIC_VECTOR IS
        VARIABLE output : STD_LOGIC_VECTOR(input'LENGTH+coeff'LENGTH-1 DOWNTO 0);
    BEGIN
        output := STD_LOGIC_VECTOR(SIGNED(input) * SIGNED(output));
        output := SHIFT_LEFT(output, 1);
        return output;
    END eq_multiply;
END EQ_functions;