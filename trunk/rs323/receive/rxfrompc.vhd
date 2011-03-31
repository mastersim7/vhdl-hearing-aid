----------------------------------------------------------------------------------
-- Design Name: Receive Data serially from PC to FPGA via RS232 COM port
-- Module Name: HIF_RS232_Receive_from_PC - Behavioral 
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)
-- Date: 2011-03-19
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_STD.ALL;
USE work.EQ_data_type.ALL;

ENTITY HIF_RS232_Receive_from_PC IS
    GENERIC(Serial_word_length:INTEGER:=10;  --Total number of bits received (10 bits = 1-start bit + 8 bits of data + 1-stop bit)
        m:INTEGER:=8);   --No.of.Bands

    PORT(   clk :           IN STD_LOGIC;--Main clock input
            RX :            IN STD_LOGIC; --Serial data input(1 bit)
            reset :         IN STD_LOGIC;--System reset
            Gain_array :    OUT Gained_result_Array --need to be changed bad named type--Band Gain value with 13 bits
        ); 
END HIF_RS232_Receive_from_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Receive_from_PC IS
        SIGNAL receive  :STD_LOGIC_VECTOR(Serial_word_length-1 DOWNTO 0); --signal where data from PC is collected for first time
        SIGNAL j,k  :       INTEGER RANGE 0 TO n; 
        SIGNAL i:           INTEGER RANGE 0 TO 5210;
        SIGNAL startbit :   STD_LOGIC;
        --SIGNAL gain_data:   STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL LUT :        Gained_result_Array ;--LUT to convert internally the gain values from 8 bits to 13 bits valeus

BEGIN
    startbit <= RX; --Receive bits from PC serially
    PROCESS(clk,reset)
            VARIABLE enable:        STD_LOGIC;
            VARIABLE gain_data:     STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        IF(rising_edge(clk)) THEN
            IF(reset = '0') THEN
                IF( (startbit = '0' or enable = '1')) THEN  --Check to start new reception or complete one comple byte transfer
                    enable := '1'; --makes sure the entire word is recieved before the component goes off
                    i <= i+1; -- i keeps the last (OLD) value
                    IF(i=5207) THEN  --Count corresponds to 50MHz for 9600 bps 
                        i <= 0;
                        IF(j < n ) THEN 
                            receive(j) <= RX; --Receiving at 9600 bps and storing it, serial bits are packed
                            j <= j + 1;
                            IF ( j = n-2 ) THEN
                                gain_data <= receive( n-3 downto 0); -- Packed datas are first stored in the local cariable and then used for value conversion
                                CASE gain_data IS -- Look Up Table begins here(as data are not decided so initially we set all the bit equal to high)
                     

                                    WHEN "00000001" => 
                                        LUT(k) <="0000000000011"; 
                                    WHEN "00000010" => 
                                        LUT(k) <="0000000000100"; 
                                    WHEN "00000011" => 
                                        LUT(k) <="0000000000101"; 
                                    WHEN "00000100" => 
                                        LUT(k) <="0000000000110"; 
                                    WHEN "00000101" => 
                                        LUT(k) <="0000000001000"; 
                                    WHEN "00000110" => 
                                        LUT(k) <="0000000001010"; 
                                    WHEN "00000111" => 
                                        LUT(k) <="0000000001100"; 
                                    WHEN "00001000" => 
                                        LUT(k) <="0000000010000"; 
                                    WHEN "00001001" => 
                                        LUT(k) <="0000000010100"; 
                                    WHEN "00001010" => 
                                        LUT(k) <="0000000011001"; 
                                    WHEN "00001011" => 
                                        LUT(k) <="0000000100000"; 
                                    WHEN "00001100" => 
                                        LUT(k) <="0000000101000"; 
                                    WHEN "00001101" => 
                                        LUT(k) <="0000000110011"; 
                                    WHEN "00001110" => 
                                        LUT(k) <="0000001000000"; 
                                    WHEN "00001111" => 
                                        LUT(k) <="0000001010001"; 
                                    WHEN "00010000" => 
                                        LUT(k) <="0000001100110"; 
                                    WHEN "00010001" =>
                                        LUT(k) <="0000010000001"; 
                                    WHEN "00010010" => 
                                        LUT(k) <="0000010100011"; 
                                    WHEN "00010011" => 
                                        LUT(k) <="0000011001101"; 
                                    WHEN "00010100" => 
                                        LUT(k) <="0000100000010"; 
                                    WHEN "00010101" => 
                                        LUT(k) <="0000101000101"; 
                                    WHEN "00010110" => 
                                        LUT(k) <="0000110011001"; 
                                    WHEN "00010111" => 
                                        LUT(k) <="0001000000011"; 
                                    WHEN "00011000" => 
                                        LUT(k) <="0001010001001"; 
                                    WHEN "00011001" => 
                                        LUT(k) <="0001100110001"; 
                                    WHEN "00011010" => 
                                        LUT(k) <="0010000000100"; 
                                    WHEN "00011011" =>
                                        LUT(k) <="0010100001110"; 
                                    WHEN "00011100" =>
                                        LUT(k) <="0011001011110"; 
                                    WHEN "00011101" => 
                                        LUT(k) <="0100000000100"; 
                                    WHEN "00011110" => 
                                        LUT(k) <="0101000010111"; 
                                    WHEN "00011111" => 
                                        LUT(k) <="0110010110100"; 
                                    WHEN "00100000" => 
                                        LUT(k) <="0111111111111"; 
                                    WHEN OTHERS => 
                                        NULL;
                                END CASE;
                                k <= k+1;
                                IF(k = 8) THEN --Final gain values of 13 bits are now  ready
                                    Gain_array(1) <= LUT(1); 
                                    Gain_array(2) <= LUT(2);
                                    Gain_array(3) <= LUT(3);
                                    Gain_array(4) <= LUT(4);
                                    Gain_array(5) <= LUT(5);
                                    Gain_array(6) <= LUT(6);
                                    Gain_array(7) <= LUT(7);
                                    Gain_array(8) <= LUT(8);
                                    k<=0;
                                END IF;
                                enable := '0';  --When one byte of data received the reception is halted but again when a new start bit is encountered, the serial data reception starts
                                    j <= 0;                                       
                            END IF;
                    END IF;
            END IF;
         END IF;
         ELSIF(reset = '1') THEN
            Gain_array <=(OTHERS =>"0111111111111");
        END IF;
    END IF;
END PROCESS;
END Behavioral;
