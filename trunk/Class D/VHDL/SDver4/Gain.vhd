


library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gain is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk,reset :in std_logic; 
          output :out std_logic_vector(N-1 downto 0));
        end entity;
        
architecture arch_gain of gain is

begin
  process(clk,reset, input)
    begin
if clk'EVENT and clk='1' then
  if reset='1' then 
   output <=(others => '0');
  else
    output<='0' & input(N-1 downto 1);
  end if;
end if;
end process;
end architecture;
        