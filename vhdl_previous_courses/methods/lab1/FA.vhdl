-- FA.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- One bit full adder
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FA IS
    PORT( A    : IN  STD_LOGIC; -- A input
          B    : IN  STD_LOGIC; -- B input
          Cin  : IN  STD_LOGIC; -- Carry in
          S    : OUT STD_LOGIC; -- Sum 
          Cout : OUT STD_LOGIC);-- Carry out
END ENTITY FA;

ARCHITECTURE FA_arch OF FA IS
BEGIN
    -- Calculate sum
    S    <= (A XOR B) XOR Cin;
    
    -- Calculate carry out
    Cout <= (A AND B) OR (A AND Cin) OR (B AND Cin);
END FA_arch;