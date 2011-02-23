-- vector_adder.vhd
-- 100910 Mathias Lundell
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vector_adder IS
    GENERIC ( N : NATURAL := 4 );
    PORT ( a : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
           b : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
           y : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
END ENTITY vector_adder;

ARCHITECTURE vector_adder_arch OF vector_adder IS
BEGIN
    y <= STD_LOGIC_VECTOR( SIGNED(a) + SIGNED(b) );
END vector_adder_arch;