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
--USE work.EQ_functions.ALL;

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
            CLK_SCALE_20khz : NATURAL := 1000;
            
            N : NATURAL := 12 ); -- Bit length of the data vectors
            
    PORT (
            -- Spartan3 ports
            clk     : IN  STD_LOGIC;                     -- FPGA master clock
            --led     : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );-- LEDs
            reset   : IN STD_LOGIC;
            -- Interfacing ports
            ADC_DIN : IN  STD_LOGIC; -- Data Input from ADC
            ADC_CS  : OUT STD_LOGIC; -- Chip Select ADC
            ADC_SCK : OUT STD_LOGIC; -- Serial Clock ADC
            ADC_DOUT: OUT STD_LOGIC; -- Data Out to ADC
            
          --  DAC_CS  : OUT STD_LOGIC; -- Chip Select DAC
          --  DAC_SCK : OUT STD_LOGIC; -- Serial Clock DAC
          --  DAC_SDI : OUT STD_LOGIC; -- Serial Data to DAC
          --  DAC_LDAC: OUT STD_LOGIC; 
            
          --  select_filters:STD_LOGIC_VECTOR( 7 DOWNTO 0 );
				-- Serial interface 
            RX      : IN STD_LOGIC;
	    sd_sign : OUT STD_LOGIC;			
            TX      : OUT STD_LOGIC);-- Latch DAC
         
END ENTITY top_main;

ARCHITECTURE top_main_arch OF top_main IS

-- constants 
--constant temp_gains : Gain_Array := ( "0000000000001" ,"0000000000001","0000000000001","0000000000001","0000000000001","0000000000001","0000000000001" ,
--"0000000000001");
 
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

COMPONENT HIF_RS232_Transmit_to_PC IS
    GENERIC(n:INTEGER := 8); -- number of bits to be sent for each gain levels
    PORT(
          clk : IN STD_LOGIC; --system clock inout
               RESET : IN STD_LOGIC; --system RESET_Tx input
                  OE_Tx : IN STD_LOGIC; --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
      gain_array_input : IN Gained_result_Array_8; -- 8 blocks x 8 bits of data to be received from Equalizer
                --flag_Tx : OUT STD_LOGIC;--flag to indicate that Eqaulizer can now send the average gain signals
               Tx_to_PC : OUT STD_LOGIC  -- Bit by Bit transmission to PC via RS232
        );
END COMPONENT;

--COMPONENT HIF_RS232_Receive_from_PC IS
--GENERIC( Serial_word_length : NATURAL :=10); --receiving 10 bits start+8 bits of data+stop
--   PORT( System_clk_Rx : IN STD_LOGIC;
--         Rx: IN STD_LOGIC;
--         reset_rx : IN STD_LOGIC;
--		 Gain_array :OUT Gained_result_Array
--        -- temp_led:OUT STd_LOGIC_vector(7 downto 0)
--       );
--END COMPONENT;


COMPONENT HIF_RS232_Receive_from_PC IS
GENERIC( Serial_word_length : NATURAL :=10); --receiving 10 bits start+8 bits of data+stop
   PORT( System_clk_Rx : IN STD_LOGIC;
         Rx: IN STD_LOGIC;
         reset_rx : IN STD_LOGIC;
        -- OE_Tx : IN STD_LOGIC; --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
         flag_Tx : OUT STD_LOGIC; --flag to indicate that Eqaulizer can now send the average gain signals
         Gain_array :OUT Gained_result_Array
        -- temp_led:OUT STd_LOGIC_vector(7 downto 0)
       );
END COMPONENT;

COMPONENT average_if IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 16;
            NUM_OF_SAMPLES : NATURAL := 200;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   :IN STD_LOGIC;
           -- CE      : IN STD_LOGIC;
            OE_GAINAMP : IN STD_LOGIC;
            REQ     :IN STD_LOGIC;
            Gained_Samples: IN Gained_result_Array_16; --an 8-array of 16 bit vectors
            OE      : OUT STD_LOGIC; 
            Q       : OUT Gained_result_Array_8); -- changed down to 8 bits/amit
END COMPONENT;





