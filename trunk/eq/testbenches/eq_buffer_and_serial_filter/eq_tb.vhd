-- Author: Alexey Sidelnikov, Mathias Lundell
-- Date: 2011-03-19

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;
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
	
	constant Size            : integer := 220;
    constant num_bits        : natural := 12;
	constant num_bits_result : natural := 37;
	constant num_bits_coeff  : natural := 24;
    
    type sample_array is array (Size-1 downto 0) of sample;
    type result_array is array (Size-1 downto 0) of sample;
	type coeff_array  is array (Size/2 downto 0) of STD_LOGIC_VECTOR(num_bits_coeff DOWNTO 0);
    
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
                report "No binary character read!" 
                severity failure;
		end case;
		return bin;
	end bin;
    
    -- Load sample
    function loadSample (fileName : string) return sample_array is 
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
	
	    -- Load coefficient
    function loadCoefficient (fileName : string) return coeff_array is 
		file objectFile : text open read_mode is fileName;
		variable memory : coeff_array;
		variable L      : line;
		variable index  : natural := 0;
		variable myChar : character;
	begin
		while not endfile(objectFile) loop
			readline(objectFile, L);
			for i in num_bits_coeff-1 downto 0 loop
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
			for i in num_bits-1 downto 0 loop
				read(L, myChar);
				memory(index)(i) := bin(myChar);
			end loop;
			index := index + 1;
		end loop;
		return memory;
	end loadResult;
    
    -- Convert std_logic_vector to string. Used for printing assertions
    function to_string (sv: Std_Logic_Vector) return string is
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
	GENERIC (N           : NATURAL := 12;
			 NUM_OF_TAPS : NATURAL := 220 );
    
    PORT (  clk          : IN  STD_LOGIC;
            reset        : IN  STD_LOGIC;
            sample_in    : IN  sample;
            CE		     : IN  STD_LOGIC;
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
			UPDATED      : OUT STD_LOGIC;
            sample_out_1 : OUT sample;
            sample_out_2 : OUT sample);
	END COMPONENT regular_buffer;
	
	COMPONENT serial_filter IS
    GENERIC(NUM_BITS_OUT  : NATURAL := 37;
            NUM_OF_COEFFS : NATURAL := 110);
    PORT(   clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            CO      : IN coefficient_type;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
			updated : IN STD_LOGIC;
            OE      : OUT STD_LOGIC;
            Q	    : OUT Multi_Result);
	END COMPONENT serial_filter;
    
    -----------------------------------------------------------------------------
	-- Test bench signals/constants
	-----------------------------------------------------------------------------
    CONSTANT SMem : sample_array := loadSample(string'("samples.tv"));
    CONSTANT CMem : sample_array := loadCoefficient(string'("coeff.tv"));
    CONSTANT RMem : result_array := loadResult(string'("output_37.tv"));
    
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
	SIGNAL updated      : STD_LOGIC := '0';
    SIGNAL Q	        : Multi_Result : (OTHERS => '0');
	
BEGIN
    
clk <= not clk after 10 ns;   

buff: COMPONENT regular_buffer PORT MAP(clk, reset_buff, sample_in, CE, RE, WE, updated, sample_out_1, sample_out_2);
	
filter: COMPONENT serial_filter	PORT MAP(clk, reset_fiter, CO, CE, sample_out_1, sample_out_2, updated, OE, Q);


    tb: process( clk )
        variable sam_in_var  : sample                        := (others => '0');
        variable coef_in_var : std_logic_vector(23 downto 0) := (others => '0');
		variable sam_out_var : std_logic_vector(36 downto 0) := (others => '0');
        variable count : natural range 0 to Size := 0;
    BEGIN
        IF clk'event and clk = '1' THEN
			
			-- Test reset_buffer first
			reset_buff <= '1';
			WAIT UNTIL falling_edge(clk);
			WAIT UNTIL rising_edge(clk);
			ASSERT ((sample_out_1 = (12 DOWNTO 0 => '0')) AND (sample_out_2 = (12 DOWNTO 0 => '0')))
			REPORT "Error reset buffer doesn't work"
			SEVERITY error;
			reset_buff <= '0';
			
			-- Test reset_buffer first
			reset_filter <= '1';
			WAIT UNTIL falling_edge(clk);
			WAIT UNTIL rising_edge(clk);
			ASSERT Q = (36 DOWNTO 0 => '0')
			REPORT "Error reset filter doesn't work"
			SEVERITY error;
			reset_filter <= '0';
			
			 -- Test the system against the test vectors
			FOR count IN 0 TO Size LOOP
		
				WAIT UNTIL rising_edge(clk);
			
				-- Set new input and verify output
				IF count < Size THEN
					sam_in_var   <= SMem( count );
					coeff_in_var <= CMem( count );
					sam_out_var  <= RMem( count ); 
				END IF;
				
				ASSERT Q = RMem(count)
				REPORT "Error! Output value is not what expected."
				SEVERITY error;

			END LOOP;
                                   
        ELSE
                ASSERT false
                REPORT "Test bench finished"
                SEVERITY note;
        END IF;
    END PROCESS;

 END ARCHITECTURE;
