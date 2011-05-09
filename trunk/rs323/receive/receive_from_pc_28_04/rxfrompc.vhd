------------------------------------------------------------------------------------------------------------------------------|
-- Design Name: Receive Data serially from PC to FPGA via RS232 COM port                                                      |
-- Module Name: HIF_RS232_Receive_from_PC - Behavioral                                                                        |
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)                                                                         |
-- Date: 2011-03-19                                                                                                           |
------------------------------------------------------------------------------------------------------------------------------|
-- HISTORY :                                                                                                                  |
--Author : Amit Kulkarni                                                                                                      |
--Date : 2011-04-04                                                                                                           |
--Changes made : Changes in the clock division to set the baud rate properly and adding RS232_enable signal                   |
------------------------------------------------------------------------------------------------------------------------------|                                                                                                   |
--Author : Amit Kulkarni                                                                                                      |
--Date : 2011-05-02                                                                                                           |
--Changes made : added an control signal to instruct when to send the average gain levels to the pc(dependent on the RS232API)|       |
------------------------------------------------------------------------------------------------------------------------------|
----------------------------------------------------------------------------------
-- Design Name: Receive Datas from PC to FPGA
-- Module Name:    receive10_2 - Behavioral 
 ----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.EQ_data_type.ALL;

ENTITY HIF_RS232_Receive_from_PC IS
GENERIC( Serial_word_length : NATURAL :=10); --receiving 10 bits start+8 bits of data+stop
   PORT( System_clk_Rx : IN STD_LOGIC;
         Rx: IN STD_LOGIC;
         reset_rx : IN STD_LOGIC;
         --OE_Tx : IN STD_LOGIC; --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
         flag_Tx : OUT STD_LOGIC; --flag to indicate that Eqaulizer can now send the average gain signals
         Gain_array :OUT Gained_result_Array
        -- temp_led:OUT STd_LOGIC_vector(7 downto 0)
       );
END HIF_RS232_Receive_from_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Receive_from_PC IS
 SIGNAL receive: STD_LOGIC_VECTOR(Serial_word_length-1 DOWNTO 0); 
 SIGNAL j:NATURAL RANGE 0 TO Serial_word_length; 
 SIGNAL counter_clk_div:NATURAL RANGE 0 TO 5210;
 SIGNAL startbit:STD_LOGIC;
 
 --SIGNAL memory_temp : Gained_result_Array_8; 
BEGIN

startbit <= Rx; --receive bits from PC continuasly, Rx is mapped with receive pin of RS232 using UCF file

PROCESS(System_clk_Rx,reset_rx)

    VARIABLE enable : STD_LOGIC;
    VARIABLE k : NATURAL RANGE 0 TO 8;
    VARIABLE memory_temp : Gained_result_Array_8;
    VARIABLE LUT : Gained_result_Array;
    VARIABLE rx_flag_int : STD_LOGIC;
    VARIABLE Count_int :NATURAL RANGE 0 TO 8;
BEGIN
IF(reset_rx = '1') THEN
           FOR k IN 0 TO 7 LOOP
            Gain_array(k) <="0111111111111";
            END LOOP;
            rx_flag_int := '0';
            counter_clk_div <= 0;            
            --startbit <= '1';
            k := 0;
            j <= 0;
            enable := '0';    