-- Component communicating with the ADC
COMPONENT new_adc IS
    GENERIC ( 
            CLOCK_SCALE  : NATURAL );
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
--COMPONENT new_dac IS
  --  GENERIC ( 
    --        CLOCK_SCALE  : NATURAL );
              
              
   -- PORT(
            -- Spartan3 ports
     --       clk  : IN  STD_LOGIC;                      -- FPGA master clock
       --     start: IN  STD_LOGIC;                      -- start conversion
         --   din  : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );-- data in to adc
            
            -- DAC interface ports
           -- CS   : OUT STD_LOGIC; -- Chip Select (active low)
            --SCK  : OUT STD_LOGIC; -- Serial Clock Input
            --SDI  : OUT STD_LOGIC; -- Serial Data Input
            --LDAC : OUT STD_LOGIC);-- Latch DAC Input (active low)
--END COMPONENT;

--Equalizer 
COMPONENT eq_main IS
GENERIC(
            NUM_OF_SAMPLES: NATURAL ;
            NUM_OF_COEFFS : NATURAL ;
            NUM_OF_BANDS  : NATURAL );
    PORT( 
            clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  sample;
            new_sample_ready : IN STD_LOGIC;
            OE : OUT STD_LOGIC;
            Q : OUT Multi_result_array);-- interface will take this 
END COMPONENT;

COMPONENT gain_amplifier IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_GAINS : NATURAL := 8;
            NUM_OF_FILTERS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            FB_OE   : IN STD_LOGIC;
            RAW_OUTPUT : IN Multi_Result_array ;-- 0 to 8 of 36 to 0 
            GAIN    : IN Gained_result_Array;
            OE      : OUT STD_LOGIC; 
            OUTPUT_TO_CLASSD: OUT sample;--output to class d
            --select_filters:STD_LOGIC_VECTOR( 7 DOWNTO 0 );
            GAIND_Q_OUT: OUT  Gained_result_Array_16);
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
component sd2 is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk :in std_logic; 
         output,add1,add2,latch1 : out std_logic_vector(N-1 downto 0);
         sign: out std_logic);
end component;

-- ADC signals
SIGNAL adc_start  : STD_LOGIC := '0'; -- Start A2D conversion
SIGNAL adc_OE     : STD_LOGIC := '0'; -- ADC finished
SIGNAL adc_output : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- the data from ADC

-- DAC signals
--SIGNAL dac_start  : STD_LOGIC := '0'; -- Start D2A conversion
SIGNAL dac_input  : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
--SIGNAL dac_input_temp  : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ):="111111111111";--should be deleted/anand

-- Equalizer and interface signals
SIGNAL eq_input             : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
--SIGNAL CE_EQ_sig            : STD_LOGIC; -- WHAT IS THIS RUNNING ATT ?
SIGNAL REQ_from_IF_sig      : STD_LOGIC;
SIGNAL GAIN_From_IF_sig     : Gained_result_Array;
SIGNAL OE_FILTERS           : STD_LOGIC; -- to interface 
SIGNAL OUTPUT_TO_CLASSD_sig : sample;
SIGNAL TO_IF_SUM_sig        : Gained_result_Array_16;-- interface will take this 
SIGNAL INTER_Q_sig          : Multi_result_array;
-- 
SIGNAL OE_AMP      : STD_LOGIC:='0';
SIGNAL gain_multiplied_output : Gained_result_Array_16;
SIGNAL Average_if_output: Gained_result_Array_8;
SIGNAL OE_from_average_if : STD_LOGIC;


--signal select_filters_sig :STD_LOGIC_VECTOR( 7 DOWNTO 0 );

--SIGNAL SUMMED : STD_LOGIC_VECTOR(25 DOWNTO 0); 
-- Sigma delta signals
--SIGNAL sd_output         : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
--SIGNAL sd_sign           : STD_LOGIC;

SIGNAL dummy_for_checking_1		 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL dummy_for_checking_2		 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL dummy_for_checking_3		 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL dummy_for_checking_4		 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL sd_input : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );

--------- Begin the architecture sample_system_arch ----------------------
BEGIN

-------------------- Bind the components --------------------------------
adc_comp: new_adc   
    GENERIC MAP( CLOCK_SCALE => 12 )
    PORT MAP( 
              clk   => clk, 
              start => adc_start, 
              OE    => adc_OE, 
              Q     => adc_output, 
              DIN   => ADC_DIN, 
              CS    => ADC_CS, 
              SCK   => ADC_SCK, 
              DOUT  => ADC_DOUT );
                                
