
library ieee;

use ieee.std_logic_1164.all;

entity latch is
  generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk :in std_logic; 
         output :out std_logic_vector(N-1 downto 0));

        end entity;

architecture arch_latch of latch is
begin
  process(clk, input)
    begin
    if clk'event and clk='1' then
      output<=input;
    end if;
  end process;
end architecture;