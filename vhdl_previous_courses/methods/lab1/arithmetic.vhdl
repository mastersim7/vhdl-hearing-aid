-- arithmetic.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Arithmetic unit (ripple carry adder/subtracter).
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY arithmetic IS
	GENERIC ( N : NATURAL := 32 );
    PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- A input
          B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- B input     
          Op   : IN  STD_LOGIC;                        -- Op(1)
          CO   : OUT STD_LOGIC;                        -- Carry out
          V    : OUT STD_LOGIC;                        -- Overflow flag
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
END ENTITY arithmetic;


ARCHITECTURE arithmetic_arch OF arithmetic IS

	-- Full Adder
    COMPONENT FA IS
        PORT( A    : IN  STD_LOGIC; -- A input
              B    : IN  STD_LOGIC; -- B input
              Cin  : IN  STD_LOGIC; -- Carry in
              S    : OUT STD_LOGIC; -- Sum 
              Cout : OUT STD_LOGIC);-- Carry out
    END COMPONENT;
    
    
    
    SIGNAL nB : STD_LOGIC_VECTOR( B'RANGE );
    SIGNAL nC : STD_LOGIC_VECTOR( A'LEFT+1 DOWNTO 0 );
    
    
BEGIN
	-- 1s complement of B for subtraction
    nB <= (NOT B) WHEN Op = '1' ELSE   -- sub
               B;                      -- add

    -- The LS Carry in is used to generate 2's comp of B
    nC(0) <= '1' WHEN Op = '1' ELSE   -- sub
             '0';                     -- add
			 
    -- Generate FA components for the ripple carry adder
    FA_0 : FA PORT MAP( A(0), nB(0), nC(0), Outs(0), nC(1) );
    generate_fa: FOR i IN 1 TO N-1 GENERATE
        FA_i : FA PORT MAP( A(i), nB(i), nC(i), Outs(i), nC(i+1) );
    END GENERATE;
    
	-- Output the last carry out and overflow
    CO <= nC(nC'LEFT);           -- Carry out
    V  <= nC(nC'LEFT) XOR nC(nC'LEFT-1);-- Overflow
    
END arithmetic_arch;