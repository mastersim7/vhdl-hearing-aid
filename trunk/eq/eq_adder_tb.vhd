-- eq_adder_tb.vhd
-- Author:
-- Date:
-- Description:
-- Function used together with the symmetrical filters to add together the newest and
-- oldest sample before multiplication with common coefficient.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity eq_adder_tb is
    PORT( a_sig : OUT sample;
          b_sig : OUT sample;
          y_sig : OUT STD_LOGIC_VECTOR(12 DOWNTO 0));
end;

architecture eq_adder_tb_arch of eq_adder_tb is
    
    -----------------------------------------------------------------------------
	-- Declarations
	-----------------------------------------------------------------------------
    constant Size   : integer := 1000;
    constant num_bits : natural := 12;
    constant num_bits_result : natural := 13;
    
    type sample_array is array (Size-1 downto 0) of sample;
    type result_array is array (Size-1 downto 0) of STD_LOGIC_VECTOR(12 DOWNTO 0);
    
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
    function loadOperand (fileName : string) return sample_array is 
		file objectFile : text open read_mode is fileName;
		variable memory : sample_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
		while not endfile(objectFile) loop
			readline(objectFile, L);
			for i in num_bits-1 downto 0 loop
				read(L, myChar);
				memory(index)(i) := bin(myChar);
			end loop;
			index := index + 1;
		end loop;
		return memory;
	end loadOperand;
    
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
			for i in num_bits_result-1 downto 0 loop
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
    CONSTANT AMem : sample_array := loadOperand(string'("a.tv"));
    CONSTANT BMem : sample_array := loadOperand(string'("b.tv"));
    CONSTANT YMem : result_array := loadResult(string'("y.tv"));
    
    SIGNAL clk   : STD_LOGIC := '0';
begin
    clk <= not clk after 10 ns;
    
    tb: process( clk )
        variable a : sample := (others => '0');
        variable b : sample := (others => '0');
        variable y : std_logic_vector(12 downto 0) := (others => '0');
        variable count : natural range 0 to Size := 0;
    begin
        if clk'event and clk = '1' then
            if count < Size then
                a := AMem(count);
                b := BMem(count);
                y := eq_adder(a,b);
                
                assert y = YMem(count)
                    report  "Error in function eq_adder. Output is not what expected." &
                            " A: " & to_string(a) &
                            " B: " & to_string(b) &
                            " Y: " & to_string(y) &
                            " Expected y: " & to_string(YMem(count))
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
