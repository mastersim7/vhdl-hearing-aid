-- ALU_TB.vhd
-- Mathias Lundell & Alexey Sidelnikov
-- 101109-18:58
--
-- ALU_TB
--
  LIBRARY ieee;
  LIBRARY std;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  USE std.textio.ALL;
  USE ieee.std_logic_textio.ALL;
  
  ENTITY ALU_TB IS
  END ENTITY;
  
  ARCHITECTURE Behaviour OF ALU_TB IS
	-----------------------------------------------------------------------------
	-- Declarations
	-----------------------------------------------------------------------------
	constant Size    : integer := 1001;
	type Operand_array is array (Size downto 0) of std_logic_vector(31 downto 0);
	type OpCode_array is array (Size downto 0) of std_logic_vector(3 downto 0);

	-----------------------------------------------------------------------------
	-- Functions
	-----------------------------------------------------------------------------
	function bin (myChar : character) return std_logic is
		variable bin : std_logic;
	begin
		case myChar is
			when '0' => bin := '0';
			when '1' => bin := '1';
			when 'x' => bin := '0';
			when others => 
                assert (false) 
                report "no binary character read" 
                severity failure;
		end case;
		return bin;
	end bin;

    
	function loadOperand (fileName : string) return Operand_array is 
		file objectFile : text open read_mode is fileName;
		variable memory : Operand_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
		while not endfile(objectFile) loop
			readline(objectFile, L);
			for i in 31 downto 0 loop
				read(L, myChar);
				memory(index)(i) := bin(myChar);
			end loop;
			index := index + 1;
		end loop;
		return memory;
	end loadOperand;


	function loadOpCode (fileName : string) return OpCode_array is
		file objectFile : text open read_mode is fileName;
		variable memory : OpCode_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
        while not endfile(objectFile) loop
            readline(objectFile, L);
            for i in 3 downto 0 loop
                read(L, myChar);
                memory(index)(i) := bin(myChar);
            end loop;
            index := index + 1;
		end loop;
        return memory;
    end loadOpCode;

    
    function to_string(sv: Std_Logic_Vector) return string is
        variable bv: bit_vector(sv'range) := to_bitvector(sv);
        variable lp: line;
    begin
        write(lp, bv);
        return lp.all;
    end to_string;
    
    -----------------------------------------------------------------------------
	-- Components
	-----------------------------------------------------------------------------
    COMPONENT ALU_RCA IS
        PORT( Clk  : IN  STD_LOGIC;                      -- System clock
              Reset: IN  STD_LOGIC;                      -- Reset
              A    : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- A input
              B    : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 ); -- B input
              Op   : IN  STD_LOGIC_VECTOR(  3 DOWNTO 0 ); -- Operation code
              
              Outs : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0));-- Output
    END COMPONENT ALU_RCA;
    
    
    
    -----------------------------------------------------------------------------
	-- Test bench signals/constants
	-----------------------------------------------------------------------------
    CONSTANT AMem : Operand_array := loadOperand(string'("A.tv"));
    CONSTANT BMem : Operand_array := loadOperand(string'("B.tv"));
    CONSTANT OpMem: OpCode_array := loadOpCode(string'("Op.tv"));
    CONSTANT ExpectOutMem: Operand_array := loadOperand(string'("ExpectOut.tv"));
    
    SIGNAL clk  : STD_LOGIC := '0';
    SIGNAL reset: STD_LOGIC := '0';
    SIGNAL A    : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL B    : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL Op   : STD_LOGIC_VECTOR(  3 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL Outs : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := (OTHERS => '0');
    
      
BEGIN
    
    -- Generate system clock
    clk <= NOT clk AFTER 20 ns;
    
    -- Bind the ALU component
    alu_comp : ALU_RCA PORT MAP( clk, reset, A, B, Op, Outs );
    
    -- Process for the test bench
    tb: PROCESS
        VARIABLE cnt : INTEGER RANGE 0 TO Size := 0;
        VARIABLE run : STD_LOGIC := '1';
    BEGIN
        -- Only run this process once
        IF run = '1' THEN
            run := '0';
            A <=  AMem(0);
            B <=  BMem(0);
            Op<= OpMem(0);
            
            -- Test reset first
            reset <= '0';
            WAIT UNTIL falling_edge(clk);
	    WAIT UNTIL rising_edge(clk);
            ASSERT Outs = (31 DOWNTO 0 => '0')
                REPORT "Error reset doesn't work"
                SEVERITY error;
            
            reset <= '1';
            
            -- Test the ALU against the test vectors
            FOR cnt IN 0 TO Size+2 LOOP
            
                WAIT UNTIL rising_edge(clk);
                
                -- Set new input and verify output
		    IF cnt < AMem'LENGTH THEN
                        A <=  AMem( cnt );
                        B <=  BMem( cnt );
                        Op<= OpMem( cnt ); 
		    END IF;
                    
                    -- Check outs 2 clock cycles later
                    IF cnt > 2 THEN
                        ASSERT Outs = ExpectOutMem(cnt-3)
                        REPORT "Error! Output value is not what expected." &
                                " A: "      & to_string(  AMem(cnt-3) ) &
                                " B: "      & to_string(  BMem(cnt-3) ) &
                                " Opcode: " & to_string( OpMem(cnt-3) ) &
                                " Expected outs: " & to_string( ExpectOutMem(cnt-3) ) &
                                " Outs: "   & to_string( Outs )
                        SEVERITY error;
                    END IF;

            END LOOP; -- cnt 0 to size

            ASSERT (false)
	    REPORT "Testbench finished"
	    SEVERITY note;
        END IF; -- run = '1'
    END PROCESS;
END ARCHITECTURE;
