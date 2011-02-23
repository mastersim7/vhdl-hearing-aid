-- ALU_SKL.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- ALU - Sklansky adder
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ALU_SKL IS
	GENERIC ( N : NATURAL := 32 );
    PORT( Clk  : IN  STD_LOGIC;                      -- System clock
          Reset: IN  STD_LOGIC;                      -- Reset
          A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0); -- A input
          B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0); -- B input
          Op   : IN  STD_LOGIC_VECTOR(   3 DOWNTO 0); -- Operation code
          Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0));-- Output
END ENTITY ALU_SKL;


ARCHITECTURE ALU_SKL_arch OF ALU_SKL IS

    -----------------------------------------------------------------------------
    -- Components
    -----------------------------------------------------------------------------
    COMPONENT in_reg IS
		GENERIC ( N : NATURAL := 32 );
        PORT( Clk  : IN  STD_LOGIC;                     -- System clock
              Reset: IN  STD_LOGIC;                     -- Reset
              A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- A input
              B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- B input
              Op   : IN  STD_LOGIC_VECTOR(   3 DOWNTO 0);-- Operation code
          
              qA   : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- A output 
              qB   : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- B output
              qOp  : OUT STD_LOGIC_VECTOR(   3 DOWNTO 0));-- Op output
    END COMPONENT;
    
	
    COMPONENT out_reg IS
		GENERIC ( N : NATURAL := 32 );
		PORT( Clk  : IN  STD_LOGIC;                     -- System clock
			  Reset: IN  STD_LOGIC;                     -- Reset
			  D1   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D1 input
			  D2   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D2 input
			  D3   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D3 input
			  D4   : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0);-- D4 input
			  Op   : IN  STD_LOGIC_VECTOR(   3 DOWNTO 2);-- Op(3 DOWNTO 2)
			  Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0));-- Outs 
    END COMPONENT out_reg;
    
	
    COMPONENT arithmetic_skl IS
		GENERIC ( N : NATURAL := 32 );
        PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );-- A input
              B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );-- B input     
              Op   : IN  STD_LOGIC; -- Op(1)
              CO   : OUT STD_LOGIC; -- Carry out
              V    : OUT STD_LOGIC; -- Overflow flag
              Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
    END COMPONENT arithmetic_skl;
    
	
    COMPONENT logic IS
		GENERIC ( N : NATURAL := 32 );
        PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- A input
              B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- B input
              Op   : IN  STD_LOGIC_VECTOR(   1 DOWNTO 0 ); -- Op(1 DOWNTO 0)
              Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
    END COMPONENT logic;
    
	
    COMPONENT shift IS
		GENERIC ( N : NATURAL := 32 );
        PORT( A    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- A input
              B    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- B input
              Op   : IN  STD_LOGIC_VECTOR(   1 DOWNTO 0 ); -- Op(1 DOWNTO 0)
              Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- Outs (result)
    END COMPONENT shift;
    
	
    COMPONENT compare IS
		GENERIC ( N : NATURAL := 32 );
        PORT( R    : IN  STD_LOGIC; -- Arithmetic MSB
              C    : IN  STD_LOGIC; -- Arithmetic Carry out
              V    : IN  STD_LOGIC; -- Arithmetic overflow flag
              Op   : IN  STD_LOGIC; -- Op(0)
              Outs : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));-- SLT/SLTU result
    END COMPONENT compare;
    
	
	
	
    -----------------------------------------------------------------------------
    -- Internal signals between the components
    -----------------------------------------------------------------------------
    SIGNAL qA  : STD_LOGIC_VECTOR(     A'RANGE );
    SIGNAL qB  : STD_LOGIC_VECTOR(     B'RANGE );
    SIGNAL qOp : STD_LOGIC_VECTOR(    Op'RANGE );
    
    SIGNAL D1  : STD_LOGIC_VECTOR(  Outs'RANGE );
    SIGNAL D2  : STD_LOGIC_VECTOR(  Outs'RANGE );
    SIGNAL D3  : STD_LOGIC_VECTOR(  Outs'RANGE );
    SIGNAL D4  : STD_LOGIC_VECTOR(  Outs'RANGE );
    
    SIGNAL CO  : STD_LOGIC;
    SIGNAL  V  : STD_LOGIC;
    
	
BEGIN

    -- Bind the components
    input_register : in_reg         PORT MAP( Clk, Reset, A, B, Op, qA, qB, qOp );
    arithmetic_unit: arithmetic_skl PORT MAP( qA, qB, qOp(1), CO, V, D1 );
    compare_unit   : compare        PORT MAP( D1(D1'LEFT), CO, V, qOp(0), D2 );
    logical_unit   : logic          PORT MAP( qA, qB, qOp(1 DOWNTO 0), D3 );
    shifter_unit   : shift          PORT MAP( qA, qB, qOp(1 DOWNTO 0), D4 );
    output_register: out_reg        PORT MAP( Clk, Reset, D1, D2, D3, D4, qOp(3 DOWNTO 2), Outs ); 
    
END ALU_SKL_arch;