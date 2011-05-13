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
    GENERIC ( N              : NATURAL := 12;    -- Bit length of the vectors
              NUM_OF_SAMPLES : NATURAL  );  -- Number of taps
    
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
    TYPE buffer_type IS ARRAY (0 TO NUM_OF_SAMPLES-1) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    SIGNAL samples : buffer_type;
    SIGNAL nr_of_old_sample : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL nr_of_new_sample : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
    buffer_process: PROCESS( clk )
        VARIABLE nr_int : INTEGER RANGE 0 TO NUM_OF_SAMPLES;
    BEGIN   
        IF clk'EVENT AND clk = '1' THEN
            IF reset = '1' THEN
                -- Reset the stored samples
                FOR m IN 0 TO NUM_OF_SAMPLES-1 LOOP
                    samples(m) <= (OTHERS => '0');
                END LOOP;
                sample_out_1 <= (OTHERS => '0');
                sample_out_2 <= (OTHERS => '0');
                updated <= '0';
            ELSIF WE = '1' THEN
                -- Update the stored samples (propagate samples downward in stack)
                FOR m IN NUM_OF_SAMPLES-1 DOWNTO 1 LOOP
                    samples(m) <= samples(m-1);
                END LOOP;
                samples(0) <= sample_in;
                updated <= '1';

            ELSIF RE = '1' THEN
                updated <= '0';
                nr_int := TO_INTEGER(UNSIGNED(nr));
                
                assert nr_int < NUM_OF_SAMPLES/2
                    report "nr_int is too large (in regular buffer)"
                    severity error;
                    
                -- Read samples
                sample_out_1 <= samples(nr_int);
                sample_out_2 <= samples(NUM_OF_SAMPLES - 1 - nr_int);
            ELSE
                updated <= '0';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
