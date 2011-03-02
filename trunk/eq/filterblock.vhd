LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.all;
ENTITY filterblock IS 
	GENERIC ( L : NATURAL := 12); 
	PORT	( 	clk : IN STD_LOGIC ;
			DI1 : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0); 
			DI2 : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0); 
			DO  : OUT  STD_LOGIC_VECTOR(L-1 DOWNTO 0);
			READ : OUT STD_LOGIC;
			OE	:  OUT STD_LOGIC
		);
END filterblock;

ARCHITECTURE filterblock_arch of filterblock IS 
	COMPONENT multiplier IS
    		GENERIC ( N : NATURAL := 12; 
	      		  M : NATURAL := 24	); -- width of samples
                
		PORT (      DI      : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
			    DI_C      : IN  STD_LOGIC_VECTOR( M-1 DOWNTO 0 );     -- Coefficient            
		            DO       : OUT STD_LOGIC_VECTOR( N+M-1   DOWNTO 0 ));  -- result
	END COMPONENT multiplier;
BEGIN 
END filterblock_arch; 

			

