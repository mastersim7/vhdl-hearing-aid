-- serial_filter.vhd
-- Author: Mathias Lundell,Shwan Ciyako,Anandhavel Sakthivel
-- Date: 2011-03-16
-- Description:
-- A serial filter
--
-- It is still in the implementation phase. Have to decide how to handle incoming samples.
-- May have to use a flag for setting it in computation mode or may have to signal the buffer component
-- somehow that we want new samples. Another way to do it is also to get the clock enable from buffer,
-- add the samples together and when we have done it the correct number of time flag it on the output./Mathias
-- 
-- I wanted to add the one set of calculations to be one CE here , it was possiabele for main to 
-- ask for them one by one then this component had /shwan
-- I want to make communication between here and BUFFER directly done with no interaction from main
-- become only a adder multiplier. 
--
-- I want it to be a single serial filter. That's the reason for making it a component. Then you can
-- order them any way you want in another file, just import them as components. It will be easier to debug
-- and will be easier to fit together with the rest of the design.
-- CE should be high when we want to calculate a result.
-- OE goes high when calculations are finished. And then goes low again.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY serial_filter IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 37;
            NUM_OF_COEFFS : NATURAL := 110);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            CO      : IN coefficient_type;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            updated : IN STD_LOGIC;
            OE      : OUT STD_LOGIC;
            Q	    : OUT Multi_Result);
				--  Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END ENTITY;

ARCHITECTURE serial_filter_arch OF serial_filter IS
-- FILTER COEEFS WILL BE ADDED HERE    
signal started :STD_LOGIC;
BEGIN

PROCESS(clk, CE)
    VARIABLE two_samples : extended_sample; 
    VARIABLE count : NATURAL RANGE 0 TO NUM_OF_COEFFS;
    VARIABLE mac,temp : STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0);
     
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        -- Synchronous reset
        IF reset ='1' THEN 
            mac := (OTHERS => '0');
            Q   <= (OTHERS => '0');
            count := 0;
            OE    <= '0';
            started <= '0';
        -- CE high, calculate a result. Output updated when all coefficients used
        ELSIF CE = '1' THEN  
            IF started = '1' THEN  
            
            IF count /= NUM_OF_COEFFS THEN 
                -- Add two samples together, multiply with coefficient, accumulate result

                two_samples := eq_adder(sample1, sample2);
                -- who chnaged from signed to unsigned why ?
                 -- mac := SIGNED(mac) + SIGNED(eq_multiply(two_samples,CO));  
               mac:= (mac) + (eq_multiply(two_samples,CO));
                count:= count + 1;
            ELSE 
                count := 0;
                Q     <= mac;
                OE    <= '1';
                started <= '0'
            END IF; --count
            ELSE 
            started <= updated;
            OE <= '0';
            END IF ; --started
        -- OE should go low after a single CE clock cycle.
        END IF; --ce and reset
    END IF;
END IF;
END PROCESS;
END ARCHITECTURE serial_filter_arch;
