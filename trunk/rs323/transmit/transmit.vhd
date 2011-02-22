---------------------------------------------------------------- 
-- Design Name: Transmit from FPGA to PC
------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity transmit_4_2 is
GENERIC(n:INTEGER:=20);--initially sending 2 bytes
   PORT( system_clk : in STD_LOGIC;
         y: OUT STD_LOGIC
  );

end transmit_4_2;

architecture Behavioral of transmit_4_2 is
 
 signal transmit: STD_LOGIC_VECTOR(n-1 DOWNTO 0):="10100000101010000100"; -- as an example sending B A, start stop bits for each bye and its respective ASCII values 
 signal j:INTEGER RANGE 0 TO n; 
 signal i:INTEGER RANGE 0 TO 5208;

begin
process(system_clk) 

begin

if(rising_edge(system_clk)) then

          y <= transmit(j);
          i <= i+1;
         
          if(i=5207)then -- this clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
          i <= 0;
            if(j < n )then 
             
              j <= j+1;
          
                    if ( j = n-1 ) then
                   j <= 0; -- to send continuasly
                 END IF;
            END IF;
         END IF;
END IF;
END PROCESS;
end Behavioral;  

   
