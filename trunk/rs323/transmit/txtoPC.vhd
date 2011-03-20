----------------------------------------------------------------------------------
-- Design Name: Transmit Data serially from FPGA to PC via RS232 COM port
-- Module Name: HIF_RS232_Transmit_to_PC - Behavioral 
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)
-- Date: 2011-03-19
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.EQ_data_type.ALL;

ENTITY HIF_RS232_Transmit_to_PC IS
	GENERIC(n:INTEGER:=8); -- number of bits to be sent for each gain levels
	PORT(system_clk_Tx : IN STD_LOGIC; --system clock input
			  RESET_Tx : IN STD_LOGIC; --system RESET_Tx input
				 OE_Tx : IN STD_LOGIC; --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
	 gain_array_output : IN Gained_result_Array_16; -- 8 blocks x 16 bits of data to be received from Equalizer
			   flag_Tx : OUT STD_LOGIC;--flag to indicate that Eqaulizer can now send the average gain signals
			  Tx_to_PC : OUT STD_LOGIC -- Bit by Bit transmission to PC via RS232
		);
END HIF_RS232_Transmit_to_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Transmit_to_PC IS
	SIGNAL k				 : INTEGER RANGE 0 TO n+1; 
	SIGNAL j				 : INTEGER RANGE 0 TO n;
	SIGNAL i				 : INTEGER RANGE 0 TO 5208;
	SIGNAL OE_Flag 			 : STD_LOGIC;	-- Internal Flag to decide when transmission of data starts and ends
BEGIN
	PROCESS(system_clk_Tx,RESET_Tx,OE_Tx,gain_array_output) 
	VARIABLE count : NATURAL RANGE 0 to 2; -- Counter to decide when to send start + data + stop bits
	BEGIN
		IF(OE_Tx = '1') THEN
			OE_Flag <= '1';
		END IF;
		IF(rising_edge(system_clk_Tx) AND RESET_Tx = '0' AND OE_Flag = '1') THEN
			i <= i+1;
			IF(i = 5207) THEN -- This clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
				i <= 0;
				IF(count = 0) THEN
					Tx_to_PC <= '0'; --Send the Start bit
					count := count + 1; --Increment the count to send the actual data
				ELSIF(count = 1) THEN
					IF(j < n )THEN  -- Check whether all bits of corresponding block are transmitted or not
						Tx_to_PC <= gain_array_output(k)(j); --Transmit to PC bit by bit (8 blocks x 8 bits)
						j <= j + 1;  -- If all bits of corresponding block is not yet transmited completely then increment the index to send next bit
					ELSE
						k <= k + 1; -- Once all bits of the previous blocks are transmitted, select the next block of data to be sent 
						count := count + 1; --Increment the count to send the stop bit
						j <= 0; --Reset the bit index to point the first bit of the next block
						IF(k=8) THEN
							k <= 1; -- Once all blocks are transmitted, select the first block to be sent again
							flag_Tx <= '1'; --Once all blocks are transmitted set a flag to indicate the Equalizer that all (n blocks x n bits) are successfully transmitted
							OE_Flag <= '0'; --Disable the internal flag so that next set of datas are to be sent only if Equalizer send the next set of new data
						ELSE
							flag_Tx <= '0';
						END IF;
					END IF;
				ELSIF(count = 2) THEN
					Tx_to_PC <= '1'; --Send the stop bit
					count := 0; -- Rest the count to send the start bit for next 8 bits of data
				END IF;
			END IF;
		ELSIF(RESET_Tx='1') THEN -- When sytstem RESET_Tx is encountered RESET_Tx all the counters and flags
			flag_Tx <= '0';
			j <= 0;
			i <= 0;
			k <= 1;
			count := 0;
		END IF;
	END PROCESS;
END Behavioral;  

   