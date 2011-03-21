-- adc.vhd
-- Mathias Lundell
-- 101012
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY adc IS
    GENERIC ( 
            CLOCK_SCALE  : NATURAL := 32 ); -- Downscaling of the clock (4 is barely ok)
              
              
    PORT (
            -- Spartan3 ports
            clk   : IN  STD_LOGIC;             -- FPGA master clock
            start : IN  STD_LOGIC;             -- start conversion
            OE    : OUT STD_LOGIC;             -- conversion finished
            Q     : OUT STD_LOGIC_VECTOR( 11 DOWNTO 0 ); -- converted Q
            
            -- ADC interface ports
            DIN  : IN  STD_LOGIC;                     -- Serial Data from ADC to FPGA
            CS   : OUT STD_LOGIC;                     -- Chip Select (active low)
            SCK  : OUT STD_LOGIC;                     -- Serial Clock Input to ADC
            DOUT : OUT STD_LOGIC);                    -- Data to ADC                    
            
END ENTITY adc;


ARCHITECTURE adc_arch OF adc IS
-- State handling
TYPE     state_type IS ( IDLE, SEND_DATA, READ_DATA_MSB, READ_DATA_LSB );
SIGNAL   state        : state_type := IDLE;
SIGNAL   next_state   : state_type := IDLE;

-- Config bits
CONSTANT START_BIT    : STD_LOGIC := '1'; -- Bit which initializes reading
CONSTANT SGL_DIFF     : STD_LOGIC := '1'; -- Single ended (1) or differential mode (0)
CONSTANT ODD_SIGN     : STD_LOGIC := '0'; -- Channel selection
CONSTANT MSBF         : STD_LOGIC := '1'; -- Start with MSB (1), LSB (0)
CONSTANT CONFIG_BITS  : STD_LOGIC_VECTOR := START_BIT & SGL_DIFF & ODD_SIGN & MSBF;

-- Total bit length of message from ADC (including null bit)
CONSTANT ADC_MESSAGE_LENGTH : NATURAL    := 13; 

-- Internal signal for clock handling
SIGNAL   clk_enable         : STD_LOGIC  := '0';-- clock enable for output

-- Begin the architecture dac_arch
BEGIN 

------- Process for downscaling the clock and handling reset -------------
-- 'ckl_enable' is used to update the output from the FPGA to
-- the ADC and is downscaled with a factor 'CLOCK_SCALE'.
-- SCK get a rising edge after half the time between the 
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
    VARIABLE started : STD_LOGIC := '0';
    VARIABLE finished: STD_LOGIC := '0';
    VARIABLE cnt : NATURAL RANGE 0 TO ADC_MESSAGE_LENGTH := 0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
    
        -- Catch the start signal pulse
		IF start = '1' THEN
            started := '1';
        END IF;
        
        -- Communicate with the ADC
        IF clk_enable = '1' THEN
            CASE state IS
                 
                -- Idle state
                WHEN IDLE =>
                    CS  <= '1'; -- no input
                    cnt := 0;
                    finished := '0';
                    
                    -- Go to next state                                                                                           
                    IF started = '1' THEN
                        started := '0';
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
                        next_state <= READ_DATA_MSB;
                    END IF;
                
                -- State saving the digital value in format MSBF,
                -- also redirecting to READ_DATA_LSB if flag MSBF='0'
                WHEN READ_DATA_MSB =>
                    -- First bit from ADC is a null bit
                    IF cnt = 0 THEN
                        cnt := cnt + 1;

                    -- Save the digital in MSBF format
                    ELSIF cnt < Q'LENGTH THEN
                        Q(Q'LENGTH - cnt) <= DIN;
                        cnt := cnt + 1;
                    ELSE
                        Q(0) <= DIN;
                        IF MSBF = '1' THEN
                            CS <= '1';
                            next_state <= IDLE;
                            finished := '1';
                        ELSE
                            cnt := 1;
                            next_state <= READ_DATA_LSB;
                        END IF;
                    END IF;
                
                -- State saving the digital value in LSB first format
                WHEN READ_DATA_LSB =>
                    IF cnt < Q'LENGTH THEN
                        Q(cnt) <= DIN;
                        cnt := cnt + 1;
                        IF cnt = Q'LENGTH THEN
                           CS <= '1';
                           finished := '1';
                           next_state <= IDLE;
                        END IF;
                    END IF; 
            END CASE; -- case state
        END IF;       -- clock_enable
        
        -- Send a pulse out that conversion finished
        IF finished = '1' THEN
            finished := '0';
            OE <= '1';
        ELSE
            OE <= '0';
        END IF;
    END IF;           -- rising_edge( clk )
END PROCESS adc_interface;

END ARCHITECTURE adc_arch;
