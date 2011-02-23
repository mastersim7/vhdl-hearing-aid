-- fir_filter2.vhd
-- Mathias Lundell
-- 2010-09-25
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fir_filter2 IS
    GENERIC (   N : NATURAL := 8; -- width of samples and filter coefficients
                NUM_OF_TAPS : NATURAL := 4);-- number of taps
                
    PORT (  x       : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
            reset   : IN  STD_LOGIC;                            -- reset
            start   : IN  STD_LOGIC;                            -- start filter
            
            y       : OUT STD_LOGIC_VECTOR( N-1   DOWNTO 0 ));  -- result
END ENTITY;



ARCHITECTURE fir_filter2_arch OF fir_filter2 IS
    
    -- Filter coefficients
    TYPE taps IS ARRAY (0 TO NUM_OF_TAPS-1) OF STD_LOGIC_VECTOR( x'RANGE );
    CONSTANT tk : taps := ( "11010111", -- -0.32
                            "00011110", --  0.23
                            "00011110", --  0.23
                            "11010111");-- -0.32
                                    
    -- Samples
    SIGNAL xk : taps;
BEGIN
    -- Reset or calculate FIR
    fir_calculations : PROCESS( reset, start, x )
        VARIABLE a : SIGNED( (2*N)-1 DOWNTO 0 );
    BEGIN
        -- Reset
        IF reset = '1' THEN
            -- Reset the output
            y <= (OTHERS => '0');
            
            -- Reset the stored samples
            FOR m IN 0 TO NUM_OF_TAPS-1 LOOP
                xk(m) <= (OTHERS => '0');
            END LOOP;
            
        -- Do the calculations (samples must have been provided)
        ELSIF start'EVENT AND start = '1' THEN
            -- Update samples, first in first out
            xk(0) <= x;
            FOR m IN 0 TO NUM_OF_TAPS-2 LOOP
                xk(m+1) <= xk(m);
            END LOOP;
            
            -- Calculate the output
            a := SHIFT_LEFT( (SIGNED(tk(0)) * SIGNED(x)), 1 );
            FOR i IN 1 TO NUM_OF_TAPS-1 LOOP
                a := a + SHIFT_LEFT( (SIGNED(tk(i)) * SIGNED(xk(i-1))), 1 );
            END LOOP;
            y <= STD_LOGIC_VECTOR( a(2*N-1 downto N) );
        END IF;
    END PROCESS;

END ARCHITECTURE fir_filter2_arch;

