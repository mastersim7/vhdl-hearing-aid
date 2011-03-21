----------------------------------------------------------------------------------|
-- Design Name: Transmit Data serially from FPGA to PC via RS232 COM port         | 
-- Module Name: HIF_RS232_Transmit_to_PC - Behavioral                             |
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)                             |
-- Date: 2011-03-19	                                                          |
-------------------------------------History--------------------------------------|
--uthor : Amit Kulkarni                                                           |
--Date : 2011-03-21                                                               |
--Changes made : Changes to fix RESET, proper data reception                      |
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
	 gain_array_output : IN Gained_result_Array_16; -- 8 blocks x 16 bits of data to be received from Equalizer
			   flag_Tx : OUT STD_LOGIC;--flag to indicate that Eqaulizer can now send the average gain signals
			  Tx_to_PC : OUT STD_LOGIC -- Bit by Bit transmission to PC via RS232
		);
END HIF_RS232_Transmit_to_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Transmit_to_PC IS
	SIGNAL j,k				 : INTEGER RANGE 0 TO n; 
	SIGNAL i				 : INTEGER RANGE 0 TO 5208;
	SIGNAL OE_Flag 			 : STD_LOGIC;	-- Internal Flag to decide when transmission of data starts and ends
	SIGNAL OE_Tx_loc         : STD_LOGIC;
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
					IF(i = 5207) THEN -- This clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
						IF(count = 0) THEN
							Tx_to_PC <= '0'; --Send the start bit
							count := 1; --Increment the count to send the actual data
						ELSIF(count = 1) THEN
							Tx_to_PC <= gain_array_output(k)(j); --Transmit to PC bit by bit (8 blocks x 8 bits)
							IF(j < n)THEN  -- Check whether all bits of corresponding blocks are transmitted or not
								j <= j + 1; -- If all bits of corresponding block is not yet transmited completely then increment the index to send next bit
							ELSE
								k <= k + 1; -- Once all bits of the previous blocks are transmitted, select the next block of data to be sent 
								j <= 0; --Reset the bit index so that it points to the first bit of next block
								count := 2; --Increment the count to send the stop bit
								IF (k = 8) THEN
									k <= 1; -- Once all blocks are transmitted, select the first block to be sent again
									flag_Tx <= '1'; --Once all blocks are transmitted set a flag to indicate the Equalizer that all (n blocks x n bits) are successfully transmitted
									OE_Flag <= '0'; --Disable the internal flag so that next set of datas are to be sent
								ELSE
									flag_Tx <= '0';
								END IF;
							END IF;
						ELSIF(count = 2) THEN
							Tx_to_PC <= '1'; --Send the stop bit
							count := 0; -- Reset the count to send the next start bit
						END IF;
						i <= 0;
					END IF;
				END IF;
			ELSIF(RESET_Tx='1') THEN -- When sytstem RESET is encountered RESET_Tx all the counters and flags
					flag_Tx <= '0';
					j <= 0;
					i <= 0;
					k <= 1;
					count := 0;
			END IF;
		END IF;
	END PROCESS;
END Behavioral;  

   
