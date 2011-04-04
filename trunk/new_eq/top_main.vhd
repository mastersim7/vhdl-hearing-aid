-- top_main.vhd
-- Shwan Ciyako , Anandhavel Sakthivel
-- bracnched  sample_system.vhd
-- Mathias Lundell

--  Using ADC and DAC, and EQ and IF inbetween this file will be the top for the FPGA testing

-- 2011-03-22
-- Changed indentations and spaces in order to make the code uniform.
-- Added signal eq_input and connected it from ADC to Equalizer instead of sd_input. Still making
-- it bipolar in between.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY top_main IS 
    GENERIC (
            -- The system master clock is of 50 MHz giving a period of 20ns.
            -- Scaling the master clock to get a restart
            -- time for the ADC at 40 kHz gives us 25e-6/20e-9 = 1250.
            -- The frequencies are changed a little bit to get even scaling
            -- factors for the system master clock.
            -- ADC samples with 39.97 kHz
            -- ADC samples read with 119.9 kHz
            -- Output to DAC, 29.98 kHz
            CLK_SCALE_20khz : NATURAL := 2500;
            CLK_SCALE_2mhz : NATURAL := 25;
            
            N : NATURAL := 12 ); -- Bit length of the data vectors
            
    PORT (
            -- Spartan3 ports
            clk     : IN  STD_LOGIC;                     -- FPGA master clock
            led     : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );-- LEDs
            reset   : IN STD_LOGIC;
            -- Interfacing ports
            ADC_DIN : IN  STD_LOGIC; -- Data Input from ADC
            ADC_CS  : OUT STD_LOGIC; -- Chip Select ADC
            ADC_SCK : OUT STD_LOGIC; -- Serial Clock ADC
            ADC_DOUT: OUT STD_LOGIC; -- Data Out to ADC
            
            DAC_CS  : OUT STD_LOGIC; -- Chip Select DAC
            DAC_SCK : OUT STD_LOGIC; -- Serial Clock DAC
            DAC_SDI : OUT STD_LOGIC; -- Serial Data to DAC
            DAC_LDAC: OUT STD_LOGIC; 
            -- Serial interface 
            RX      : IN STD_LOGIC;
            TX      : OUT STD_LOGIC);-- Latch DAC
         
END ENTITY top_main;

ARCHITECTURE top_main_arch OF top_main IS


-- Components for Rs232
-- Component HIF_RS232_Receive_from_PC IS
    -- GENERIC(
            -- n : INTEGER := 10;
            -- m : INTEGER := 8); --Number of bands
                
    -- PORT(   
            -- system_clk_Rx      : IN STD_LOGIC; --Main clock input
            -- serial_data_inp_Rx : IN STD_LOGIC; --Serial data input(bit by bit)
            -- RESET_Rx           : IN STD_LOGIC; --System RESET_Rx
            --data_ready_Rx : OUT STD_LOGIC;	--Flag to indicate equalizer that, gain datas are ready to send from HIF
            -- gain_data_array_Rx : OUT Gain_Array ); --Band Gain value with 13 bits
-- END COMPONENT;

-- COMPONENT HIF_RS232_Transmit_to_PC IS
	-- GENERIC(
            -- n : INTEGER := 8 ); -- Number of bits to be sent for each gain levels
	-- PORT(   
            -- System_clk_Tx     : IN STD_LOGIC; --System clock input
            -- RESET_Tx          : IN STD_LOGIC; --System RESET_Tx input
            
            --8 blocks x 16 bits of data to be received from Equalizer
            -- gain_array_output : IN Gained_result_Array_16;
            
            --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
            -- OE_Tx             : IN STD_LOGIC;
                                   
            -- flag_Tx  : OUT STD_LOGIC; --flag to indicate that Eqaulizer can now send the average gain signals
            -- Tx_to_PC : OUT STD_LOGIC);-- Bit by Bit transmission to PC via RS232
-- END COMPONENT;

-- Component communicating with the ADC
COMPONENT adc IS
    GENERIC ( 
            CLOCK_SCALE  : NATURAL := 32 );
    PORT (
            -- Spartan3 ports
            clk  : IN  STD_LOGIC;            -- FPGA master clock
            start: IN  STD_LOGIC;            -- start conversion
            OE   : OUT STD_LOGIC;            -- conversion finished
            Q    : OUT STD_LOGIC_VECTOR( 11 DOWNTO 0 );-- LEDs
				
            -- ADC interface ports
            DIN  : IN  STD_LOGIC; -- Serial Data In to FPGA from ADC
            CS   : OUT STD_LOGIC; -- Chip Select (active low)
            SCK  : OUT STD_LOGIC; -- Serial Clock Input to ADC
            DOUT : OUT STD_LOGIC);-- Data Out to ADC from FPGA
END COMPONENT;

-- Component communicating with the DAC
COMPONENT dac IS
    GENERIC ( 
            CLOCK_SCALE  : NATURAL := 8 );
              
              
    PORT(
            -- Spartan3 ports
            clk  : IN  STD_LOGIC;                      -- FPGA master clock
            start: IN  STD_LOGIC;                      -- start conversion
            din  : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );-- data in to adc
            
            -- DAC interface ports
            CS   : OUT STD_LOGIC; -- Chip Select (active low)
            SCK  : OUT STD_LOGIC; -- Serial Clock Input
            SDI  : OUT STD_LOGIC; -- Serial Data Input
            LDAC : OUT STD_LOGIC);-- Latch DAC Input (active low)
END COMPONENT;

