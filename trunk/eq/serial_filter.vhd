-- serial_filter.vhd
-- Author: Mathias Lundell
-- Date: 2011-03-16
-- Description:
-- A serial filter
-- It is still in the implementation phase. Have to decide how to handle incoming samples.
-- May have to use a flag for setting it in computation mode or may have to signal the buffer component
-- somehow that we want new samples. Another way to do it is also to get the clock enable from buffer,
-- add the samples together and when we have done it the correct number of time flag it on the output.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY serial_filter IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 37;
            NUM_OF_COEFFS : NATURAL := 110;
            NUM_OF_FILTERS);-- this can very well be the length'coefconst
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            OE      : OUT STD_LOGIC;
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;

ARCHITECTURE serial_filter_arch OF serial_filter IS
    

BEGIN

PROCESS(clk, CE)
    VARIABLE two_samples : STD_LOGIC_VECTOR( 2*sample'LENGTH-1 DOWNTO 0 );
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        IF CE = '1' THEN
        -- how do we handle CE ? it should be high until OE goes high then it goes low ?    
        IF i /= NUM_OF_COEFFS THEN 
           two_samples := eq_addition(sample1, sample2);
           Q <= eq_multiply(two_samples,CO(m,i));
           i := i+1;
        ELSIF m /= (NUM_OF_FILTERS)
	   i:=0;
           m:=m+1;
	ELSE 
	   OE <= '1' ; -- we are done doing calculation for the  filters this should let the main know and CE goes low ?
           m:=0;
           i:=0;
        END IF;		
END ARCHITECTURE serial_filter_arch;
