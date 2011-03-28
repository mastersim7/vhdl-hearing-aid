-- shift.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Shifting unit.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY shift IS
	GENERIC ( N : NATURAL := 32 );
    PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- A input
          B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- B input
          Op   : IN  STD_LOGIC_VECTOR(   1 DOWNTO 0 ); -- Op(1 DOWNTO 0)
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
END ENTITY shift;

ARCHITECTURE shift_arch OF shift IS
BEGIN
    shifting: PROCESS( A, B, Op )
        VARIABLE i  : NATURAL RANGE 0 TO N := 0;
        VARIABLE bv : BIT_VECTOR( N-1 DOWNTO 0 ) := (OTHERS => '0');
    BEGIN
        i := TO_INTEGER(UNSIGNED( B(4 DOWNTO 0) ));
        bv := TO_BITVECTOR(A);
        CASE Op IS
            WHEN "00" =>
                bv := bv SLL i;
            WHEN "10" =>
                bv := bv SRL i;
            WHEN OTHERS =>
                bv := bv SRA i;
        END CASE;
        Outs <= TO_STDLOGICVECTOR( bv );
    END PROCESS;
    
END shift_arch;
