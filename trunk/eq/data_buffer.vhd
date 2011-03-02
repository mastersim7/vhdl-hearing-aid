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

ARCHITECTURE data_Buffer_arch OF Data_Buffer IS
	TYPE Buffer_array is ARRAY (TAPS_NUM-1 DOWNTO 0) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0) ; 
	
	-- Read sample pair from buffer --
	-- This is currently not working!!!!!
	PROCEDURE read_sample(newest : IN INTEGER;
	                      oldest : IN INTEGER;
								 counter: INOUT INTEGER;
								 Sample_Buffer : IN Buffer_Array;
								 sample_out1_var : INOUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
								 sample_out2_var : INOUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)) IS
		VARIABLE temp : INTEGER RANGE 0 TO TAPS_NUM-1;
	BEGIN
		-- Output of new values
		IF (newest - counter) >= 0 THEN
			sample_out1_var := Sample_Buffer(newest-counter);
		ELSE
			temp := newest - counter + TAPS_NUM;
			sample_out1_var := Sample_Buffer(temp);
		END IF;
					
		-- Output of old values
		IF ((oldest + counter) =< (TAPS_NUM-1)) THEN
			sample_out2_var := Sample_Buffer(oldest+counter);
		ELSE
			temp := oldest + counter - TAPS_NUM;
			sample_out2_var := Sample_Buffer(temp);
		END IF;
					
		-- Increment counter
		IF counter < (TAPS_NUM/2) THEN
			counter := counter + 1;
		ELSE
			counter := 0;
		END IF;
	END PROCEDURE read_sample;
	
	
	-- Write a sample to buffer and increment pointers
	-- Also not working!!!!!!!!!!!!!!
	PROCEDURE write_sample(newest : INOUT VARIABLE INTEGER;
	                       oldest : INOUT VARIABLE INTEGER;
								  Sample_Buffer : INOUT VARIABLE Buffer_Array) IS
	BEGIN
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
					 
		Sample_Buffer(newest) <= sample_in; 
	END PROCEDURE write_sample;
	

BEGIN
    Load_Data: PROCESS( clk )
		  VARIABLE newest : INTEGER RANGE 0 TO TAPS_NUM-1; -- pointer to newest sample
		  VARIABLE oldest : INTEGER RANGE 0 TO TAPS_NUM-1; -- pointer to oldest sample
		  VARIABLE counter : INTEGER RANGE 0 TO (TAPS_NUM/2)-1; -- incrementer when looping through buffer
        VARIABLE Sample_Buffer : Buffer_array; -- the buffer of samples
											 
		 -- Signals for procedure, not proven to work yet. (maybe unnecessary)
		  VARIABLE sample_out1_var : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  VARIABLE sample_out2_var : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    BEGIN
        IF clk'EVENT AND clk = '1' THEN --   MHz
			 -- Synchronous reset
          IF reset = '1' THEN 
            FOR i IN 0 TO ORDER-1 LOOP
					Sample_Buffer(i) := (Others => '0' ) ;
				END LOOP;
            newest := 0;
				oldest := TAPS_NUM-1;
				counter := 0;
				write_guard := TRUE; 
          ELSE
			   --
				-- We should consider if we want to write and read values at the same time.
				-- Also how we should handle this?
				-- We have idea of giving read higher priority, so we read first and then write.
				IF RE = '1' AND WE = '0' THEN
					read_sample(newest, oldest, counter, Sample_Buffer, sample_out1_var, sample_out2_var);
				
				ELSIF RE = '1' AND WE = '1' THEN
					read_sample(newest, oldest, counter, Sample_Buffer, sample_out1_var, sample_out2_var);
					write_sample(newest, oldest, Sample_Buffer);
				ELSIF WE = '1' AND RE = '0' THEN
					write_sample(newest, oldest, Sample_Buffer);
				ELSE
					NULL;
				END IF;
				
				sample_out_1 <= sample_out1_var; -- testing
				sample_out_2 <= sample_out2_var; -- testing
        END IF;
      END IF;
    END PROCESS;
END ARCHITECTURE;