--dac_comp: new_dac   
  --  GENERIC MAP( CLOCK_SCALE => 32 )
    --PORT MAP( 
      --        clk   => clk, 
        --      start => dac_start, 
          --    din   => dac_input, 
            --  CS    => DAC_CS, 
              --SCK   => DAC_SCK, 
              --SDI   => DAC_SDI, 
              --LDAC  => DAC_LDAC );
              
-- transmitter_comp : HIF_RS232_Transmit_to_PC
    -- PORT MAP( 
--              port in comp  => Signal
              -- System_clk_Tx   	=> clk, 
              -- RESET_Tx 		    => reset, 
              -- Tx_to_PC 		    => Tx,
              -- flag_Tx 		    => REQ_from_IF_sig,
              -- OE_Tx			    => OE_FILTERS,
              -- gain_array_output =>TO_IF_SUM_sig);

-- Receiver_comp   : HIF_RS232_Receive_from_PC 
    -- PORT MAP( 
              -- System_clk_Rx         => clk, 
              -- reset_rx              => reset, 
              -- serial_data_inp_Rx    => Rx,
              -- gain_data_array_Rx    => GAIN_From_IF_sig);
              
  Receiver_comp   : HIF_RS232_Receive_from_PC 
GENERIC MAP( Serial_word_length => 10 ) --receiving 10 bits start+8 bits of data+stop
   PORT MAP( 
         System_clk_Rx => clk,
         Rx=> Rx,
         reset_rx => reset,
         --OE_Tx => OE_from_average_if,
          flag_Tx =>REQ_from_IF_sig,
		 Gain_array  => GAIN_From_IF_sig
        -- temp_led:OUT STd_LOGIC_vector(7 downto 0)
       );

              
                          

Equalizer_comp : eq_main 
	GENERIC MAP( NUM_OF_SAMPLES => 400,
            NUM_OF_COEFFS => 200,
            NUM_OF_BANDS  => 8)
    PORT MAP( 
              clk  	          => clk, -- System clock (50 MHz)
              reset	          => reset,
              sample_in        => eq_input, -- Changed from sd_input to adc_output
              new_sample_ready => adc_OE,     -- OBS! MAKE SURE THAT adc_OE GIVES INTENDED SIGNAL
              OE		          => OE_FILTERS,    -- to gain 
              Q			       => INTER_Q_sig);
				  
	

--dac_input<= NOT INTER_Q_sig(4)(25) & INTER_Q_sig(4)(24 downto 14);

 Amplifier_COMP :  gain_amplifier
  GENERIC MAP ( NUM_BITS_OUT => 13,
				NUM_OF_GAINS => 8,  
				NUM_OF_FILTERS => 8)
   PORT MAP( clk      => clk,
             reset   => reset,
             FB_OE => OE_FILTERS,
             RAW_OUTPUT =>INTER_Q_sig, -- 1 to 8 of 36 to 0 
			    GAIN =>GAIN_From_IF_sig,
             OE =>OE_AMP,
				 OUTPUT_TO_CLASSD => sd_input, --output to class d
              --   select_filters => select_filters,
             GAIND_Q_OUT => gain_multiplied_output);
             
             
 adding_signals: average_if 
    GENERIC MAP(
            NUM_BITS_OUT => 16,
            NUM_OF_SAMPLES => 200,
            NUM_OF_BANDS => 8)
    PORT MAP( 
            clk     => clk,
            reset   => reset,
            --CE      : IN STD_LOGIC;
            OE_GAINAMP =>OE_AMP,
            REQ      => REQ_from_IF_sig,
            Gained_Samples => gain_multiplied_output,
            OE  => OE_from_average_if,    
            Q    => Average_if_output   ); -- changed down to 8 bits/amit

 
transmit_to_pc: HIF_RS232_Transmit_to_PC 
    GENERIC MAP(n => 8) -- number of bits to be sent for each gain levels
    PORT MAP(
          clk => clk,
               RESET => reset,
                  OE_Tx => OE_from_average_if, --Flag sent by the Equalizer conveying that data filling into 'gain_array_output' is finished
               gain_array_input => Average_if_output,-- 8 blocks x 8 bits of data to be received from Equalizer
                --flag_Tx => REQ_from_IF_sig,--flag to indicate that Eqaulizer can now send the average gain signals
               Tx_to_PC => Tx
        );

 
