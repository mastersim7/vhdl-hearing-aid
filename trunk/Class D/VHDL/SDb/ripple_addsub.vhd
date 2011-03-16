
--Robin Andersson
Library ieee;

use ieee.std_logic_1164.all;

entity ripple_addsub is
  generic(n:integer:= 11);
  port ( a, b: in std_logic_vector(n downto 0);
          sat,sub : in std_logic;
          y : out std_logic_vector(n downto 0));
end ripple_addsub;

----------------------Architecture---------------------
architecture arch_ripple_addsub of ripple_addsub is
signal c_sig: std_logic_vector(n downto 0):=(others => '0');
signal cout, v:std_logic;
signal y_sig: std_logic_vector(n downto 0):=(others => '0');
signal b_sig: std_logic_vector(n downto 0):=(others => '0');
-----------------Define components----------
component full_adder
  port ( a, b: in std_logic;
          cin: in std_logic;
          y : out std_logic;
          cout: out std_logic);
end component full_adder;
        
component invert_b
  generic(n :integer:=11);
  port ( en: in std_logic;
          b_in: in std_logic_vector(n downto 0);
          b_out: out std_logic_vector(n downto 0));
end component invert_b;


-------------------------------------------
begin
-----------------------------Components--------
 b0:component invert_b
 port map(en => sub, b_in=> b, b_out => b_sig);
   
 m0: component full_adder
 port map(a => a(0), b => b_sig(0), cin => sub, y=>y_sig(0),cout=>c_sig(0));
       
 G: for i in 1 to n-1 generate
 mi:component full_adder
 port map(a => a(i), b => b_sig(i), cin => c_sig(i-1), y=>y_sig(i),cout=>c_sig(i));
 end generate;
        
 mn: component full_adder
 port map(a => a(n), b => b_sig(n), cin => c_sig(n-1), y=>y_sig(n),cout=>cout);
   
 ----------------------------overflow--------
 process(cout, y_sig, sat)
   begin
     if (cout /= c_sig(n-1)) then
       if sat='0' then
         y<=y_sig;
       else
        if y_sig(n)='1' then
          y<=(others => '1');
          y(n)<='0';
       else 
          y<=(others => '0');
          y(n)<='1';
       end if;
      end if;
    else
      y<=y_sig; 
    end if;


  end process;
end arch_ripple_addsub;