ELSIF(reset_rx = '0') THEN
    IF(rising_edge(system_clk_Rx)) THEN
        IF( startbit = '0' OR enable = '1' )THEN  -- to start new reception or complete one comple byte transfer
            enable := '1';
            --rx_flag_int := '0';
            counter_clk_div <= counter_clk_div+1;
                        IF(counter_clk_div = 5207)THEN   -- this clock count corresponds to 50MHz for 9600 bps and can be changed if we are working with 1MHz or any  other frequency
                counter_clk_div <= 0;
                IF(j < Serial_word_length )THEN
                    receive(j) <= Rx;    -- receiving at 9660 bps and storing it, serial bits are packed
                    j <= j+1;
                    IF ( j = Serial_word_length-2 ) THEN
                        memory_temp(k) := receive( Serial_word_length-3 DOWNTO 0);  -- packed  datas are sent to receive_out(for testing counter_clk_div mapped this receive out eight bits into LED)
                        CASE memory_temp(k) IS -- Look Up Table begins here(as data are not decided so initially we set all the bit equal to high)
                            WHEN "00000001" => 
                                LUT(k) :="0000000000011"; 
                            WHEN "00000010" => 
                                LUT(k) :="0000000000100"; 
                            WHEN "00000011" => 
                                LUT(k) :="0000000000101"; 
                            WHEN "00000100" => 
                                LUT(k) :="0000000000110"; 
                            WHEN "00000101" => 
                                LUT(k) :="0000000001000"; 
                            WHEN "00000110" => 
                                LUT(k) :="0000000001010"; 
                            WHEN "00000111" => 
                                LUT(k) :="0000000001100"; 
                            WHEN "00001000" => 
                                LUT(k) :="0000000010000"; 
                            WHEN "00001001" => 
                                LUT(k) :="0000000010100"; 
                            WHEN "00001010" => 
                                LUT(k) :="0000000011001"; 
                            WHEN "00001011" => 
                                LUT(k) :="0000000100000"; 
                            WHEN "00001100" => 
                                LUT(k) :="0000000101000"; 
                            WHEN "00001101" => 
                                LUT(k) :="0000000110011"; 
                            WHEN "00001110" => 
                                LUT(k) :="0000001000000"; 
                            WHEN "00001111" => 
                                LUT(k) :="0000001010001"; 
                            WHEN "00010000" => 
                                LUT(k) :="0000001100110"; 
                            WHEN "00010001" =>
                                LUT(k) :="0000010000001"; 
                            WHEN "00010010" => 
                                LUT(k) :="0000010100011"; 
                            WHEN "00010011" => 
                                LUT(k) :="0000011001101"; 
                            WHEN "00010100" => 
                                LUT(k) :="0000100000010"; 
                            WHEN "00010101" => 
                                LUT(k) :="0000101000101"; 
                            WHEN "00010110" => 
                                LUT(k) :="0000110011001"; 
                            WHEN "00010111" => 
                                LUT(k) :="0001000000011"; 
                            WHEN "00011000" => 
                                LUT(k) :="0001010001001"; 
                            WHEN "00011001" => 
                                LUT(k) :="0001100110001"; 
                            WHEN "00011010" => 
                                LUT(k) :="0010000000100"; 
                            WHEN "00011011" =>
                                LUT(k) :="0010100001110"; 
                            WHEN "00011100" =>
                                LUT(k) :="0011001011110"; 
                            WHEN "00011101" => 
                                LUT(k) :="0100000000100"; 
                            WHEN "00011110" => 
                                LUT(k) :="0101000010111"; 
                            WHEN "00011111" => 
                                LUT(k) :="0110010110100"; 
                            WHEN "00100000" => 
                                LUT(k) :="0111111111111"; 
                            WHEN "01000000" =>		
                                rx_flag_int := '1';
                            WHEN OTHERS => 
                                NULL;
                        END CASE;
                        k := k+1; --increment to fill the next block
                        IF(k = 8) THEN --Final gain values of 13 bits are now  ready
                            Gain_array(0) <= LUT(0); 
                            Gain_array(1) <= LUT(1);
                            Gain_array(2) <= LUT(2);
                            Gain_array(3) <= LUT(3);
                            Gain_array(4) <= LUT(4);
                            Gain_array(5) <= LUT(5);
                            Gain_array(6) <= LUT(6);
                            Gain_array(7) <= LUT(7);
                            k := 0; -- Once all LUT value is given restart from the first block
                        END IF;                              
                        --k := k +1;
                        enable := '0'; --when one byte of data received the reception is disabled but again when a new start bit is encounteredd again the reception starts
                        j <= 0;
--                        IF(k = 8) THEN                       
--                            k := 0;
--                        END IF;
                    END IF;--j = Serial_word_length-2 
                END IF;--j
            END IF;--counter_clk_div
        END IF;  --startbit
        
  IF(rx_flag_int = '1') THEN
    count_int := count_int + 1;
    flag_Tx  <= rx_flag_int;
   END IF;

  IF(Count_int = 7 ) THEN
       rx_flag_int := '0';
       flag_Tx  <= '0';
       Count_int := 0;
  END IF;    
     
    END IF;--clock
END IF;--reset
--IF(OE_Tx = '1') THEN
--rx_flag_in := '0';
--END IF;
--flag_Tx  <= rx_flag_int;
----flag_Tx  <= '1';
--
--rx_flag_int := '0';    
----temp_led <= LUT(7)(12 downto 5);

END PROCESS;

END Behavioral;


