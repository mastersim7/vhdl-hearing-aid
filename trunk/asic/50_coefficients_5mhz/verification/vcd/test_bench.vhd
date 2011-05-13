
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;



entity tb is
end;

architecture tb_arch of tb is
  
    -----------------------------------------------------------------------------
    -- Declarations
    -----------------------------------------------------------------------------

    constant num_of_samples   : integer := 200;

       
    -----------------------------------------------------------------------------
    -- Functions
    -----------------------------------------------------------------------------

  
        
    
    -----------------------------------------------------------------------------
    -- Components
    -----------------------------------------------------------------------------
    component top_main IS 
    GENERIC (
         
            CLK_SCALE_20khz : NATURAL ;
            
            N : NATURAL := 12 ); -- Bit length of the data vectors
            
    PORT (
            -- Spartan3 ports
            clk     : IN  STD_LOGIC;                     -- FPGA master clock
            --led     : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );-- LEDs
            reset   : IN STD_LOGIC;
            sample_in    : IN  STD_LOGIC_VECTOR( 11 DOWNTO 0 );
            new_sample_ready : IN STD_LOGIC;
                     
	    sd_sign : OUT STD_LOGIC			
            );-- Latch DAC
         
 END component;

  type vals IS ARRAY (0 to num_of_samples) of std_logic_vector(11 downto 0); 

constant sin: vals := (
"111111111110",
"111111111101",
"111111111000",
"111111101101",
"111111011010",
"111110111101",
"111110010010",
"111101010110",
"111100000110",
"111010011111",
"111000011110",
"110110000001",
"110011000101",
"101111101010",
"101011110000",
"100111011001",
"100010101001",
"011101100101",
"011000010101",
"010011000101",
"001110000000",
"001001010111",
"000101011000",
"000010010100",
"000000011110",
"000000000010",
"000001001110",
"000100000111",
"001000101101",
"001110110111",
"010110010110",
"011110101101",
"100111011001",
"101111110000",
"110111000010",
"111100100001",
"111111100010",
"111111101000",
"111100100010",
"110110011000",
"101101100111",
"100011000101",
"010111111100",
"001101100110",
"000101011100",
"000000110000",
"000000011011",
"000100110001",
"001101011000",
"011001001000",
"100110001110",
"110010011110",
"111011101001",
"111111110110",
"111110000000",
"110110001101",
"101001101110",
"011010111111",
"001101000111",
"000011010011",
"000000000001",
"000100010111",
"001111100111",
"011111001100",
"101111001100",
"111011010010",
"111111111110",
"111011100100",
"101111000000",
"011101110000",
"001100111111",
"000010000100",
"000000110010",
"001001111101",
"011010110011",
"101101101010",
"111011110011",
"111111110011",
"110111110010",
"100110011101",
"010010010111",
"000011100111",
"000000100001",
"001010110001",
"011110010110",
"110010110101",
"111110111110",
"111100110110",
"101101000001",
"010110110000",
"000100110110",
"000000011110",
"001100010000",
"100010100000",
"110111100101",
"111111111110",
"110110101000",
"100000011001",
"001001101111",
"000000000000",
"001001011000",
"100000100111",
"110111101001",
"111111110111",
"110011101000",
"011010011011",
"000100110001",
"000001011011",
"010011001001",
"101101111111",
"111111000010",
"111001101011",
"100001010110",
"000111110111",
"000000100100",
"010001100001",
"101101111011",
"111111011001",
"110111100001",
"011100010000",
"000011111101",
"000011010001",
"011011010001",
"110111100000",
"111111000101",
"101010110001",
"001100100010",
"000000001000",
"010001100000",
"110000101110",
"111111111110",
"110000000101",
"010000001100",
"000000000000",
"010000001111",
"110000110000",
"111111111011",
"101101011011",
"001100011110",
"000000100010",
"010111000100",
"110111100110",
"111101101100",
"100001111111",
"000011111000",
"000110011100",
"100111001011",
"111111011011",
"110001110001",
"001110010101",
"000000100111",
"011010000111",
"111011001000",
"111001100000",
"010110110111",
"000000000100",
"010011011011",
"110111101001",
"111011111110",
"011010000100",
"000000010000",
"010010101010",
"110111111010",
"111011001010",
"010111010011",
"000000000000",
"010111101010",
"111011101110",
"110110010010",
"001111000101",
"000001101001",
"100011000001",
"111111101110",
"101010100010",
"000100100011",
"001010100000",
"110011001111",
"111100100101",
"010110110010",
"000000010000",
"011110111111",
"111111011100",
"101010001010",
"000011010100",
"001110010100",
"111000010110",
"110111010011",
"001100101000",
"000100110010",
"101110010110",
"111101101000",
"010110001011",
"000000111110",
"100101111111",
"111111101010",
"011100111010",
"000000000100",
"100001000110",
"111111111110",
"011111110111",
"000000000000"

); 
    


    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL clk_20kHz    : STD_LOGIC := '0';

    SIGNAL sample_sig : STD_LOGIC_VECTOR( 11 DOWNTO 0 );
    SIGNAL i : natural := 0;
    SIGNAL k : natural := 0;
    SIGNAL reset : STD_LOGIC := '0';
    
    signal sd_out :STD_LOGIC ;
BEGIN
    
    clk <= not clk after 25 ns; -- 50 MHz clock

    -- Bind component eq_main
    top_main_comp :component top_main
        generic map(CLK_SCALE_20khz => 1000 ) 
        port map(
                clk              => clk,
                reset            => reset,
                sample_in        => sample_sig,
                new_sample_ready => clk_20kHz,
               	sd_sign          => sd_out
                );
                      



                        
    clk_20kHz_generation: process( clk ) is
        constant END_VALUE : natural := 1000;
        variable count : natural range 0 to END_VALUE := 0;
    begin
      if k< 1000 then
        if i < (num_of_samples+1) then
            if clk'event and clk = '1' then
                if count < END_VALUE then
                    count := count + 1;
                    clk_20kHz <= '0';
                else
                    count := 0;
                    clk_20kHz <= '1';
                    sample_sig <= sin(i);
                    i <= i + 1;
                    k<=k+1; 
                end if;
            end if;
        else
             i<=0;
        end if;
     else
      assert false
             report "Test bench finished"
             severity failure;
         end if;
    end process;
    
   
 end architecture;
