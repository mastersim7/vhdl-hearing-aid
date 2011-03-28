----------------------------------------------------------------------------------
-- Design Name: Receive Datas from PC to FPGA
-- Module Name:    receive10_2 - Behavioral 
 ----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity receive10_2 is
GENERIC(n:INTEGER:=10); --receiving 10 bits start+8 bits of data+stop
   PORT( system_clk : in STD_LOGIC;
         x: in STD_LOGIC;
			receive_out:  out STD_LOGIC_VECTOR(n-3 DOWNTO 0)
  );
end receive10_2;

architecture Behavioral of receive10_2 is
 signal receive: STD_LOGIC_VECTOR(n-1 DOWNTO 0); 
 signal j:INTEGER RANGE 0 TO n; 
 signal i:INTEGER RANGE 0 TO 5210;
 signal startbit:STD_LOGIC;
  
begin

 startbit <= x; --receive bits from PC continuasly, x is mapped with receive pin of RS232 using UCF file

process(system_clk)
 
 variable enable:STD_LOGIC;
 variable initialize:STD_LOGIC;

begin

if(rising_edge(system_clk)) then
        
         		
				
        if( startbit = '0' or enable = '1' )then        -- to start new reception or complete one comple byte transfer
          enable := '1';
          i <= i+1;
			 if(i=5207)then                                   -- this clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
          i <= 0;
            if(j < n )then 
             receive(j) <= x;                           -- receiving at 9660 bps and storing it, serial bits are packed
              j <= j+1;
          
         		 if ( j = n-1 ) then
					 receive_out <= receive( n-3 downto 0);       -- packed  datas are sent to receive_out(for testing i mapped this receive out eight bits into LED)
                  enable := '0';                        --when one byte of data received the reception is disabled but again when a new start bit is encounteredd again the reception starts
						j <= 0;                                       
					 END IF;
            END IF;
         END IF;
       END IF;
END IF;
END PROCESS;


end Behavioral;
