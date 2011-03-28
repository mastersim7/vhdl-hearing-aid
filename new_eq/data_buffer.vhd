-- data_buffer.vhd
--  version 0
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_buffer IS
    GENERIC ( N     : NATURAL := 12;    -- Bit length of the vectors
              TAPS_NUM : NATURAL :=220 );  -- Number of taps
    
    PORT ( 
            clk       : IN  STD_LOGIC; -- System clock (50 MHz)
            reset     : IN  STD_LOGIC; -- reset
            sample_in : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            RE        : IN  STD_LOGIC;
				WE			 : IN  STD_LOGIC;
            OE        : OUT STD_LOGIC;
            sample_out_1 : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
				sample_out_2 : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
            
END ENTITY;

ARCHITECTURE data_buffer_arch OF data_buffer IS
	TYPE Buffer_array is ARRAY (0 TO (TAPS_NUM-1)) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0); 
BEGIN
    Load_Data: PROCESS( clk )
		  VARIABLE newest : INTEGER RANGE 0 TO TAPS_NUM-1; -- pointer to newest sample
		  VARIABLE oldest : INTEGER RANGE 0 TO TAPS_NUM-1; -- pointer to oldest sample
		  VARIABLE counter : INTEGER RANGE 0 TO (TAPS_NUM/2)-1; -- incrementer when looping through buffer
        VARIABLE Sample_Buffer : Buffer_array; -- the buffer of samples
		  VARIABLE temp : INTEGER RANGE 0 TO TAPS_NUM-1;
		  VARIABLE REWE : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        IF clk'EVENT AND clk = '1' THEN --   MHz
			 -- Synchronous reset
          IF reset = '1' THEN 
            FOR i IN 0 TO TAPS_NUM-1 LOOP
					Sample_Buffer(i) := (Others => '0' ) ;
				END LOOP;
            newest := 0;
				oldest := TAPS_NUM-1;
				counter := 0;
          ELSE
			   --
				-- We should consider if we want to write and read values at the same time.
				-- Also how we should handle this?
				-- We have idea of giving read higher priority, so we read first and then write.
				REWE := RE & WE;
				CASE (REWE) IS
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
					
					WHEN "10" =>
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
					
					WHEN "11" =>
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
					WHEN OTHERS =>
						NULL;
				END CASE;
			END IF;
      END IF;
    END PROCESS;
END ARCHITECTURE;
