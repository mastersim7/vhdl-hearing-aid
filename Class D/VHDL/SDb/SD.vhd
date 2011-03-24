

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
  generic(N:integer:= 12);
  port ( a, b: in std_logic_vector(N-1 downto 0);
          sat,sub : in std_logic;
          y : out std_logic_vector(N-1 downto 0));
end component;
        
component latch is
    generic ( N : integer:= 12);
   port ( input :in std_logic_vector(N-1 downto 0); 
          clk :in std_logic; 
          output :out std_logic_vector(N-1 downto 0));

  end component;     
  
  signal ins,addout1, addout2, feed : std_logic_vector(N-1 downto 0):=(others =>'0');
  signal latchout1, latchout2, latchin : std_logic_vector(N-1 downto 0):=(others =>'0');

begin
    ins<=input(N-1) & input(N-1 downto 1);
    A0: ripple_addsub generic map (n=>N) port map(input, feed, '1', '1', addout1);
    A1: ripple_addsub generic map (n=>N) port map(addout1, latchout1, '0', '0', addout2);
    L1: latch generic map (N=>N) port map(latchin, clk, latchout1);
        
    feed <=('1' & (N-2 downto 0 =>'0')) WHEN latchout1(N-1)='1' ELSE
           ('0' & (N-2 downto 0 =>'1'));
    latchin<=addout2 WHEN addout2(N-1)='0' OR addout2(N-1)='1' ELSE
             (others => '0');
    sign<='1' WHEN latchout1(N-1)='0' ELSE '0';
    
    
        output<=addout2;
        add1<=addout1;
        add2<=addout2;
        latch1<=latchout1;
    
  end architecture;