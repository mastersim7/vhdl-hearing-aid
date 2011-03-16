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
            NUM_BITS_OUT : NATURAL := 37 );
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;

ARCHITECTURE serial_filter_arch OF serial_filter IS
    

BEGIN

PROCESS(clk, CE)
    VARIABLE two_samples : STD_LOGIC_VECTOR( 2*sample'LENGTH-1 DOWNTO 0 );
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        IF CE = '1' THEN
            two_samples := eq_addition(sample1, sample2);
            Q <= eq_multiply -- i stop here, will continue when possible... 
END ARCHITECTURE serial_filter_arch;