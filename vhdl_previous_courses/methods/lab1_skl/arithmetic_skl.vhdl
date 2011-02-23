-- arithmetic.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Arithmetic unit using Sklansky adder.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY arithmetic_skl IS
	GENERIC ( N : NATURAL := 32 );
    PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- A input
          B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- B input     
          Op   : IN  STD_LOGIC;                        -- Op(1)
          CO   : OUT STD_LOGIC;                        -- Carry out
          V    : OUT STD_LOGIC;                        -- Overflow flag
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
END ENTITY arithmetic_skl;


ARCHITECTURE arithmetic_skl_arch OF arithmetic_skl IS

	-- Sklansky adder
    COMPONENT sklansky IS
        PORT( OpA    : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- A input
              OpB    : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- B input
              Cin    : IN  STD_LOGIC; -- Carry in
              Cout   : OUT STD_LOGIC;
              V      : OUT STD_LOGIC;
              Result : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ));-- Carry out
    END COMPONENT;
    
    
    
    SIGNAL nB : STD_LOGIC_VECTOR( B'RANGE );
    SIGNAL nC : STD_LOGIC;
    
BEGIN
	-- 1s complement of B for subtraction
    nB <= (NOT B) WHEN Op = '1' ELSE   -- sub
               B;                      -- add

    -- The LS Carry in is used to generate 2's comp of B
    nC <= '1' WHEN Op = '1' ELSE   -- sub
          '0';                     -- add
    
    skl : sklansky 
        PORT MAP(
            OpA    => A,
            OpB    => nB,
            Cin    => nC,
            Cout   => CO,
            V      => V,
            Result => Outs);
            
END arithmetic_skl_arch;