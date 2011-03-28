-- compare.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Comparison unit.
-- Set less than and set less than unsigned (SLT, SLTU)
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY compare IS
	GENERIC ( N : NATURAL := 32 );
    PORT( R    : IN  STD_LOGIC; -- Arithmetic MSB
          C    : IN  STD_LOGIC; -- Arithmetic Carry out
          V    : IN  STD_LOGIC; -- Arithmetic overflow flag
          Op   : IN  STD_LOGIC; -- Op(0)
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- SLT/SLTU result
END ENTITY compare;

ARCHITECTURE compare_arch OF compare IS
    SIGNAL x : STD_LOGIC;
BEGIN
    -- SLT  = Outs(MSB) XOR V
    -- SLTU = NOT C
    x <= (R XOR V) WHEN Op = '0' ELSE
         (NOT C);
         
    Outs <= (N-1 DOWNTO 1 => '0') & x;
END compare_arch;