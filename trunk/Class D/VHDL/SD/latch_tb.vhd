library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_Std.all;

entity latch_tb is
end;

architecture behav_latch_tb of latch_tb is
    component latch
    port (  input :in std_logic_vector(11 downto 0); 
            clk :in std_logic; 
            output :out std_logic_vector(11 downto 0));   
    end component;
    
    signal input : std_logic_vector(11 downto 0); 
    signal clk : std_logic := '0'; 
    signal output : std_logic_vector(11 downto 0); 
begin
    clk <= not clk after 10 ns;
    
    lat : latch port map( input,clk,output );
    
    tb: process
    begin
        input <= "000000000000";
        wait for 40 ns;
        input <= "100000000001";
        wait for 40 ns;
        input <= "000000100001";
        wait for 40 ns;
        input <= "000110000001";
        wait for 40 ns;
    end process;

 end architecture;
