-- vector_multiplication.vhd
-- Mathias Lundell
-- 091020
--
-- Note:
-- To be sure we have full accuracy we need the output port
-- to be of lg(2^(2n-2)+1)+1 bits.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;
USE ieee.numeric_std.ALL;

ENTITY vector_multiplication IS
    GENERIC ( N : NATURAL := 8 );
    PORT ( a : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
           b : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
           y : OUT STD_LOGIC_VECTOR( NATURAL(CEIL(LOG2(REAL( 2 ** ((2*N)-2)+1 )))) DOWNTO 0 ));
END ENTITY;

ARCHITECTURE vector_multiplication_arch OF vector_multiplication IS
BEGIN
    y <= STD_LOGIC_VECTOR( SIGNED(a) * SIGNED(b) );
END ARCHITECTURE;