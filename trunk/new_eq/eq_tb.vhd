-- Author: Alexey Sidelnikov, Mathias Lundell
-- Date: 2011-03-19

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity eq_tb is
    PORT( a_sig : OUT sample;
          b_sig : OUT sample;
          y_sig : OUT STD_LOGIC_VECTOR(12 DOWNTO 0));
end;

architecture eq_tb_arch of eq_tb is
  
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
        
    -- Convert std_logic_vector to string. Used for printing assertions
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
	
	COMPONENT regular_buffer IS
	GENERIC ( N        : NATURAL := 12;    -- Bit length of the vectors
			NUM_OF_TAPS : NATURAL := 220 );  -- Number of taps
    
    PORT (  clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            CE		     : IN STD_LOGIC;
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
            sample_out_1 : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            sample_out_2 : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
	END COMPONENT regular_buffer;
	
	COMPONENT serial_filter IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 37;
            NUM_OF_COEFFS : NATURAL := 110);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            CO      : IN coefficient_type;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            OE      : OUT STD_LOGIC;
            Q	    : OUT Multi_Result);
	END COMPONENT serial_filter;
    
    -----------------------------------------------------------------------------
	-- Test bench signals/constants
	-----------------------------------------------------------------------------
    CONSTANT AMem : sample_array := loadOperand(string'("a.tv"));
    CONSTANT BMem : sample_array := loadOperand(string'("b.tv"));
    CONSTANT YMem : result_array := loadResult(string'("y.tv"));
    
	-- Common signals
    SIGNAL clk          : STD_LOGIC := '0';
	SIGNAL CE		    : STD_LOGIC := '0';
	
	-- Signals for buffer
	SIGNAL reset_buff   : STD_LOGIC := '0';
    SIGNAL sample_in    : STD_LOGIC_VECTOR( num_bits-1 DOWNTO 0 ) : (OTHERS => '0');
    SIGNAL RE           : STD_LOGIC := '0';
    SIGNAL WE           : STD_LOGIC := '0';
    SIGNAL sample_out_1 : STD_LOGIC_VECTOR( num_bits-1 DOWNTO 0 ) : (OTHERS => '0');
    SIGNAL sample_out_2 : STD_LOGIC_VECTOR( num_bits-1 DOWNTO 0 ) : (OTHERS => '0');
	
	-- Signals for filter
	SIGNAL reset_filter : STD_LOGIC := '0';
    SIGNAL CO           : coefficient_type : (OTHERS => '0');
    SIGNAL OE           : STD_LOGIC := '0';
    SIGNAL Q	        : Multi_Result : (OTHERS => '0');
	
BEGIN
    
clk <= not clk after 10 ns;   

buff: COMPONENT regular_buffer PORT MAP(clk, reset_buff, sample_in, CE, RE, WE, sample_out_1, sample_out_2);
	
filter: COMPONENT serial_filter	PORT MAP(clk, reset_fiter, CO, CE, sample_out_1, sample_out_2, OE, Q);


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
