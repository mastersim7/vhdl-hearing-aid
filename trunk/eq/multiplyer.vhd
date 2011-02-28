LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY multiplyer IS
    GENERIC ( N : NATURAL := 12; 
	      M : NATURAL := 24	); -- width of samples
                
    PORT (  --clk     : IN  STD_LOGIC;
	    DI      : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
	    DI_C      : IN  STD_LOGIC_VECTOR( M-1 DOWNTO 0 );     -- Coefficient

            
            DO       : OUT STD_LOGIC_VECTOR( N+M-1   DOWNTO 0 ));  -- result
END ENTITY;
ARCHITECTURE multiplyer_arch OF multiplyer IS 
BEGIN 
DO<= DI * DI_C;
END ARCHITECTURE multiplyer_arch;
