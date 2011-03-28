
Library ieee;

use ieee.std_logic_1164.all;

entity invert_b is
  generic(n :integer:=11);
  port (  en: in std_logic;
          b_in: in std_logic_vector(n downto 0);
          b_out:out std_logic_vector(n downto 0));
end invert_b;

architecture arch_invert_b of invert_b is
begin
  process(b_in, en)
    begin
      if en='1' then
        b_out<= not b_in;
      else
        b_out<= b_in;  
      end if;
    end process;
end arch_invert_b;

