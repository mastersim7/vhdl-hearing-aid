-- eq_multiply_tb.vhd
-- Author: Mathias Lundell
-- Date: 2011-03-16
-- Description:
-- Tests function for multiplying two added together samples with
-- a coefficient. The added together samples are a 13 bit std_logic_vector
-- and the result is 24+13 bits long.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity eq_multiply_tb is
    PORT( a_sig : OUT STD_LOGIC_VECTOR(13-1 DOWNTO 0);
          b_sig : OUT coefficient_type;
          y_sig : OUT STD_LOGIC_VECTOR(37-1 DOWNTO 0));
end;

architecture eq_multiply_tb_arch of eq_multiply_tb is
    
    -----------------------------------------------------------------------------
	-- Declarations
	-----------------------------------------------------------------------------
    constant Size   : integer := 1000;
    constant A_N : natural := 13;
    constant C_N : natural := coefficient_type'LENGTH;
    
    type a_array is array (Size-1 downto 0) of STD_LOGIC_VECTOR(A_N-1 DOWNTO 0);
    type coefficient_array is array (Size-1 downto 0) of coefficient_type;
    type result_array is array (Size-1 downto 0) of STD_LOGIC_VECTOR(A_N+C_N-1 DOWNTO 0);
    
    -----------------------------------------------------------------------------
	-- Functions
	-----------------------------------------------------------------------------
    -- Convert character to std_logic
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
    
    -- Load an operand
    function loadOperand (fileName : string) return a_array is 
		file objectFile : text open read_mode is fileName;
		variable memory : a_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
		while not endfile(objectFile) loop
			readline(objectFile, L);
			for i in A_N-1 downto 0 loop
				read(L, myChar);
				memory(index)(i) := bin(myChar);
			end loop;
			index := index + 1;
		end loop;
		return memory;
	end loadOperand;
    
    -- Load a coefficient
    function loadCoefficient (fileName : string) return coefficient_array is 
		file objectFile : text open read_mode is fileName;
		variable memory : coefficient_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
		while not endfile(objectFile) loop
			readline(objectFile, L);
			for i in C_N-1 downto 0 loop
				read(L, myChar);
				memory(index)(i) := bin(myChar);
			end loop;
			index := index + 1;
		end loop;
		return memory;
	end loadCoefficient;
    
    -- Load result
    function loadResult (fileName : string) return result_array is 
		file objectFile : text open read_mode is fileName;
		variable memory : result_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
		while not endfile(objectFile) loop
			readline(objectFile, L);
			for i in A_N+C_N-1 downto 0 loop
				read(L, myChar);
				memory(index)(i) := bin(myChar);
			end loop;
			index := index + 1;
		end loop;
		return memory;
	end loadResult;
    
    -- Convert std_logic_vector to string. Used for printing assertions
    function to_string(sv: Std_Logic_Vector) return string is
        variable bv: bit_vector(sv'range) := to_bitvector(sv);
        variable lp: line;
    begin
        write(lp, bv);
        return lp.all;
    end to_string;
    
    -----------------------------------------------------------------------------
	-- Test bench signals/constants
	-----------------------------------------------------------------------------
    CONSTANT AMem : a_array := loadOperand(string'("a.tv"));
    CONSTANT BMem : coefficient_array := loadCoefficient(string'("coefficient.tv"));
    CONSTANT YMem : result_array := loadResult(string'("result.tv"));
    
    SIGNAL clk   : STD_LOGIC := '0';
begin
    clk <= not clk after 10 ns;
    
    tb: process( clk )
        variable a : STD_LOGIC_VECTOR(A_N-1 DOWNTO 0) := (others => '0');
        variable b : coefficient_type := (others => '0');
        variable y : std_logic_vector(A_N+C_N-1 downto 0) := (others => '0');
        variable count : natural range 0 to Size := 0;
    begin
        if clk'event and clk = '1' then
            if count < Size then
                a := AMem(count);
                b := BMem(count);
                y := eq_multiply(a,b);
                
                assert y = YMem(count)
                    report  "Error in function eq_multiply. Output is not what expected." &
                            " A: " & to_string(a) &
                            " Coefficient: " & to_string(b) &
                            " Result: " & to_string(y) &
                            " Expected result: " & to_string(YMem(count))
                    severity error;
                    
                a_sig <= a;
                b_sig <= b;
                y_sig <= y;
                
                count := count + 1;
            else
                assert false
                    report "Test bench finished"
                    severity note;
            end if;
        end if;
    end process;

 end architecture;
