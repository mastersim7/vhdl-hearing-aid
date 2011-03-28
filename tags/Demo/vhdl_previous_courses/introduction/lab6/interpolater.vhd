-- interpolater.vhd
-- Mathias Lundell
-- 101013-15:39
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interpolater IS
    GENERIC ( N : NATURAL := 12 ); -- Bit length of the vectors
    PORT ( 
            clk       : IN  STD_LOGIC; -- System clock (50 MHz)
            CE        : IN  STD_LOGIC; -- Clock Enable (Input signal of 120 kHz)
            load      : IN  STD_LOGIC; -- Load sample 40 kHz
            sample_in : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            
            OE        : OUT STD_LOGIC;
            sample_out: OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
            
END ENTITY;

ARCHITECTURE interpolater_arch OF interpolater IS
BEGIN
    inperpolate: PROCESS( clk )
        VARIABLE last_sample : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
    BEGIN
        IF clk'EVENT AND clk = '1' THEN --  50 MHz
            IF CE = '1' THEN            -- 120 kHz
                IF load = '1' THEN      --  30 kHz
                    sample_out <= sample_in;
						  last_sample := sample_in;
                ELSE
                    sample_out <= last_sample;
                END IF;
                OE <= '1';
				ELSE
				    OE <= '0';
			   END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;