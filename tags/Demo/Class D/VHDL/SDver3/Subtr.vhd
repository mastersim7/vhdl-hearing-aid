library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity subtr is
    generic ( N : integer:= 12);
  port ( a,b :in std_logic_vector(N-1 downto 0); 
         clk,reset :in std_logic; 
         output :out std_logic_vector(N-1 downto 0));
        end entity;
        
architecture arch_subtr of subtr is
signal sig : std_logic_vector(N-1 downto 0);
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
end architecture;
