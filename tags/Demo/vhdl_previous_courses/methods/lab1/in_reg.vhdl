-- in_reg.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Input register (flip-flop) to ALU
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY in_reg IS
	GENERIC ( N : NATURAL := 32 );
    PORT( Clk  : IN  STD_LOGIC;                      -- System clock
          Reset: IN  STD_LOGIC;                      -- Reset
          A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0); -- A input
          B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0); -- B input
          Op   : IN  STD_LOGIC_VECTOR(  3 DOWNTO 0); -- Operation code
          
          qA   : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0); -- A output 
          qB   : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0); -- B output
          qOp  : OUT STD_LOGIC_VECTOR(  3 DOWNTO 0));-- Op output
END ENTITY in_reg;

ARCHITECTURE in_reg_arch OF in_reg IS
BEGIN
    -- Synchronous reset (active low) resets outputs or
    -- rising edge clock updates output with input values
    shift_out: PROCESS( clk )
    BEGIN
        IF Clk'EVENT AND Clk = '1' THEN
            IF reset = '0' THEN
                qA <= (OTHERS => '0');
                qB <= (OTHERS => '0');
                qOp<= (OTHERS => '0');
            ELSE
                qA <= A;
                qB <= B;
                qOp<= Op;
            END IF;
        END IF;
    END PROCESS;
            
END in_reg_arch;