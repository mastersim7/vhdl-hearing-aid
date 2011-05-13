

Library ieee;

use ieee.std_logic_1164.all;

entity full_adder is
  port ( a, b: in std_logic;
          cin: in std_logic;
          y : out std_logic;
          cout: out std_logic);
end full_adder;

architecture arch_full_adder of full_adder is
begin
      
        y<=a xor b xor cin ;
        cout<= (a and b) or (cin and (a xor b));
end arch_full_adder;