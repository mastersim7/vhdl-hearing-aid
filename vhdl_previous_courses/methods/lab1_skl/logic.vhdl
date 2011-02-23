-- logic.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Bitwise logical unit.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY logic IS
	GENERIC ( N : NATURAL := 32 );
    PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- A input
          B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- B input
          Op   : IN  STD_LOGIC_VECTOR(   1 DOWNTO 0 ); -- Op(1 DOWNTO 0)
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
END ENTITY logic;

ARCHITECTURE logic_arch OF logic IS
BEGIN
    WITH Op SELECT
        Outs <= (A AND B) WHEN "00",
                (A  OR B) WHEN "01",
                (A NOR B) WHEN "10",
                (A XOR B) WHEN OTHERS;
END logic_arch;