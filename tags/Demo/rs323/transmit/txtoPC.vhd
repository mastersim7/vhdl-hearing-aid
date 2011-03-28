----------------------------------------------------------------------------------|
-- Design Name: Transmit Data serially from FPGA to PC via RS232 COM port         | 
-- Module Name: HIF_RS232_Transmit_to_PC - Behavioral                             |
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)                             |
-- Date: 2011-03-19	                                                             |
-------------------------------------History--------------------------------------|
--Author : Amit Kulkarni                                                          |
--Date : 2011-03-21                                                               |
--Changes made : Changes to fix RESET, proper data reception                      |
----------------------------------------------------------------------------------|
--Author : Amit Kulkarni                                                          |
--Date : 2011-03-23                                                               |
--Changes made : Bug fix in baud rate clock dividing                              |
----------------------------------------------------------------------------------|
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.EQ_data_type.ALL;

ENTITY HIF_RS232_Transmit_to_PC IS
	GENERIC(n:INTEGER := 8); -- number of bits to be sent for each gain levels
	PORT(system_clk_Tx : IN STD_LOGIC; --system clock inout
			    RESET_Tx : IN STD_LOGIC; --system RESET_Tx inout
				    OE_Tx : IN STD_LOGIC; --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
	 gain_array_output : IN Gained_result_Array_16; -- 8 blocks x 8 bits of data to be received from Equalizer
	   	     flag_Tx : OUT STD_LOGIC;--flag to indicate that Eqaulizer can now send the average gain signals
			    Tx_to_PC : OUT STD_LOGIC -- Bit by Bit transmission to PC via RS232
		);
END HIF_RS232_Transmit_to_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Transmit_to_PC IS
	SIGNAL j ,k			 : INTEGER RANGE 0 TO 10; 
	SIGNAL i				 : INTEGER RANGE 0 TO 8000;
	SIGNAL OE_Flag 	 : STD_LOGIC;	-- Internal Flag to decide when transmission of data starts and ends
	SIGNAL OE_Tx_loc    : STD_LOGIC;
  -- SIGNAL gain_array_output : Gained_result_Array_16 := ("01110000","01110001","01110011","01110100","01110101","01110110","01110111","01111000");
BEGIN
	OE_Tx_loc <= OE_Tx;
	PROCESS(system_clk_Tx,RESET_Tx,OE_Tx_loc,gain_array_output) 
      VARIABLE count : Natural RANGE 0 to 2 := 0;
	BEGIN
      IF(rising_edge(system_clk_Tx))THEN
         IF(RESET_Tx = '0')THEN
            IF(OE_Tx_loc = '1') THEN
               OE_Flag <= '1';
				END IF;
				IF(OE_Flag = '1') THEN
               i <= i+1;
               --Start bit--
					IF(i = 7812 AND count = 0) THEN -- This clock count corresponds to 50MHz for 9600 bps to the middle of the start bit, the count can be changed if we are working with 1MHz or any  other frequency
                  Tx_to_PC <= '0'; --Send the start bit
						count := 1; --Set the count to send the actual data
                  i <= 0;
						j <= 0;
                  
					--Actual data--	
               ELSIF(count = 1 AND i = 5208) THEN
						Tx_to_PC <= gain_array_output(k)(j); --Transmit to PC bit by bit (8 blocks x 8 bits)
						j <= j + 1;
						IF(j = n)THEN  -- Check whether all bits of corresponding blocks are transmitted or not
                     count := 2; -- If all bits of corresponding block is transmited completely then st the count to send the stop bit
							k <= k + 1; -- Increment the block index to point to the next block
							IF(k = 9) THEN --If all blocks are transmitted then,   
								k <= 1;  --reset the block index to the start of the block
								flag_Tx <= '1'; -- turn on the handshake for equalizer
								OE_Flag <= '0'; --and then wait for a enable signal from equalizer
							END IF;
						END IF;
                  i<=0; -- reset the clock count to zero
                  
               --Stop bit--
					ELSIF(count = 2 AND i =5209 ) THEN
						Tx_to_PC <= '1'; --Send the stop bit
						count := 0; -- Reset the count to send the next start bit
					   i <= 0;	-- Reset the clock count to zero								 
					END IF;
            END IF;
            
			ELSIF(RESET_Tx='1') THEN -- When system RESET is encountered RESET_Tx all the counters and flags
				flag_Tx <= '1';
				j <= 0;
				i <= 0;
				count := 0;
				k <= 1;				
			END IF;
		END IF;
	END PROCESS;
END Behavioral;  

   
