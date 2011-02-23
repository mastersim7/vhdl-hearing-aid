-- in_reg.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- Output register (flip-flop) from ALU
-- MUX functionality
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY out_reg IS
	GENERIC ( N : NATURAL := 32 );
    PORT( Clk  : IN  STD_LOGIC;                     -- System clock
          Reset: IN  STD_LOGIC;                     -- Reset
          D1   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D1 input
          D2   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D2 input
          D3   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D3 input
          D4   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D4 input
          Op   : IN  STD_LOGIC_VECTOR(   3 DOWNTO 2);-- Op code input (Op(3 DOWNTO 2))
          
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0));-- Outs 
END ENTITY out_reg;

ARCHITECTURE out_reg_arch OF out_reg IS

BEGIN
    -- Asynchronous reset (active low) resets outputs or
    -- rising edge clock updates output with selected input
    update_output: PROCESS( clk )
    BEGIN
        IF Clk'EVENT AND Clk = '1' THEN
            IF reset = '0' THEN
                Outs <= (OTHERS => '0');
            ELSE            
                CASE Op IS
                    -- Arithmetic unit
                    WHEN "00" =>
                        Outs <= D1;
                    -- Compare
                    WHEN "11" =>
                        Outs <= D2;
                    -- Logical unit
                    WHEN "01" =>
                        Outs <= D3;
                    -- Shifter
                    WHEN OTHERS =>
                        Outs <= D4;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
            
END out_reg_arch;