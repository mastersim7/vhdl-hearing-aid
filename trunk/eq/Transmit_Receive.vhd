
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.all;
USE work.EQ_data_type.all;
entity Transmit_Receive is
GENERIC(m:INTEGER:=200;--initially sending 
        n:INTEGER:= 80);--receiving 80 bits for 8 gain levels (start+8 bits of data+stop per byte)
   PORT( CLK : in STD_LOGIC;
         x: in STD_LOGIC;
			AVERAGE_SIG_LEV: IN AVERAGE_SIG_LEV_type;
			AVERAGE_SIG_LEV_ENABLE:IN STD_LOGIC;
			GAIN :OUT gain_type;
			y: OUT STD_LOGIC
  );end Transmit_Receive;

  
architecture Behavioral of Transmit_Receive is
   
	signal state:integer range 0 to 3;
   signal startbit:STD_LOGIC;
-- for control
	signal receive_control: STD_LOGIC_VECTOR(7 DOWNTO 0); 
	signal receive_control_out: STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal j:INTEGER RANGE 0 TO 10; 
   signal i:INTEGER RANGE 0 TO 5210;
-- for receiving gain
   signal receive_gain: STD_LOGIC_VECTOR(n-1 DOWNTO 0); 
	signal receive_gain_out: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   signal k:INTEGER RANGE 0 TO n; 
   signal l:INTEGER RANGE 0 TO 5210;
-- for transmitting asl
   signal p:INTEGER RANGE 0 TO m; 
   signal q:INTEGER RANGE 0 TO 5210;
	signal transmit: STD_LOGIC_VECTOR(m-1 DOWNTO 0); 
	
	 

begin
startbit <= x; --receive bits from PC continuasly, x is mapped with receive pin of RS232 using UCF file

process(clk)

 variable enable_control:STD_LOGIC;
  variable enable_receive:STD_LOGIC;

 
begin
case state is 
        
        when 0=>
		  
		  if(rising_edge(clk)) then
         						
        if( startbit = '0' or enable_control = '1' )then        -- to start new reception or complete 8 byte transfer
          enable_control := '1';
          i <= i+1;
			 if(i=5207)then                                   -- this clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
          i <= 0;
            if(j < 10 )then 
             receive_control(j) <= x;                           -- receiving at 9600 bps and storing it, 
              j <= j+1;
           		 if ( j = 9 ) then
					 receive_control_out <= receive_control( 7 downto 0);      
                  enable_control := '0';                        --when 8 bytes of data received the reception is disabled but again when a new start bit is encounteredd again the reception starts
						j <= 0;                                       
					 END IF;
            END IF;
         END IF;
       END IF;
END IF;
		  
                  state<=1;

        when 1=> 
		  
		  if(receive_control_out = "11110000" ) then -- receive gain values
                  state<=2;
		  END IF;
		  
		  if(receive_control_out = "11110110" ) then  --send asl
                  state<=3;
		  END IF;			
		  
        when 2=> 
		  if(rising_edge(clk)) then
          						
        if( startbit = '0' or enable_receive = '1' )then        -- to start new reception or complete 8 byte transfer
          enable_receive := '1';
          l <= l+1;
			 if(l=5207)then                                   -- this clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
          l <= 0;
            if(k < n )then 
             receive_gain(k) <= x;                           -- receiving at 9600 bps and storing it, serial bits are packed
              k <= k+1;
          
         		 if ( k = n-1 ) then
					 receive_gain_out <= receive_gain( n-3 downto 0);       -- packed  datas are sent to receive_out(for testing i mapped this receive out bits into LED)
                  enable_receive := '0';                        --when 8 bytes of data received the reception is disabled but again when a new start bit is encounteredd again the reception starts
						k <= 0;                                       
					 END IF;
            END IF;
         END IF;
       END IF;
END IF;

-- received datas should be converted to corresponding gain values and gain should be outputed
                  state<=0;
        
		  when 3=> 
		  
		  
		  -- the 200 asl should be added and then transmitted.
		  
		  if(rising_edge(CLK)) then



          y <= transmit(p);
          q <= q+1;
         
          if(q=5207)then -- this clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
          q <= 0;
            if(p < m )then 
             
              p <= p+1;
          
                    if ( p = m-1 ) then
                   p <= 0; -- to send continuasly
                 END IF;
            END IF;
         END IF;
END IF;

                  state<=0;
						end case; 
END process;
end Behavioral;

