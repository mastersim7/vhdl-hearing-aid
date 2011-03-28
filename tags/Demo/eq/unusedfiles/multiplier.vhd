-- TO be used as compnent but later changed and moved into a function, is Xilinx complier treathes the FUNCTION and COMPONENTS differntly while syntisizing 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY multiplier IS
    GENERIC ( N : NATURAL := 13; 
	      M : NATURAL := 26	); -- width of samples
                
    PORT (  --clk     : IN  STD_LOGIC;
	    DI      : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
	    DI_C      : IN  STD_LOGIC_VECTOR( M-1 DOWNTO 0 );     -- Coefficient

            
            DO       : OUT STD_LOGIC_VECTOR( N+M-1   DOWNTO 0 ));  -- result
END ENTITY;
ARCHITECTURE multiplier_arch OF multiplier IS 
BEGIN 
DO<= DI * DI_C;
END ARCHITECTURE multiplier_arch;
