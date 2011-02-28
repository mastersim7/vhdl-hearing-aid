-- data_buffer.vhd
--  version 0
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY data_buffer IS
    GENERIC ( N_D : NATURAL := 12; -- Bit length of the vectors
              N : NATURAL :=220 );  -- Order of the filter
    
    PORT ( 
            clk       : IN  STD_LOGIC; -- System clock (50 MHz)
            CE        : IN  STD_LOGIC; -- Clock Enable (SAME CLOCK THAT IS GOING TO BE USED IN THE EQ  XkHz)
            load      : IN  STD_LOGIC; -- Load sample 22300 kHz
            reset     : IN  STD_LOGIC; -- Load sample 40 kHz
            sample_in : IN  STD_LOGIC_VECTOR( N_D-1 DOWNTO 0 );
            Read      : IN  STD_LOGIC;
            OE        : OUT STD_LOGIC;
            sample_out: OUT STD_LOGIC_VECTOR( N_D-1 DOWNTO 0 ));
            
END ENTITY;

ARCHITECTURE data_Buffer_arch OF Data_Buffer IS
TYPE Buffer_array is ARRAY (N DOWNTO 0) OF STD_LOGIC_VECTOR(N_D-1 DOWNTO 0) ; 
SIGNAL sample_sig : Buffer_array;
BEGIN
    Load_Data: PROCESS( clk )
        VARIABLE last_sample : STD_LOGIC_VECTOR( N_D-1 DOWNTO 0 );
        VARIABLE Sample_Buffer : Buffer_array;
        VARIABLE Pointer : INTEGER RANGE 0 TO N;
    BEGIN
        IF clk'EVENT AND clk = '1' THEN --   MHz
          IF reset = '1' THEN 
            FOR I IN 0 TO N LOOP
            Sample_Buffer(I) := (Others => '0' ) ;
          END LOOP;
            Pointer := 0;
          ELSE
            sample_sig <=  sample_buffer;
            IF CE = '1' THEN            --  kHz
                IF load = '1' THEN      --  22300 kHz
                     Sample_Buffer(Pointer):=sample_in ;
                     Pointer := Pointer +1;
                ELSIF (LOAD = '0') and (READ = '1') THEN 
                    sample_out <= Sample_Buffer(Pointer - 1) ;
                     Pointer := Pointer +1;
                END IF;
                OE <= '1';
        ELSE
            OE <= '0';
         END IF;
        END IF;
      END IF;
      
    END PROCESS;
END ARCHITECTURE;