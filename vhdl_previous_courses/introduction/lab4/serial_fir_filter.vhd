-- serial_fir_filter.vhd
-- Mathias Lundell
-- 2010-10-25
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY serial_fir_filter IS
    GENERIC (   N : NATURAL := 8; -- width of samples and filter coefficients
                NUM_OF_TAPS : NATURAL := 4);-- number of taps
                
    PORT (  x       : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
            reset   : IN  STD_LOGIC;                            -- reset
            start   : IN  STD_LOGIC;                            -- start filter
            clk     : IN  STD_LOGIC;
            
            finished: OUT STD_LOGIC;                            -- result finished
            y       : OUT STD_LOGIC_VECTOR( N-1   DOWNTO 0 ));  -- result
END ENTITY serial_fir_filter;



ARCHITECTURE serial_fir_filter_arch OF serial_fir_filter IS
    -- Filter coefficients
    TYPE taps IS ARRAY (0 TO NUM_OF_TAPS-1) OF STD_LOGIC_VECTOR( x'RANGE );
    CONSTANT tk : taps := ( "11010111", -- -0.32
                            "00011110", --  0.23
                            "00011110", --  0.23
                            "11010111");-- -0.32
                                    
    -- Samples
    SIGNAL xk : taps;
    
    -- Counter
    SIGNAL i : NATURAL RANGE 0 TO NUM_OF_TAPS-1;
    
    -- Store the temporary results
    SIGNAL y_temp : STD_LOGIC_VECTOR( (2*N)-1 DOWNTO 0 );
    
    -- Started and finished flags
    SIGNAL n_finished : STD_LOGIC;
    SIGNAL started  : STD_LOGIC;
	 
BEGIN
    -- Process for the FIR-filter calculations
    fir : PROCESS( reset, clk )
        VARIABLE a : SIGNED( y_temp'RANGE );
        VARIABLE temp : STD_LOGIC_VECTOR( (2*N)-1 DOWNTO 0 );
    BEGIN
        -- Asynchronous reset
        IF reset = '1' THEN
            -- Reset the output
            y <= (OTHERS => '0');
            
            -- Reset start, finish flags
            started  <= '0';
            n_finished <= '0';
            
            -- Reset the stored samples
            FOR m IN 0 TO NUM_OF_TAPS-1 LOOP
                xk(m) <= (OTHERS => '0');
            END LOOP;
        ELSIF clk'EVENT AND clk = '1' THEN
            -- Start when we have had a pulse on start
            IF start = '1' THEN
                started <= '1';
                i <= 0;
                n_finished <= '0';
                y_temp <= (OTHERS => '0');
                
                -- Update the samples
                xk(0) <= x;
                FOR m IN 0 TO NUM_OF_TAPS-2 LOOP
                    xk(m+1) <= xk(m);
                END LOOP;
                
            -- Do the FIR-filter calculations
            ELSIF started = '1' THEN
                IF i < NUM_OF_TAPS THEN
                    -- Do the multiplication and shift left
                    a := SIGNED(xk(i)) * SIGNED(tk(i));
                    a := SHIFT_LEFT( a, 1 );
                    
                    -- Increment the result
                    y_temp <= STD_LOGIC_VECTOR( SIGNED(y_temp) +  a );
                    
                    -- If this was the last tap, finish
                    IF i = NUM_OF_TAPS-1 THEN
                        started <= '0';
                        temp := STD_LOGIC_VECTOR( SIGNED(y_temp) +  a );
                        y <= temp(2*N-1 DOWNTO N);
                        n_finished <= '1';
                    ELSE
                        -- Increment the counter
                        i <= i + 1;
                    END IF;   
                END IF;
            END IF;
            
        END IF;
    END PROCESS fir; 
    
    -- Finished goes high when calculations complete
    finished <= n_finished;
    
    -- Update the output when calculations complete
    --y <= y_temp((2*N)-1 DOWNTO N) WHEN n_finished = '1';
         
END ARCHITECTURE serial_fir_filter_arch;

