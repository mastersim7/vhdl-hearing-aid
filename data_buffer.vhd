-- data_buffer.vhd
--  version 0
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_buffer IS
    GENERIC ( N     : NATURAL := 12;    -- Bit length of the vectors
              TAPS_NUM : NATURAL :=220 );  -- Number of taps
    
    PORT ( 
            clk         : IN  STD_LOGIC; -- System clock (50 MHz)
            reset       : IN  STD_LOGIC; -- reset
            nr          : IN  STD_LOGIC_VECTOR( 7 DOWNTO 0 ); -- number of sample (between 0 and 109)
            sample_in   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            RE          : IN  STD_LOGIC;
            WE			: IN  STD_LOGIC;
            updated     : OUT STD_LOGIC;
            sample_new  : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            sample_old  : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
            
END ENTITY;

ARCHITECTURE data_buffer_arch OF data_buffer IS
    TYPE Buffer_array is ARRAY (0 TO (TAPS_NUM-1)) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0); 
BEGIN
    buffer_process: PROCESS( clk )

        VARIABLE Sample_Buffer : Buffer_array; -- the buffer of samples
        VARIABLE temp : INTEGER RANGE 0 TO TAPS_NUM-1;
    BEGIN
        IF clk'EVENT AND clk = '1' THEN --   MHz
			 -- Synchronous reset
            IF reset = '1' THEN 
                FOR i IN 0 TO TAPS_NUM-1 LOOP
                    Sample_Buffer(i) := (Others => '0' ) ;
                END LOOP;
                newest := 0;
                oldest := TAPS_NUM-1;
            ELSE
				IF WE = '1' THEN
                    WHEN "01" =>
                        -- Write sample
                        IF newest < TAPS_NUM-1 THEN
                            newest := newest + 1;
                        ELSE
                            newest := 0;
                        END IF;
					 
                        IF oldest > 0 THEN
                            oldest := oldest - 1;
                        ELSE
                            oldest := TAPS_NUM-1;
                        END IF;
                        Sample_Buffer(newest) := sample_in;
					
                ELSIF RE = '1' THEN
                    -- Read sample
                    -- Output of new values
                    IF (newest - counter) >= 0 THEN
                        sample_out_1 <= Sample_Buffer(newest-counter);
                    ELSE
                        temp := newest - counter + TAPS_NUM;
                        sample_out_1 <= Sample_Buffer(temp);
                    END IF;
                                
                    -- Output of old values
                    IF (oldest + counter) <= (TAPS_NUM-1) THEN
                        sample_out_2 <= Sample_Buffer(oldest+counter);
                    ELSE
                        temp := oldest + counter - TAPS_NUM;
                        sample_out_2 <= Sample_Buffer(temp);
                    END IF;
                                
                    -- Increment counter
                    IF counter < (TAPS_NUM/2) THEN
                        counter := counter + 1;
                    ELSE
                        counter := 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
