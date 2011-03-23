-- regular_buffer.vhd
-- version 1.0
-- Mathias Lundell
-- 2011-03-04
-- Changed by others later...
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;

ENTITY regular_buffer IS
    GENERIC ( N           : NATURAL := 12;    -- Bit length of the vectors
              NUM_OF_TAPS : NATURAL := 220 );  -- Number of taps
    
    PORT (  clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  sample;
            nr           : IN  STD_LOGIC_VECTOR(6 DOWNTO 0); -- nr of sample to read
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
            updated      : OUT STD_LOGIC;
            sample_out_1 : OUT sample;
            sample_out_2 : OUT sample);
END ENTITY;

ARCHITECTURE regular_buffer_arch OF regular_buffer IS
BEGIN
    buffer_process: PROCESS( clk )
        TYPE buffer_type IS ARRAY (0 TO NUM_OF_TAPS-1) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        VARIABLE samples : buffer_type;
        VARIABLE nr_int, nr_int_new, nr_int_old : INTEGER RANGE 0 TO NUM_OF_TAPS;
		  VARIABLE index_new : NATURAL RANGE 0 TO NUM_OF_TAPS;
		  VARIABLE index_old : NATURAL RANGE 0 TO NUM_OF_TAPS;
    BEGIN   
        IF clk'EVENT AND clk = '1' THEN
            IF reset = '1' THEN
                -- Reset the stored samples
                FOR m IN 0 TO NUM_OF_TAPS-1 LOOP
                    samples(m) := (OTHERS => '0');
                END LOOP;
                index_new := 0;
                index_old := 1;
            ELSIF WE = '1' THEN
                samples(index_new) := sample_in;
                
                -- Update variables
                IF index_new /= NUM_OF_TAPS-1 THEN
                   index_new := index_new + 1;
              ELSE
                  index_new := 0;
              END IF;
              IF index_old /= NUM_OF_TAPS-1 THEN
                  index_old := index_old + 1;
            ELSE
                index_old := 0;
              END IF;
					      
            ELSIF RE = '1' THEN
                updated <= '0';
                nr_int := TO_INTEGER(UNSIGNED(nr));
                IF (index_new - nr_int) > 0 THEN
                  nr_int_new := index_new - nr_int;
                ELSE
                  nr_int_new := index_new - nr_int + NUM_OF_TAPS-1;
              END IF;
                IF (index_old-1 + nr_int) < NUM_OF_TAPS-1 THEN
                  nr_int_old := index_old-1 + nr_int;
                ELSE
                  nr_int_old := index_old-1 + nr_int - (NUM_OF_TAPS-1);
              END IF;
                -- Read samples
                sample_out_1 <= samples(nr_int_new);
                sample_out_2 <= samples(nr_int_old);
            ELSE
                updated <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
