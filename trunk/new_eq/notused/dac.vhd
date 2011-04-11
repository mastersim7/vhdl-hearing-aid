-- dac.vhd
-- Mathias Lundell
-- 101012
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY dac IS
    GENERIC ( 
            CLOCK_SCALE  : NATURAL := 8 ); -- Downscaling of the clock (4 is barely ok)
              
              
    PORT (
            -- Spartan3 ports
            clk  : IN  STD_LOGIC;                      -- FPGA master clock
            start: IN  STD_LOGIC;                      -- start conversion
            din  : IN  STD_LOGIC_VECTOR( 11 DOWNTO 0 );-- data in to ADC
            
            -- DAC interface ports
            CS   : OUT STD_LOGIC; -- Chip Select (active low)
            SCK  : OUT STD_LOGIC; -- Serial Clock Input
            SDI  : OUT STD_LOGIC; -- Serial Data Input
            LDAC : OUT STD_LOGIC);-- Latch DAC Input (active low)
END ENTITY dac;


ARCHITECTURE dac_arch OF dac IS

-- State handling
TYPE     state_type IS ( IDLE, SEND_DATA, UPDATE_DAC_OUTPUT );
SIGNAL   state        : state_type := IDLE;
SIGNAL   next_state   : state_type := IDLE;

CONSTANT NUM_CFG_BITS : NATURAL := 4;      -- Number of config bits to the DAC
CONSTANT NUM_DATA_BITS: NATURAL := 12;     -- Number of data bits to the DAC


-- Config bits
-- bit<3> : Channel select bit, 1 = DACB, 0 = DACA
-- bit<2> : Output gain select bit, 1 = 1x, 0 = 2x
-- bit<1> : Don't care
-- bit<0> : SHDN: Output power down control bit, 0 = output buffer disabled
CONSTANT CONFIG_BITS  : STD_LOGIC_VECTOR( 
            NUM_CFG_BITS - 1 DOWNTO 0 ) := "0101"; -- config bits


SIGNAL   clk_enable   : STD_LOGIC := '0';      -- clock enable for output

-- Data to DAC
SIGNAL   dout         : STD_LOGIC_VECTOR(
            NUM_DATA_BITS+NUM_CFG_BITS - 1 DOWNTO 0 );

-- Begin the architecture dac_arch
BEGIN 


------- Process for downscaling the clock and handling reset -------------
-- 'ckl_enable' is used to update the output from the FPGA to
-- the DAC and is downscaled with a factor 'CLOCK_SCALE'.
-- 'n_sck' is the signal connected to 'SCK', which is the serial clock 
-- input of the DAC. SCK get a rising edge after half the time between the 
-- 'clock_enable's.
scale_clk: PROCESS ( clk )
    VARIABLE cnt : NATURAL RANGE 0 TO CLOCK_SCALE-1 := 0;
BEGIN
    IF rising_edge( clk ) THEN
        IF cnt = 0 THEN
            SCK <= '0';
        ELSIF cnt = (CLOCK_SCALE/2) THEN
            SCK <= '1';
        END IF;
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



-------------- Process communicating with the DAC ----------------------
-- The message to the DAC is 16 bits wide (4 config bits, 12 data bits),
-- MSB -> LSB.
--
-- Using the current starter board of the Spartan3, it is possible to 
-- use 8 input switches, leaving us with 4 extra bits. These are zeroes
-- in this implementation.
-- 
-- Input to DAC is sampled at high level of signal 'start' and then the
-- serial sending commences. When the whole message has been sent the
-- DAC updates it output as 'LDAC' goes low.
dac_interface: PROCESS ( clk )
    VARIABLE started : STD_LOGIC := '0';
    VARIABLE cnt : INTEGER RANGE 0 TO NUM_CFG_BITS+NUM_DATA_BITS := 0;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        -- Catch the start pulse
        IF start = '1' THEN
            started := '1';
        END IF;
        IF clk_enable = '1' THEN
            CASE state IS
                 
                -- Idle state
                WHEN IDLE =>
                    CS   <= '1'; -- no input
                    LDAC <= '1'; -- dac output latest sample
                    cnt  := 0;
                    
                    -- Sample and go to next state
                    IF started = '1' THEN
                        started := '0'; -- reset the started signal
                        next_state <= SEND_DATA;
                        dout <= CONFIG_BITS & din;
                    END IF;
                
                -- State handling which data being sent to DAC
                WHEN SEND_DATA =>
                    
                    -- Send sampled data
                    IF cnt < NUM_CFG_BITS + NUM_DATA_BITS THEN
                        CS  <= '0';            -- start sending flag
                        SDI <= dout( dout'LEFT - cnt );
                        cnt := cnt + 1;
                        
                    -- Update the dac output
                    ELSE
                        CS  <= '1';            -- stop sending flag
                        SDI <= '0';
                        cnt :=  0 ;
                        next_state <= UPDATE_DAC_OUTPUT;
                    END IF;
                
                -- State updating the DAC output
                WHEN UPDATE_DAC_OUTPUT =>
                    -- Pulse the LDAC
                    IF cnt = 0 THEN
                        LDAC <= '0';
                        cnt := cnt + 1;       
                    ELSE
                        LDAC <= '1';
                        next_state <= IDLE;
                    END IF;
            END CASE; -- state
        END IF;       -- clock_enable
    END IF;           -- rising_edge( clk )
END PROCESS dac_interface;
              
END ARCHITECTURE dac_arch;