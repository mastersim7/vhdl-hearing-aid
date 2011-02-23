library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity subtr is
  port ( a,b :in std_logic_vector(11 downto 0); 
         clk,reset :in std_logic; 
         output :out std_logic_vector(11 downto 0);
         sign :out std_logic);
        end entity;
        
architecture arch_subtr of subtr is
signal sig : std_logic_vector(11 downto 0);
begin
  process(clk,reset,a,b)
    begin
if clk'EVENT and clk='1' then
  if reset='1' then 
    sig<=(others => '0');
  else
    sig<=a-b;
  end if;
end if;
end process;
output<=sig;
sign<=sig(11);
end architecture;
