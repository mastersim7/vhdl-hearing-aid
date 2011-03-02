

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity comp is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk,reset :in std_logic; 
          output :out std_logic);
        end entity;
        
architecture arch_comp of comp is
begin
  process(clk,reset, input)
    begin
if clk'EVENT and clk='1' then
  if reset='1' then 
   output <='0';
  else
    if input>"10000000000" then
      output<='0';
    else
      output<='1';
      end if;
  end if;
end if;
end process;
end architecture;
        