-- Author: Alexey Sidelnikov, Mathias Lundell
-- Date: 2011-03-31

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

entity eq_main_tb is
end;

architecture eq_main_tb_arch of eq_main_tb is
  
    -----------------------------------------------------------------------------
    -- Declarations
    -----------------------------------------------------------------------------

    constant Size   : integer := 80;
    constant num_bits_sample : natural := 12;
    constant num_bits_result : natural := 37;
    
    type sample_array is array (Size-1 downto 0) of sample;
    type result_array is array (Size-1 downto 0) of Multi_Result;
    
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
            for i in num_bits_sample-1 downto 0 loop
                read(L, myChar);
                memory(index)(i) := bin(myChar);
            end loop;
            index := index + 1;
        end loop;
        return memory;
    end loadSample;
    
    -- Load sample
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
    -----------------------------------------------------------------------------
    -- Components
    -----------------------------------------------------------------------------
    COMPONENT eq_main IS
    GENERIC(
            NUM_OF_SAMPLES: NATURAL := 80;
            NUM_OF_COEFFS : NATURAL := 40;
            NUM_OF_BANDS  : NATURAL := 8);
    PORT( 
            clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  sample;
            new_sample_ready : IN STD_LOGIC;
            OE : OUT STD_LOGIC;
            Q : OUT Multi_result_array);-- interface will take this 
    END COMPONENT;

    -----------------------------------------------------------------------------
    -- Test bench signals/constants
    -----------------------------------------------------------------------------
    CONSTANT sampleMEM : sample_array := loadSample(string'("samples.tv"));
    CONSTANT resultMEM0 : result_array := loadResult(string'("pre_output_mac_1.tv"));
    CONSTANT resultMEM1 : result_array := loadResult(string'("pre_output_mac_2.tv"));
    CONSTANT resultMEM2 : result_array := loadResult(string'("pre_output_mac_3.tv"));
    CONSTANT resultMEM3 : result_array := loadResult(string'("pre_output_mac_4.tv"));
    CONSTANT resultMEM4 : result_array := loadResult(string'("pre_output_mac_5.tv"));
    CONSTANT resultMEM5 : result_array := loadResult(string'("pre_output_mac_6.tv"));
    CONSTANT resultMEM6 : result_array := loadResult(string'("pre_output_mac_7.tv"));
    CONSTANT resultMEM7 : result_array := loadResult(string'("pre_output_mac_8.tv"));
    


    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL clk_20kHz    : STD_LOGIC := '0';

    SIGNAL sample_sig : sample;
    SIGNAL eq_Q : Multi_result_array;
    SIGNAL eq_OE : STD_LOGIC := '0';
    SIGNAL i : natural := 0;
    SIGNAL reset : STD_LOGIC := '0';
BEGIN
    
    clk <= not clk after 10 ns; -- 50 MHz clock

    -- Bind component eq_main
    eq_main_comp : eq_main
        port map(
                clk              => clk,
                reset            => reset,
                sample_in        => sample_sig,
                new_sample_ready => clk_20kHz,
                OE               => eq_OE,
                Q                => eq_Q);
                        
                        
    clk_20kHz_generation: process( clk ) is
        constant END_VALUE : natural := 2500;
        variable count : natural range 0 to END_VALUE := 0;
    begin
        if i < Size then
            if clk'event and clk = '1' then
                if count < END_VALUE then
                    count := count + 1;
                    clk_20kHz <= '0';
                else
                    count := 0;
                    clk_20kHz <= '1';
                    sample_sig <= sampleMEM(i);
                    i <= i + 1;
                end if;
            end if;
        else
            assert false
                report "Test bench finished"
                severity failure;
        end if;
    end process;
    
    tb: process( clk )
        variable resetted : std_logic := '0';
        variable q : Multi_Result_array;
    begin
        if clk'event and clk = '1' then
            if resetted = '0' then
                reset <= '1';
                resetted := '1';
            else
                reset <= '0';
            end if;
            
            if eq_OE = '1' then
                -- Check first filter
                assert resultMEM0(i-1) = eq_Q(0)
                    report "Error, output doesn't match expected from resultMEM0." &
                            " Sample in:" & to_string(sampleMEM(i-1)) &
                            " Expected output:" & to_string(resultMEM0(i-1)) &
                            " Output:" & to_string(eq_Q(0))
                    severity error;
            end if;
        end if;
    end process;

 end architecture;
