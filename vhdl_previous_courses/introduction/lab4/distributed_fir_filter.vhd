-- distributed_fir_filter.vhd
-- Mathias Lundell
-- 2010-10-25
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY distributed_fir_filter IS
    GENERIC (   N : NATURAL := 8; -- width of samples and filter coefficients
                NUM_OF_TAPS : NATURAL := 4);-- number of taps
                
    PORT (  x       : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
            reset   : IN  STD_LOGIC;                            -- reset
            start   : IN  STD_LOGIC;                            -- start filter
            clk     : IN  STD_LOGIC;
            
            finished: OUT STD_LOGIC;                            -- result finished
            y       : OUT STD_LOGIC_VECTOR( N-1   DOWNTO 0 ));  -- result
END ENTITY;



ARCHITECTURE distributed_fir_filter_arch OF distributed_fir_filter IS
    
    -- Filter coefficients
    TYPE taps IS ARRAY (0 TO NUM_OF_TAPS-1) OF SIGNED( x'RANGE );
    CONSTANT tk : taps := ( "11010111", -- -0.32
                            "00011110", --  0.23
                            "00011110", --  0.23
                            "11010111");-- -0.32
                            
    -- Saved samples
    SIGNAL xk : taps;
    
    -- LUT based on filter coefficients
    TYPE memory IS ARRAY (0 TO (2 ** NUM_OF_TAPS)-1 ) OF SIGNED( x'RANGE );
    CONSTANT lut : memory := (         
	              (N-1 DOWNTO 0 => '0')                                  , 	 -- 0000
                 TO_SIGNED(TO_INTEGER(tk(0)), N)                        ,   -- 0001
                 TO_SIGNED(TO_INTEGER(tk(1)), N)                        ,   -- 0010
                 TO_SIGNED(TO_INTEGER(tk(1) + tk(0)), N)                ,   -- 0011
                 TO_SIGNED(TO_INTEGER(tk(2)), N)                        ,   -- 0100
                 TO_SIGNED(TO_INTEGER(tk(2) + tk(0)), N)                ,   -- 0101
                 TO_SIGNED(TO_INTEGER(tk(2) + tk(1)), N)                ,   -- 0110
                 TO_SIGNED(TO_INTEGER(tk(2) + tk(1) + tk(0)), N)        ,   -- 0111
                 TO_SIGNED(TO_INTEGER(tk(3)), N)                        ,   -- 1000
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(0)), N)                ,   -- 1001
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(1)), N)                ,   -- 1010
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(1) + tk(0)), N)        ,   -- 1011
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(2)), N)                ,   -- 1100
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(2) + tk(0)), N)        ,   -- 1101
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(2) + tk(1)), N)        ,   -- 1110
                 TO_SIGNED(TO_INTEGER(tk(3) + tk(2) + tk(1) + tk(0)), N) ); -- 1111
                               
                               
    -- Counter
    SIGNAL i : NATURAL RANGE 0 TO N;
    
    -- Store the temporary results
    SIGNAL result : SIGNED( (2*N)-1 DOWNTO 0 );
    
    -- Started and finished flags
    SIGNAL n_finished : STD_LOGIC;
    SIGNAL started  : STD_LOGIC;
BEGIN
    -- Process for the FIR-filter calculations
    fir : PROCESS( reset, clk )
        VARIABLE address : STD_LOGIC_VECTOR( NUM_OF_TAPS-1 DOWNTO 0 );
        VARIABLE term : SIGNED( 2*N-1 DOWNTO 0 ) := (OTHERS => '0');
        VARIABLE unshifted_result : SIGNED( 2*N-1 DOWNTO 0 );
    BEGIN
        -- Asynchronous reset
        IF reset = '1' THEN
			-- Reset the output
            y <= (OTHERS => '0');
            
			-- Reset the start and finish flags
			started  <= '0';
            n_finished <= '0';
			
            -- Reset the stored samples
            FOR m IN 0 TO NUM_OF_TAPS-2 LOOP
                xk(m) <= (OTHERS => '0');
            END LOOP;
			
        ELSIF clk'EVENT AND clk = '1' THEN
            -- Start when we have had a pulse on start
            IF start = '1' THEN
                started <= '1';
                i <= 0;
                n_finished <= '0';
                result <= (OTHERS => '0');
                
                -- Update the stored samples
                xk(0) <= SIGNED(x);
                FOR m IN 0 TO NUM_OF_TAPS-2 LOOP
                    xk(m+1) <= xk(m);
                END LOOP;
                
            -- Do the FIR-filter calculations
            ELSIF started = '1' THEN
                IF i < N THEN
                    address := xk(3)(i) & xk(2)(i) & xk(1)(i) & xk(0)(i);
                    term(2*N-1 DOWNTO N) := lut( TO_INTEGER(UNSIGNED(address)) );
                    
                    IF i = N-1 THEN
                        started    <= '0';
                        n_finished <= '1';
                        unshifted_result := result - term;
                        y <= STD_LOGIC_VECTOR( unshifted_result((2*N)-1 DOWNTO N) );
                    ELSE
                        unshifted_result := result + term;
                        result <= SHIFT_RIGHT( unshifted_result, 1 );
                        i      <= i + 1;
                    END IF; 
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    finished <= n_finished;
END ARCHITECTURE distributed_fir_filter_arch;


