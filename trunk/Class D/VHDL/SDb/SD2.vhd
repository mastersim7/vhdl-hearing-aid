

library ieee;

use ieee.std_logic_1164.all;

entity sd2 is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk :in std_logic; 
         output,add1,add2,latch1 : out std_logic_vector(N-1 downto 0);
         sign: out std_logic);
end entity;

architecture arch_sd2 of sd2 is

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
  
  
  signal addout1, addout2, addout3, addout4, feed : std_logic_vector(N-1 downto 0):="000000000000";
  signal latchout1, latchout2, latchin1, latchin2 : std_logic_vector(N-1 downto 0):="000000000000";
  signal gain1, gain2 : std_logic_vector(N-1 downto 0):="000000000000";
  
begin

    A0: ripple_addsub port map(input, feed, '1', '1', addout1);
    gain1<=addout1(N-1) & addout1(N-1 downto 1);
    A1: ripple_addsub port map(gain1, latchout1, '1', '0', addout2);
    L1: latch port map(latchin1, clk, latchout1);
    
    A2: ripple_addsub port map(latchout1, feed, '1', '1', addout3);
    gain2<=addout3(N-1) & addout3(N-1 downto 1);
    A3: ripple_addsub port map(gain2, latchout2, '1', '0', addout4);
    L2: latch port map(latchin2, clk, latchout2);
    
    feed <=('1' & (N-2 downto 0 =>'0')) WHEN latchout2(N-1)='1' ELSE
           ('0' & (N-2 downto 0 =>'1'));
    latchin1<=addout2 WHEN addout2(N-1)='0' OR addout2(N-1)='1' ELSE
             "000000000000";
    latchin2<=addout4 WHEN addout4(N-1)='0' OR addout4(N-1)='1' ELSE
             "000000000000";         
    sign<='1' WHEN latchout2(N-1)='0' ELSE '0';
    
        output<=addout4;
        add1<=gain1;
        add2<=gain2;
        latch1<=feed;

  end architecture;
