----------------------------------------------------------------------------------
-- Design Name: Receive Data serially from PC to FPGA via RS232 COM port
-- Module Name: HIF_RS232_Receive_from_PC - Behavioral 
-- Designer: Amit Kulkarni(amitk@student.chalmers.se)
-- Date: 2011-03-19
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY HIF_RS232_Receive_from_PC IS
	GENERIC(n:INTEGER:=10;  --Total number of bits received (10 bits = 1-start bit + 8 bits of data + 1-stop bit)
			m:INTEGER:=8;   --No.of.Bands
			p:INTEGER:=13); --Datasize in bits of each gain level after internal conversion from 8 bits to 13 bits(signed data)

	PORT(     system_clk : IN STD_LOGIC;	--Main clock input
		 serial_data_inp : IN STD_LOGIC; 	--Serial data input(bit by bit)
				   RESET : IN STD_LOGIC;	--System reset
			  data_ready : OUT STD_LOGIC;	--Flag to indicate equalizer that, gain datas are ready to send from HIF
			gain_data_1  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band1 Gain value with 13 bits
			gain_data_2  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band2 Gain value with 13 bits
			gain_data_3  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band3 Gain value with 13 bits
			gain_data_4  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band4 Gain value with 13 bits
			gain_data_5  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band5 Gain value with 13 bits
			gain_data_6  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band6 Gain value with 13 bits
			gain_data_7  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0); --Band7 Gain value with 13 bits
			gain_data_8  : OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0));--Band8 Gain value with 13 bits
END HIF_RS232_Receive_from_PC;

ARCHITECTURE Behavioral OF HIF_RS232_Receive_from_PC IS
	TYPE memory IS ARRAY (0 TO m-1) OF STD_LOGIC_VECTOR(p-1 DOWNTO 0);
	SIGNAL receive  :STD_LOGIC_VECTOR(n-1 DOWNTO 0); --Variable where data from PC is collected for first time
	SIGNAL j,k	  	:INTEGER RANGE 0 TO n; 
	SIGNAL i		:INTEGER RANGE 0 TO 5210;
	SIGNAL startbit :STD_LOGIC;
	SIGNAL gain_data:STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL LUT 		: memory;	--Array for LUT to convert the gain values
							
BEGIN
	startbit <= serial_data_inp; --Receive bits from PC serially, serial_data_inp is mapped with receive pin of RS232 using UCF file
	PROCESS(system_clk,RESET)
		VARIABLE enable:STD_LOGIC;
	BEGIN
		IF(rising_edge(system_clk) AND RESET = '0') THEN
      		IF( (startbit = '0' or enable = '1'))THEN  --Check to start new reception or complete one comple byte transfer
				enable := '1';
				i <= i+1;
				IF(i=5207)THEN  --Count corresponds to 50MHz for 9600 bps and can be changed IF we are working with 1MHz or any  other frequency
					i <= 0;
					IF(j < n )THEN 
						receive(j) <= serial_data_inp; --Receiving at 9600 bps and storing it, serial bits are packed
						j <= j + 1;
						IF ( j = n-1 ) THEN
							gain_data <= receive( n-3 downto 0); -- Packed datas are first stored in the local cariable and then used for value conversion
							CASE gain_data IS 	-- Look Up Table begins here(as data are not decided so initially we set all the bit equal to high)
								WHEN "00000001" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --1
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00000010" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --2
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00000011" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --3
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00000100" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --4
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00000101" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --5
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00000110" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --6
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00000111" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --7
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001000" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --8
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001001" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --9
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001010" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --10
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001011" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --11
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001100" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --12
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001101" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --13
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001110" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --14
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00001111" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --15
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010000" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --16
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010001" =>
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --17
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010010" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --18
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010011" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --19
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010100" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --20
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010101" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --21
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010110" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --22
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00010111" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --23
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011000" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --24
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011001" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --25
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011010" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --26
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011011" =>
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --27
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011100" =>
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --28
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011101" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --29
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011110" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --30
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00011111" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --31
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN "00100000" => 
												IF RESET = '0' THEN
													LUT(k) <="0111111111111"; --32
												ELSE
													LUT(k) <="0111111111111"; 
												END IF;
								WHEN OTHERS => NULL;
							END CASE;
							k <= k+1;
							IF(k = 8) THEN 		--Final gain values of 13 bits are now ready
								k<=0;
								gain_data_1 <= LUT(1); 
								gain_data_2 <= LUT(2);
								gain_data_3 <= LUT(3);
								gain_data_4 <= LUT(4);
								gain_data_5 <= LUT(5);
								gain_data_6 <= LUT(6);
								gain_data_7 <= LUT(7);
								gain_data_8 <= LUT(8);
								data_ready  <= '1';	-- Set a flag that gain values are ready and to be accpted by EQUALIZER
							ELSE
								data_ready <= '0'; --Ensure that flag is reset so that EQUALIZER waits for the data processed by HIF
							END IF;
							enable := '0';  --When one byte of data received the reception is halted but again when a new start bit is encountered, the serial data reception starts
							j <= 0;                                       
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavioral;
