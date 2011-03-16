

library ieee;

use ieee.std_logic_1164.all;

entity sd is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk :in std_logic; 
         output,add1,add2,latch1 : out std_logic_vector(N-1 downto 0);
         sign: out std_logic);
end entity;

architecture arch_sd of sd is

component ripple_addsub is
  generic(n:integer:= 11);
  port ( a, b: in std_logic_vector(n downto 0);
          sat,sub : in std_logic;
          y : out std_logic_vector(n downto 0));
end component;
        
component latch is
    generic ( N : integer:= 12);
   port ( input :in std_logic_vector(N-1 downto 0); 
          clk :in std_logic; 
          output :out std_logic_vector(N-1 downto 0));

  end component;     
  
  signal addout1, addout2, feed : std_logic_vector(11 downto 0):="000000000000";
  signal latchout1, latchout2, latchin : std_logic_vector(11 downto 0):="000000000000";

begin
 
    A0: ripple_addsub port map(input, feed, '1', '1', addout1);
    A1: ripple_addsub port map(addout1, latchout1, '0', '0', addout2);
    L1: latch port map(latchin, clk, latchout1);
    --L1: latch port map(addout2, clk, latchout2);
    
    feed<="100000000000" WHEN latchout1(N-1)='1' ELSE
          "011111111111";
    latchin<=addout2 WHEN addout2(N-1)='0' OR addout2(N-1)='1' ELSE
             "000000000000";
    sign<='1' WHEN latchout1(N-1)='0' ELSE '0';
    
    
    process(clk, addout2)
      begin
        if clk'event and clk='1' then
        --sign<=latchout1(N-1);
        output<=addout2;
        add1<=addout1;
        add2<=addout2;
        latch1<=latchout1;
      end if;
    end process;
    
  end architecture;