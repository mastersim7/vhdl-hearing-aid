library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_Std.all;

entity adder_tb is
  port( out_sign : out std_logic );
end;

architecture bench of adder_tb is
    component adder
    port (  a,b : in std_logic_vector(11 downto 0);
            clk,reset :in std_logic; 
            output :out std_logic_vector(11 downto 0);
            sign : out std_logic);
    end component;
    
    signal a,b : std_logic_vector(11 downto 0);
    signal clk,reset : std_logic := '0'; 
    signal output : std_logic_vector(11 downto 0);
    signal sign : std_logic;
begin
    clk <= not clk after 10 ns;
    
    add : adder port map( a,b,clk,reset,output,sign );
    
    tb: process
    begin
        reset <= '0';
        wait for 40 ns;
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for 40 ns;
        a <= "000000000011";
        b <= "000000000100";
        wait for 40 ns;
        a <= "000010000011";
        b <= "010000000100";
        wait for 40 ns;
        a <= "100000000011";
        b <= "100000000100";
        wait for 40 ns;
        a <= "111111111111";
        b <= "111111111111";
        wait for 40 ns;
        a <= "000000000000";
        b <= "000000000000";
        wait for 40 ns;
        a <= "100000000000";
        b <= "100000000000";
    end process;
    
    out_sign <= sign;
 end architecture;