sd_comp: sd2  
    GENERIC MAP(N => 12)   
    PORT MAP( input => sd_input,
                          clk => clk,
                          output => dummy_for_checking_1,
                          add1   => dummy_for_checking_2,
                          add2   => dummy_for_checking_3,
                          latch1 => dummy_for_checking_4,
                          sign => sd_sign );

                          
--led      <= OE_AMP & eq_input( N-2 DOWNTO 4 ); --shows the input to buffer
--led      <= dac_input( 11 DOWNTO 4 ); --shows the input to buffer
eq_input <= NOT adc_output(N-1) & adc_output(N-2 DOWNTO 0);
--dac_input <= INTER_Q_sig(6)(36 downto 25);

-- Process generating the different frequencies
generate_clock_frequencies: PROCESS ( clk )
    VARIABLE cnt_20kHz  : NATURAL RANGE 0 TO CLK_SCALE_20kHz-1  := 0;
    --VARIABLE cnt_2MHz   : NATURAL RANGE 0 TO CLK_SCALE_2MHz-1  := 0;
BEGIN
	 
	 IF clk'EVENT AND clk = '1' THEN
 -- 20 kHz

      
        IF cnt_20kHz < CLK_SCALE_20kHz-1 THEN
            cnt_20kHz := cnt_20kHz + 1;
            adc_start <= '0';
        --    dac_start <= '0';
        ELSE
            cnt_20kHz := 0;
            adc_start <= '1';
         --   dac_start <= '1';
        END IF;  
           
--       -- IF cnt_2mhz < CLK_SCALE_2mhz-1 THEN 
--          - CE_EQ_sig <= '0';
--           cnt_2mhz := cnt_2mhz + 1;
--        ELSE 
--           cnt_2mhz := 0;
--           CE_EQ_sig <= '1';     
--        END IF;    
    END IF;
END PROCESS generate_clock_frequencies;

--   PROCESS(clk)
--	
--  VARIABLE SUMMED : STD_LOGIC_VECTOR(25 DOWNTO 0):=(others=>'0'); 
--   BEGIN
--	summed:=(others=>'0');
--	
--	FOR k IN 0 TO 7 LOOP -- parallel of 8 additions ?
--   SUMMED := STD_LOGIC_VECTOR(SIGNED(SUMMED) + SIGNED(INTER_Q_sig(k)));
--   END LOOP;	
--	
--	 dac_input <= ( not summed(25)) & summed(24 downto 14);
--
--	end process;
--	
--	
--	   PROCESS(clk)
--	     BEGIN
--	case select_filters is
--	
--                            WHEN "00000001" => 
--                               dac_input<= NOT INTER_Q_sig(0)(25) & INTER_Q_sig(0)(24 downto 14); -- APPROXIMATELY 0-75 SWITCH 0
--                            WHEN "00000010" => 
--                                dac_input<= NOT INTER_Q_sig(1)(25) & INTER_Q_sig(1)(24 downto 14); -- APPROXIMATELY 75-150 SWITCH 1
--                            WHEN "00000100" => 
--                                dac_input<= NOT INTER_Q_sig(2)(25) & INTER_Q_sig(2)(24 downto 14); -- APPROXIMATELY 150-300 SWITCH 2
--                            WHEN "00001000" => 
--                                dac_input<= NOT INTER_Q_sig(3)(25) & INTER_Q_sig(3)(24 downto 14);  -- APPROXIMATELY 300- 600SWITCH 3
--                            WHEN "00010000" => 
--                                dac_input<= NOT INTER_Q_sig(4)(25) & INTER_Q_sig(4)(24 downto 14); -- APPROXIMATELY 600-1200 SWITCH 4
--                            WHEN "00100000" => 
--                                dac_input<= NOT INTER_Q_sig(5)(25) & INTER_Q_sig(5)(24 downto 14); -- APPROXIMATELY 1200-2500 SWITCH 5
--                            WHEN "01000000" => 
--                                dac_input<= NOT INTER_Q_sig(6)(25) & INTER_Q_sig(6)(24 downto 14); -- APPROXIMATELY 2500-5000 SWITCH 6
--                            WHEN "10000000" => 
--                                dac_input<= NOT INTER_Q_sig(7)(25) & INTER_Q_sig(7)(24 downto 14);  -- APPROXIMATELY 5000-10000 SWITCH 7
--                            
--	                         WHEN OTHERS => 
--                                 NULL;
--   END CASE;
--
--	end process; 

END ARCHITECTURE top_main_arch;
