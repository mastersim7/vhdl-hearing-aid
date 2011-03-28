library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_Std.all;

entity SD_tb is
    port ( out_sign : out std_logic );
end;

architecture behav_SD_tb of SD_tb is
    component SD
    port (  input :in std_logic_vector(11 downto 0); 
            clk,reset :in std_logic; 
            output : out std_logic_vector(11 downto 0);
            sign: out std_logic);  
    end component;
    
    signal input : std_logic_vector(11 downto 0); 
    signal clk,reset : std_logic := '0'; 
    signal output : std_logic_vector(11 downto 0);
    signal sign : std_logic;
begin
    clk <= not clk after 10 ns;
    
    sd_comp : SD port map( input,clk,reset,output,sign );
    out_sign <= sign;
    
    tb: process
    begin
        input <= "000000000000";
        reset <= '0';
        wait for 40 ns;
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for 40 ns;
        input <= "000000100000";
        wait for 40 ns;
        input <= "100000000001";
        wait for 40 ns;
        input <= "000000100001";
        wait for 40 ns;
        input <= "000110000001";
        wait for 40 ns;
    end process;

 end architecture;
