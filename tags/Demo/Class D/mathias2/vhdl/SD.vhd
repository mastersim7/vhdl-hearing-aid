

library ieee;

use ieee.std_logic_1164.all;

entity sd is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk,reset :in std_logic; 
         output : out std_logic_vector(N-1 downto 0);
         sign: out std_logic);
end entity;

architecture arch_sd of sd is

component adder is
generic ( N : integer:= 12);  
port ( a,b :in std_logic_vector(N-1 downto 0); 
        clk,reset :in std_logic; 
          output :out std_logic_vector(N-1 downto 0));
        end component;
        
component latch is
    generic ( N : integer:= 12);
   port ( input :in std_logic_vector(N-1 downto 0); 
          clk :in std_logic; 
          output :out std_logic_vector(N-1 downto 0));

  end component;     
  
  component subtr is
  generic ( N : integer:= 12);
  port ( a,b :in std_logic_vector(N-1 downto 0); 
         clk,reset :in std_logic; 
         output :out std_logic_vector(N-1 downto 0));
  end component;
  
  component comp is
  generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk,reset :in std_logic; 
          output :out std_logic);
  end component;
  
  signal addout1, addout2, latchout1, latchout2,feed : std_logic_vector(11 downto 0):=("000000000000");
  signal sign1 : std_logic:='0'; 
  
begin
 
    
    A0: subtr port map(input, feed, clk, reset, addout1);
    A1: adder port map(addout1, addout2, clk, reset, addout2);
    --L0: latch port map(addout2, clk, latchout1);
    --L1: latch port map(addout2, clk, latchout2);
    --C0: comp port map(addout2, clk, reset, sign1);
    
    feed<="011111111111" WHEN addout2(N-1)='0' ELSE
          "100000000000";
    
    process(clk, sign1, addout2)
      begin
        if clk'event and clk='1' then
        sign<= addout2(N-1);
        output<=addout2;
        --if sign1='1' then
--          feed<="111111111111";
--        else
--          feed<="000000000000";
--        end if;
      end if;
    end process;
    
  end architecture;