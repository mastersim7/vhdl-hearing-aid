-- fir_filter.vhd
-- Mathias Lundell
-- 101013-15:39
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fir_filter IS
    GENERIC ( N : NATURAL := 12 ); -- width of samples and filter coefficients
                
    PORT (  clk     : IN  STD_LOGIC;
				x       : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
            reset   : IN  STD_LOGIC;                            -- reset
            start   : IN  STD_LOGIC;                            -- start filter
            
				OE      : OUT STD_LOGIC;
            y       : OUT STD_LOGIC_VECTOR( N-1   DOWNTO 0 ));  -- result
END ENTITY;



ARCHITECTURE fir_filter_arch OF fir_filter IS
    CONSTANT NUM_OF_TAPS : NATURAL := 20; -- number of taps
    
    -- Filter coefficients
    TYPE taps IS ARRAY (0 TO NUM_OF_TAPS-1) OF STD_LOGIC_VECTOR( x'RANGE );
    CONSTANT tk : taps := ( 
							"111111111110", -- -0.0011
							"000000000101", --  0.0023
							"000000001111", --  0.0075                     
							"000000001101", --  0.0062
							"111111100100", -- -0.0136
							"111110101100", -- -0.0408
							"111111000001", -- -0.0308
							"000001110100", --  0.0566
							"000110011010", --  0.2004
							"001010000010", --  0.3134
							"001010000010", --  0.3134
							"000110011010", --  0.2004
							"000001110100", --  0.0566
							"111111000001", -- -0.0308
 							"111110101100", -- -0.0408
							"111111100100",	-- -0.0136
							"000000001101", --  0.0062
							"000000001111", --  0.0075
							"000000000101", --  0.0023
							"111111111110");-- -0.0011
                                    
    -- Samples
    SIGNAL xk : taps;
BEGIN
    -- Reset or calculate FIR
    fir_calculations : PROCESS( reset, clk, x )
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
        ELSIF clk'EVENT AND clk = '1' THEN
			   IF start = '1' THEN
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
					 OE <= '1';
				ELSE
				    OE <= '0';
				END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE fir_filter_arch;

