-- regular_buffer.vhd
-- version 1.0
-- Mathias Lundell
-- 2011-03-04
-- 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY regular_buffer IS
    GENERIC ( N        : NATURAL := 12;    -- Bit length of the vectors
              NUM_OF_TAPS : NATURAL := 220 );  -- Number of taps
    
    PORT (  clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN sample;
            CE		 : IN STD_LOGIC;
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
            UPDATED      : OUT STD_LOGIC;
            sample_out_1 : OUT sample;
            sample_out_2 : OUT sample);
END ENTITY;

ARCHITECTURE regular_buffer_arch OF regular_buffer IS
BEGIN
    buffer_process: PROCESS( clk )
        TYPE buffer_type IS ARRAY (0 TO NUM_OF_TAPS-1) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        VARIABLE samples : buffer_type;
        VARIABLE counter : NATURAL RANGE 0 TO NUM_OF_TAPS/2-1;
        VARIABLE REWE : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN   
        IF clk'EVENT AND clk = '1' THEN
            IF reset = '1' THEN
                -- Reset the stored samples
                FOR m IN 0 TO NUM_OF_TAPS-1 LOOP
                    samples(m) := (OTHERS => '0');
                END LOOP;
                counter := 0;
                sample_out_1 <= samples(samples'LEFT+counter);
                sample_out_2 <= samples(samples'RIGHT-counter);
            ELSIF CE='1' THEN
                REWE := RE & WE;
                CASE (REWE) IS
                    WHEN "01" =>
                        -- Update the stored samples (propagate samples downward in stack)
                        FOR m IN NUM_OF_TAPS-1 DOWNTO 1 LOOP
                            samples(m) := samples(m-1);
                        END LOOP;
                        samples(0) := sample_in;
                        UPDATED<= '1';

                    WHEN "10" =>
                        UPDATED<= '1';
                        -- Read samples
                        sample_out_1 <= samples(0+counter);
                        sample_out_2 <= samples(NUM_OF_TAPS-1-counter);
                
                        IF counter < NUM_OF_TAPS/2-1 THEN
                            counter := counter + 1;
                        ELSE
                            counter := 0;
                        END IF;
								
                    WHEN "11" =>
                        sample_out_1 <= samples(0+counter);
                        sample_out_2 <= samples(NUM_OF_TAPS-1 - counter);
                        
                        IF counter < NUM_OF_TAPS/2-1 THEN
                            counter := counter + 1;
                        ELSE
                            counter := 0;
                        END IF;
                        
                        -- Update the stored samples (propagate samples downward in stack)
                        FOR m IN 0 TO NUM_OF_TAPS-2 LOOP
                            samples(m+1) := samples(m);
                        END LOOP;
                        samples(0) := sample_in;
								
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
