

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity sd is
  port ( input :in std_logic_vector(11 downto 0); 
         clk,reset :in std_logic; 
         output : out std_logic_vector(11 downto 0);
         sign: out std_logic);
end entity;

architecture arch_sd of sd is

component adder is
port ( a,b :in std_logic_vector(11 downto 0); 
        clk,reset :in std_logic; 
          output :out std_logic_vector(11 downto 0);
          sign :out std_logic);
        end component;
        
component latch is
   port ( input :in std_logic_vector(11 downto 0); 
          clk :in std_logic; 
          output :out std_logic_vector(11 downto 0));

  end component;     
  
  component subtr is
  port ( a,b :in std_logic_vector(11 downto 0); 
         clk,reset :in std_logic; 
         output :out std_logic_vector(11 downto 0);
         sign :out std_logic);
  end component;
  
  signal addout1, addout2, latchout1, latchout2 : std_logic_vector(11 downto 0):=("000000000000");
  signal sign1, sign2 : std_logic:='0'; 
  
begin

    
    A0: subtr port map(input, latchout2, clk, reset, addout1, sign1);
    A1: adder port map(addout1, latchout1, clk, reset, addout2, sign2);
    L0: latch port map(addout2, clk, latchout1);
    L1: latch port map(addout2, clk, latchout2);
    
    process(clk, sign2, addout2)
      begin
        if clk'event and clk='1' then
        sign<= sign2;
        output<=addout2;
      end if;
    end process;
    
  end architecture;