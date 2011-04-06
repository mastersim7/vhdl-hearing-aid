----------------------------------------------------------------------------------|
-- Design Name: Transmit Data serially from FPGA to PC via RS232 COM port         | 
-- Module Name: HIF_RS232_Transmit_to_PC - Behavioral                             |
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)                             |
-- Date: 2011-03-19                                                               |
-------------------------------------History--------------------------------------|
--Author : Amit Kulkarni                                                          |
--Date : 2011-03-21                                                               |
--Changes made : Changes to fix RESET, proper data reception                      |
----------------------------------------------------------------------------------|
--Author : Amit Kulkarni                                                          |
--Date : 2011-03-23                                                               |
--Changes made : Bug fix in baud rate clock dividing                              |
----------------------------------------------------------------------------------|
--Author : Amit Kulkarni                                                          |
--Date : 2011-04-04                                                               |
--Changes made : Inserted the RS232_enable signal                                 |
----------------------------------------------------------------------------------|
--Author : Amit Kulkarni                                                          |
--Date : 2011-04-06                                                               |
--Changes made : The idle signal of the Tx_to_PC in RS232 must be high-fix done   |
----------------------------------------------------------------------------------|
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.EQ_data_type.ALL;

ENTITY HIF_RS232_Transmit_to_PC IS
    GENERIC(n:INTEGER := 8); -- number of bits to be sent for each gain levels
    PORT(
          system_clk_Tx : IN STD_LOGIC; --system clock inout
               RESET_Tx : IN STD_LOGIC; --system RESET_Tx input
                  OE_Tx : IN STD_LOGIC; --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
      --gain_array_output : IN Gained_result_Array_8; -- 8 blocks x 8 bits of data to be received from Equalizer
                flag_Tx : OUT STD_LOGIC;--flag to indicate that Eqaulizer can now send the average gain signals
               Tx_to_PC : OUT STD_LOGIC  -- Bit by Bit transmission to PC via RS232
        );
END HIF_RS232_Transmit_to_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Transmit_to_PC IS
    
  --  SIGNAL OE_Flag : STD_LOGIC;   -- Internal Flag to decide when transmission of data starts and ends
    SIGNAL OE_Tx_loc : STD_LOGIC;
    SIGNAL RS232_enable : STD_LOGIC;
    SIGNAL counter_clk_div : natural RANGE 0 to 5210;  
    SIGNAL gain_array_output : Gained_result_Array_8 := ("10011001","01000001","10011001","01000001","10011001","01000001","10011001","01000001");
    BEGIN
    
    PROCESS(system_clk_Tx,RESET_Tx,OE_Tx,gain_array_output) 
        VARIABLE state : Natural RANGE 0 to 2;
        VARIABLE j ,k    : INTEGER RANGE 0 TO 10; 
    BEGIN
        IF(RESET_Tx = '1') THEN
            flag_Tx <= '1';
            j := 0;
            counter_clk_div <= 0;
            state := 0;
            RS232_enable <= '0';
            k := 0;
				Tx_to_PC <= '1';
        ELSIF(RESET_Tx = '0') THEN
            IF(rising_edge(system_clk_Tx))THEN
                IF(OE_Tx = '1') THEN
                    OE_Tx_loc <= '1';
                END IF;
                IF(OE_Tx_loc = '1') THEN
                    counter_clk_div <= counter_clk_div + 1; -- Increment the counter
                    IF( counter_clk_div =5208) THEN
                        RS232_enable <= '1';    -- generate the intermediate enable signal
                        counter_clk_div <= 0;   -- Reset the counter after generating the intermediate signal
                    ELSE
                        RS232_enable <= '0';
                    END IF;
              
						  IF( RS232_enable = '1') THEN
                        IF( state = 0 ) THEN
                            Tx_to_PC <= '0'; --Send the start bit
                            state := 1; --Set the state to send the actual data
                            j := 0; -- Set the start index of the actual data which is ready to send  
   						 
                        ELSIF( state = 1 ) THEN
                            Tx_to_PC <= gain_array_output(k)(j); --Transmit to PC bit by bit (8 blocks x 8 bits)
                            j := j + 1;
                            IF(j = n)THEN  -- Check whether all bits of corresponding blocks are transmitted or not
                                state := 2; -- If all bits of corresponding block is transmited completely then st the state to send the stop bit
                                k := k + 1; -- Increment the block index to point to the next block
                                IF(k = 8) THEN --If all blocks are transmitted then,   
                                    flag_Tx <= '1'; -- turn on the handshake for equalizer
                                    OE_Tx_loc <= '0'; --and then wait for a enable signal from equalizer
                                    k := 0;  --reset the block index to the start of the block
                                END IF;			
                            END IF;
                        ELSIF ( state = 2 ) THEN
                            Tx_to_PC <= '1'; --Send the stop bit
                            state := 0; -- Reset the state to send the next start bit
                        END IF;
                    END IF;
            	 END IF;
           END IF;
        END IF;
    END PROCESS;
END Behavioral;
