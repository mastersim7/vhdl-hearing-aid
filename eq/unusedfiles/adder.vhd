LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY adder IS
    GENERIC ( N : NATURAL := 12; ); -- width of samples
                
    PORT (  --clk     : IN  STD_LOGIC;
	    DI1      : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
	    DI2      : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- Coefficient
            DO       : OUT STD_LOGIC_VECTOR( N-1   DOWNTO 0 ));  -- result

END ENTITY;
ARCHITECTURE adder_arch OF adder IS 
BEGIN 

process (DI1,DI2,DO)
	DO<= DI1 + DI2;
IF (DI1(N-1) XOR DI2(N-1)) AND (DO(N-1) XOR DI1(N-1))  = '0' THEN 
	IF DI1(N-1) = '1' THEN 
	-- if negative owerflow accures make output smallest 
	  DO(N-1)<= '1';
	  DO(N-2 DOWNTO 0) <= (others => '0')
	ELSE 
	-- if positive owerflow accures make output biggest
	  DO(N-1)<= '0';
	  DO(N-2 DOWNTO 0) <= (others => '1')
	END IF;
	END IF; 

END ARCHITECTURE multiplier_arch;
