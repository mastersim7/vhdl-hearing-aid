-- sample_system.vhd
-- Mathias Lundell
-- 101013-15:39
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sample_system IS 
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
            led     : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );-- LEDs
            
            -- Interfacing ports
            ADC_DIN : IN  STD_LOGIC; -- Data Input from ADC
            ADC_CS  : OUT STD_LOGIC; -- Chip Select ADC
            ADC_SCK : OUT STD_LOGIC; -- Serial Clock ADC
            ADC_DOUT: OUT STD_LOGIC; -- Data Out to ADC
            
            DAC_CS  : OUT STD_LOGIC; -- Chip Select DAC
            DAC_SCK : OUT STD_LOGIC; -- Serial Clock DAC
            DAC_SDI : OUT STD_LOGIC; -- Serial Data to DAC
            DAC_LDAC: OUT STD_LOGIC);-- Latch DAC
         
END ENTITY sample_system;

ARCHITECTURE sample_system_arch OF sample_system IS


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

COMPONENT SD IS
    PORT(
         input : in std_logic_vector(11 downto 0); 
         clk,reset :in std_logic; 
         output : out std_logic_vector(11 downto 0);
         sign: out std_logic);
END COMPONENT;

SIGNAL adc_start         : STD_LOGIC := '0'; -- Start A2D conversion
SIGNAL adc_OE            : STD_LOGIC := '0'; -- ADC finished

SIGNAL dac_start         : STD_LOGIC := '0'; -- Start D2A conversion
SIGNAL dac_input		    : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );

SIGNAL adc_output        : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- the data from ADC
SIGNAL sd_output         : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL sd_sign           : STD_LOGIC;
SIGNAL sd_sign_concd		 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
SIGNAL sd_input			 : STD_LOGIC_VECTOR( N-1 DOWNTO 0 );

--------- Begin the architecture sample_system_arch ----------------------
BEGIN

-------------------- Bind the components --------------------------------
adc_comp: adc   GENERIC MAP( CLOCK_SCALE => 32 )
                PORT MAP( clk   => clk, 
                          start => adc_start, 
                          OE    => adc_OE, 
                          Q     => adc_output, 
                          DIN   => ADC_DIN, 
                          CS    => ADC_CS, 
                          SCK   => ADC_SCK, 
                          DOUT  => ADC_DOUT );
                                
dac_comp: dac   GENERIC MAP( CLOCK_SCALE => 32 )
                PORT MAP( clk   => clk, 
                          start => dac_start, 
                          din   => dac_input, 
                          CS    => DAC_CS, 
                          SCK   => DAC_SCK, 
                          SDI   => DAC_SDI, 
                          LDAC  => DAC_LDAC );
              
sd_comp: sd     PORT MAP( input => sd_input,
                          clk => clk,
								  reset => '0',
								  output => sd_output,
								  sign => sd_sign );
                          
led <= adc_output( N-1 DOWNTO 4 );
sd_sign_concd <= '0' & sd_sign & "0000000000";
sd_input <= NOT adc_output(N-1) & adc_output(N-2 DOWNTO 0);

-- Process generating the different frequencies
generate_clock_frequencies: PROCESS ( clk )
    VARIABLE cnt_20kHz  : NATURAL RANGE 0 TO CLK_SCALE_20kHz-1  := 0;
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
				dac_input <= sd_sign_concd;
        END IF;       
    END IF;
END PROCESS generate_clock_frequencies;


END ARCHITECTURE sample_system_arch;