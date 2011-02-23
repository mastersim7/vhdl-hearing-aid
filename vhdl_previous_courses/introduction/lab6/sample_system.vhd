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
            CLK_SCALE_120khz : NATURAL := 417;
            CLK_SCALE_40kHz  : NATURAL := 1251;
            CLK_SCALE_30kHz  : NATURAL := 1668;
            
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


-- Component to interpolate the signal from ADC (inject zeroes)
COMPONENT interpolater IS
    GENERIC ( N : NATURAL := 12 ); -- Bit length of the vectors
    PORT ( 
            clk       : IN  STD_LOGIC; -- System clock (50 MHz)
            CE        : IN  STD_LOGIC; -- Clock Enable (Input signal of 120 kHz)
            load      : IN  STD_LOGIC; -- Load sample 40 kHz
            sample_in : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            
            OE        : OUT STD_LOGIC;
            sample_out: OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
END COMPONENT;

-- Component for filtering calculations (including lowpass filter and decimation)
COMPONENT fir_filter IS
    GENERIC (   N : NATURAL := 12 ); -- width of samples and filter coefficients
                
    PORT (  clk     : IN  STD_LOGIC;
				x       : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );     -- sample
            reset   : IN  STD_LOGIC;                            -- reset
            start   : IN  STD_LOGIC;                            -- start filter
            
				OE      : OUT STD_LOGIC;
            y       : OUT STD_LOGIC_VECTOR( N-1   DOWNTO 0 ));  -- result
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


SIGNAL adc_start         : STD_LOGIC := '0'; -- Start A2D conversion
SIGNAL adc_OE            : STD_LOGIC := '0'; -- ADC finished
SIGNAL dac_start         : STD_LOGIC := '0'; -- Start D2A conversion
SIGNAL fir_start         : STD_LOGIC := '0'; -- Start fir filtering
SIGNAL fir_reset         : STD_LOGIC := '0'; -- Reset the fir filter
SIGNAL fir_OE            : STD_LOGIC;
SIGNAL interpolater_CE   : STD_LOGIC := '0'; -- Load a sample to the interpolater 
SIGNAL interpolater_start: STD_LOGIC := '0'; -- Start interpolater (interpolate zeroes)
SIGNAL interpolater_OE   : STD_LOGIC := '0'; -- Interpolater has new value on output

SIGNAL adc_output          : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- the data from ADC
SIGNAL interpolater_output : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- data from i.p.
SIGNAL fir_output          : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- data from FIR

SIGNAL bipolar_adc_output  : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- bipolar value
SIGNAL unipolar_fir_output : STD_LOGIC_VECTOR( N-1 DOWNTO 0 ); -- unipolar value

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


interpolater_comp : interpolater 
                GENERIC MAP( N => N )
                PORT MAP( clk        => clk,
                          CE         => interpolater_CE,
                          load       => interpolater_start,
                          sample_in  => bipolar_adc_output,
                          OE         => interpolater_OE,
                          sample_out => interpolater_output );

fir_filter_comp : fir_filter
                GENERIC MAP ( N => N )
                PORT MAP( clk   => clk,
								  x     => interpolater_output,
                          reset => fir_reset,
                          start => fir_start,
								  OE    => fir_OE,
                          y     => fir_output );
                    

                                
dac_comp: dac   GENERIC MAP( CLOCK_SCALE => 32 )
                PORT MAP( clk   => clk, 
                          start => dac_start, 
                          din   => unipolar_fir_output, 
                          CS    => DAC_CS, 
                          SCK   => DAC_SCK, 
                          SDI   => DAC_SDI, 
                          LDAC  => DAC_LDAC );
              

led <= adc_output( N-1 DOWNTO 4 );
bipolar_adc_output  <= (NOT adc_output(N-1)) & adc_output(N-2 DOWNTO 0);
unipolar_fir_output <= (NOT fir_output(N-1)) & fir_output(N-2 DOWNTO 0);


-- Process generating the different frequencies
generate_clock_frequencies: PROCESS ( clk )
    VARIABLE cnt_120kHz : NATURAL RANGE 0 TO CLK_SCALE_120kHz-1 := 0;
    VARIABLE cnt_40kHz  : NATURAL RANGE 0 TO CLK_SCALE_40kHz-1  := 0;
    VARIABLE cnt_30kHz  : NATURAL RANGE 0 TO CLK_SCALE_30kHz-1  := 0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        -- 120 kHz
        IF cnt_120kHz < CLK_SCALE_120kHz-1 THEN
            cnt_120kHz      := cnt_120kHz + 1;
            interpolater_CE <= '0';
            fir_start       <= '0';
        ELSE
            cnt_120kHz      := 0;
            interpolater_CE <= '1';
            fir_start       <= '1';
        END IF;
        
        -- 40 kHz
        IF cnt_40kHz < CLK_SCALE_40kHz-1 THEN
            cnt_40kHz          := cnt_40kHz + 1;
            adc_start          <= '0';
            interpolater_start <= '0';
        ELSE
            cnt_40kHz          := 0;
            adc_start          <= '1';
            interpolater_start <= '1';
        END IF;
        
        -- 30 kHz
        IF cnt_30kHz < CLK_SCALE_30kHz-1 THEN
            cnt_30kHz := cnt_30kHz + 1;
            dac_start <= '0';
        ELSE
            cnt_30kHz := 0;
            dac_start <= '1';
        END IF;
        
    END IF;
END PROCESS generate_clock_frequencies;


END ARCHITECTURE sample_system_arch;