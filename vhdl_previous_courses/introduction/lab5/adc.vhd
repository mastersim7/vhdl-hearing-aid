-- adc.vhd
-- Mathias Lundell
-- 101010
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adc IS
    GENERIC ( 
            CLOCK_SCALE  : NATURAL := 32 ); -- Downscaling of the clock (4 is barely ok)
              
              
    PORT (
            -- Spartan3 ports
            clk  : IN  STD_LOGIC;                     -- FPGA master clock
            start: IN  STD_LOGIC;                     -- start conversion
            led  : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );-- LEDs
            
            -- ADC interface ports
            DIN  : IN  STD_LOGIC;                     -- Data In from ADC
            CS   : OUT STD_LOGIC;                     -- Chip Select (active low)
            SCK  : OUT STD_LOGIC;                     -- Serial Clock Input to ADC
            DOUT : OUT STD_LOGIC);                    -- Serial Data out to ADC
            
END ENTITY adc;


ARCHITECTURE adc_arch OF adc IS
-- State handling
TYPE     state_type IS ( IDLE, SEND_DATA, READ_DATA );
SIGNAL   state        : state_type := IDLE;
SIGNAL   next_state   : state_type := IDLE;

-- Config bits
CONSTANT START_BIT    : STD_LOGIC := '1'; -- Bit which initializes reading
CONSTANT SGL_DIFF     : STD_LOGIC := '1'; -- Single ended (1) or differential mode (0)
CONSTANT ODD_SIGN     : STD_LOGIC := '0'; -- Channel selection
CONSTANT MSBF         : STD_LOGIC := '1'; -- Start with MSB (1), LSB (0)
CONSTANT CONFIG_BITS  : STD_LOGIC_VECTOR := START_BIT & SGL_DIFF & ODD_SIGN & MSBF;

CONSTANT ADC_MESSAGE_LENGTH : NATURAL    := 13; -- Total bit length of message from ADC

-- Internal signal for clock handling
SIGNAL   clk_enable         : STD_LOGIC := '0';-- clock enable for output

-- Begin the architecture dac_arch
BEGIN 

------- Process for downscaling the clock and handling reset -------------
-- 'ckl_enable' is used to update the output from the FPGA to
-- the ADC and is downscaled with a factor 'CLOCK_SCALE'.
-- 'n_sck' is the signal connected to 'SCK', which is the serial clock 
-- input of the ADC. SCK get a rising edge after half the time between the 
-- 'clock_enable's.
scale_clk: PROCESS ( clk )
    VARIABLE cnt : NATURAL RANGE 0 TO CLOCK_SCALE-1 := 0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        -- SCK (external)
        IF cnt = 0 THEN
            SCK <= '0';
        ELSIF cnt = (CLOCK_SCALE/2) THEN
            SCK <= '1';
        END IF;
        
        -- Clock enable (internal)
        IF cnt < CLOCK_SCALE-1 THEN
            cnt := cnt + 1;
            clk_enable <= '0';
        ELSE
            clk_enable <= '1';
            cnt := 0;
        END IF;
    END IF;
END PROCESS scale_clk;
    
    
    
---------- Process updating the current state -----------
update_state: PROCESS ( clk )
BEGIN
    IF clk'EVENT and clk = '1' THEN
        state <= next_state;
    END IF;
END PROCESS update_state;

-------------- Process communicating with the ADC ----------------------
-- The message to the ADC is 4 bits wide (1 start bit, 3 config bits),
-- MSB -> LSB.
-- 
-- After the config bits have been sent, we read the output of the ADC.
-- Since there is only 8 led's on the starter board, we have to discard
-- the last (least significant) bits from the ADC. 
adc_interface: PROCESS ( clk )
    VARIABLE cnt : NATURAL RANGE 0 TO ADC_MESSAGE_LENGTH := 0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        IF clk_enable = '1' THEN
            CASE state IS
                 
                -- Idle state
                WHEN IDLE =>
                    CS  <= '1'; -- no input
                    cnt := 0;
                    
                    -- Go to next state
                    IF start = '1' THEN
                        next_state <= SEND_DATA;
                    END IF;
                
                -- State handling which data being sent to 
                WHEN SEND_DATA =>
                    CS <= '0'; -- start sending flag
                    -- Send config bits to ADC
                    IF cnt < CONFIG_BITS'LENGTH THEN
                        DOUT <= CONFIG_BITS( cnt );
                        cnt  := cnt + 1;
                        
                    -- Go to state reading converted data
                    ELSE
                        DOUT <= '0'; -- send no more config bits 
                        cnt  :=  0;
                        next_state <= READ_DATA;
                    END IF;
                
                -- State updating the DAC output
                WHEN READ_DATA =>
                    -- First bit from ADC is a null bit
                    IF cnt = 0 THEN
                        cnt := cnt + 1;
                    
                    -- Save the digital values (MSB first)
                    ELSIF cnt <= led'LENGTH THEN
                        led(led'LENGTH - cnt) <= DIN;
                        cnt := cnt + 1;
                    ELSIF cnt < ADC_MESSAGE_LENGTH-1 THEN
                        cnt := cnt + 1;
                    ELSE
                        CS <= '1';
                        next_state <= IDLE;
                    END IF;
                    
            END CASE; -- case state
        END IF;       -- clock_enable
    END IF;           -- rising_edge( clk )
END PROCESS adc_interface;
              
END ARCHITECTURE adc_arch;