--Equalizer 
COMPONENT eq_main IS
GENERIC(
            NUM_OF_SAMPLES: NATURAL := 80;
            NUM_OF_COEFFS : NATURAL := 40;
            NUM_OF_BANDS  : NATURAL := 6);
    PORT( 
            clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  sample;
            new_sample_ready : IN STD_LOGIC;
            OE : OUT STD_LOGIC;
            Q : OUT Multi_result_array);-- interface will take this 
END COMPONENT;

-- Sigma Delta component
--COMPONENT SD IS
--  GENERIC( 
            --N : NATURAL := 12 );
--  PORT(
--         input    : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0); 
--         clk,reset: IN STD_LOGIC; 
--         output   : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
--         sign     : OUT STD_LOGIC);
--END COMPONENT;

-- ADC signals
SIGNAL adc_start  : STD_LOGIC := '0'; -- Start A2D conversion
SIGNAL adc_OE     : STD_LOGIC := '0'; -- ADC finished
SIGNAL adc_output : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- the data from ADC

-- DAC signals
SIGNAL dac_start  : STD_LOGIC := '0'; -- Start D2A conversion
SIGNAL dac_input  : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );

-- Equalizer and interface signals
SIGNAL eq_input             : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL CE_EQ_sig            : STD_LOGIC; -- WHAT IS THIS RUNNING ATT ?
SIGNAL REQ_from_IF_sig      : STD_LOGIC;
SIGNAL GAIN_From_IF_sig     : Gain_Array;
SIGNAL OE_TO_IF_sig         : STD_LOGIC; -- to interface 
SIGNAL OUTPUT_TO_CLASSD_sig : sample;
SIGNAL TO_IF_SUM_sig        : Gained_result_Array_16;-- interface will take this 
SIGNAL INTER_Q_sig          : Multi_result_array;


-- Sigma delta signals
--SIGNAL sd_output         : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
--SIGNAL sd_sign           : STD_LOGIC;
--SIGNAL sd_sign_concd		 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
--SIGNAL sd_input : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );

--------- Begin the architecture sample_system_arch ----------------------
BEGIN

-------------------- Bind the components --------------------------------
adc_comp: adc   
    GENERIC MAP( CLOCK_SCALE => 32 )
    PORT MAP( 
              clk   => clk, 
              start => adc_start, 
              OE    => adc_OE, 
              Q     => adc_output, 
              DIN   => ADC_DIN, 
              CS    => ADC_CS, 
              SCK   => ADC_SCK, 
              DOUT  => ADC_DOUT );
                                
dac_comp: dac   
    GENERIC MAP( CLOCK_SCALE => 32 )
    PORT MAP( 
              clk   => clk, 
              start => dac_start, 
              din   => dac_input, 
              CS    => DAC_CS, 
              SCK   => DAC_SCK, 
              SDI   => DAC_SDI, 
              LDAC  => DAC_LDAC );
              
-- transmitter_comp : HIF_RS232_Transmit_to_PC
    -- PORT MAP( 
--              port in comp  => Signal
              -- System_clk_Tx   	=> clk, 
              -- RESET_Tx 		    => reset, 
              -- Tx_to_PC 		    => Tx,
              -- flag_Tx 		    => REQ_from_IF_sig,
              -- OE_Tx			    => OE_TO_IF_sig,
              -- gain_array_output =>TO_IF_SUM_sig);

-- Receiver_comp   : HIF_RS232_Receive_from_PC 
    -- PORT MAP( 
              -- System_clk_Rx         => clk, 
              -- reset_rx              => reset, 
              -- serial_data_inp_Rx    => Rx,
              -- gain_data_array_Rx    => GAIN_From_IF_sig);
                          

Equalizer_comp : eq_main 
    PORT MAP( 
              clk  	           => clk, -- System clock (50 MHz)
              reset	           => reset,
              sample_in        => eq_input, -- Changed from sd_input to adc_output
              new_sample_ready => adc_OE,     -- OBS! MAKE SURE THAT adc_OE GIVES INTENDED SIGNAL
              OE		       => OE_TO_IF_sig,    -- to interface 
              Q			   => INTER_Q_sig);


--sd_comp: sd     
--    PORT MAP( input => sd_input,
--                          clk => clk,
--                          reset => '0',
--                          output => sd_output,
--                          sign => sd_sign );
--
                          
led      <= adc_output( N-1 DOWNTO 4 );
eq_input <= NOT adc_output(N-1) & adc_output(N-2 DOWNTO 0);
dac_input <= INTER_Q_sig(6)(36 downto 25);

-- Process generating the different frequencies
generate_clock_frequencies: PROCESS ( clk )
    VARIABLE cnt_20kHz  : NATURAL RANGE 0 TO CLK_SCALE_20kHz-1  := 0;
    VARIABLE cnt_2MHz   : NATURAL RANGE 0 TO CLK_SCALE_2MHz-1  := 0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        -- 20 kHz
        IF cnt_20kHz < CLK_SCALE_20kHz-1 THEN
            cnt_20kHz := cnt_20kHz + 1;
            adc_start <= '0';
            dac_start <= '0';
        ELSE
            cnt_20kHz := 0;
            adc_start <= '1';
            dac_start <= '1';
        END IF;  
           
        IF cnt_2mhz < CLK_SCALE_2mhz-1 THEN 
           CE_EQ_sig <= '0';
           cnt_2mhz := cnt_2mhz + 1;
        ELSE 
           cnt_2mhz := 0;
           CE_EQ_sig <= '1';     
        END IF;    
    END IF;
END PROCESS generate_clock_frequencies;


END ARCHITECTURE top_main_arch;
