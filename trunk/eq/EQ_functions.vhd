-- EQ_functions.vhd
-- Author: Shwan Ciyako, Anandhavel Sakthivel, Mathias Lundell
-- Date: 2011-03-16

-- Description:
-- Function eq_adder used together with the symmetrical filters to add together the 
-- newest and oldest sample before multiplication with common coefficient. Input
-- parameters are n bits and output is n+1 bits in order to avoid overflow

-- Comments:
-- Function eq_adder behaviourally tested using 1000 test vectors.
-- Function eq_multiply behaviourally tested using 1000 test vectors.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;
USE work.EQ_data_type.ALL;

PACKAGE EQ_functions IS 
    FUNCTION eq_adder(DI1,DI2 : sample ) RETURN STD_LOGIC_VECTOR;
	 FUNCTION if_adder(DI1,DI2 : extended_sample) RETURN  STD_LOGIC_VECTOR;
    FUNCTION eq_multiply(input : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0); coeff : coefficient_type) RETURN STD_LOGIC_VECTOR;
	 FUNCTION eq_gain_multiply(RAW_OUTPUT: STD_LOGIC_VECTOR(extended_sample'LENGTH-1 DOWNTO 0); GAIN : STD_LOGIC_VECTOR(extended_sample'LENGTH-1 DOWNTO 0))
	 RETURN STD_LOGIC_VECTOR;
END EQ_functions;


PACKAGE BODY EQ_functions IS 

    -- Function eq_adder used together with the symmetrical filters to add together the 
    -- newest and oldest sample before multiplication with common coefficient. Input
    -- parameters are n bits and output is n+1 bits in order to avoid overflow
    FUNCTION eq_adder(DI1,DI2 : sample) RETURN  STD_LOGIC_VECTOR IS
        VARIABLE DO : STD_LOGIC_VECTOR(extended_sample'LENGTH-1 DOWNTO 0); 
        CONSTANT MSB : NATURAL := DI1'LEFT;
        VARIABLE p1, p2 : STD_LOGIC_VECTOR(extended_sample'LENGTH-1 DOWNTO 0);
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
    
    -- branch the adder, this is going to be used to sum up samples out from eq for interface to make average 16 bits data
     FUNCTION if_adder(DI1,DI2 : extended_sample) RETURN  STD_LOGIC_VECTOR IS
        VARIABLE DO : STD_LOGIC_VECTOR(15 DOWNTO 0); 
		  
        CONSTANT MSB : NATURAL := DI1'LEFT;
        VARIABLE p1, p2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN   
        -- Extend incoming parameters. to new format from 1.11 representation into 5.11 
        IF DI1(MSB) = '1' THEN
            p1 := "111" & DI1;
        ELSE
            p1 := "000" & DI1;
        END IF;
        
        IF DI2(MSB) = '1' THEN
            p2 := "111" & DI2;
        ELSE
            p2 := "000" & DI2;
        END IF;
        
        -- Perform signed addition
        DO := STD_LOGIC_VECTOR( SIGNED(p1) + SIGNED(p2) );
        
        RETURN DO;
    END if_adder;
    
    -- Function for multiplying two signed values
    -- The result is a std logic vector of length of sample + length of coefficient.
    -- After multiplication the result is shifted left 1 step in order to keep format fixed point
    -- decimal.
    FUNCTION eq_multiply(input : STD_LOGIC_VECTOR(sample'LENGTH DOWNTO 0); coeff : coefficient_type)
    RETURN STD_LOGIC_VECTOR IS
        VARIABLE output : SIGNED(input'LENGTH+coeff'LENGTH-1 DOWNTO 0);
    BEGIN
        output := SIGNED(input) * SIGNED(coeff);
        output := SHIFT_LEFT(output, 1);
        RETURN STD_LOGIC_VECTOR(output);
    END eq_multiply;
	 
	 FUNCTION eq_gain_multiply(RAW_OUTPUT: STD_LOGIC_VECTOR(extended_sample'LENGTH-1 DOWNTO 0); GAIN : STD_LOGIC_VECTOR(extended_sample'LENGTH-1 DOWNTO 0))
	 RETURN STD_LOGIC_VECTOR IS
        VARIABLE output_gain : SIGNED(RAW_OUTPUT'LENGTH+GAIN'LENGTH-1 DOWNTO 0);
    BEGIN
        output_gain := SIGNED(RAW_OUTPUT) * SIGNED(GAIN);
        output_gain := SHIFT_LEFT(output_gain, 1);
        RETURN STD_LOGIC_VECTOR(output_gain);
    END eq_gain_multiply;
END EQ_functions;
