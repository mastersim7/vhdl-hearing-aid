-- tb_adc.vhd
-- Mathias Lundell
-- 2010-10-11
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_adc IS
END ENTITY;

ARCHITECTURE tb_adc_behavioral OF tb_adc IS
    COMPONENT adc IS
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
    END COMPONENT;
    
    SIGNAL clk  : STD_LOGIC := '0';
    SIGNAL start: STD_LOGIC := '0';
    SIGNAL led  : STD_LOGIC_VECTOR( 7 DOWNTO 0 ) := (OTHERS => '0');
    
    SIGNAL din  : STD_LOGIC;
    SIGNAL cs   : STD_LOGIC;
    SIGNAL sck  : STD_LOGIC;
    SIGNAL dout : STD_LOGIC;
    
BEGIN
    clk <= NOT clk AFTER 10 ns;
    
    adc_comp: adc GENERIC MAP( CLOCK_SCALE => 64 )
                  PORT MAP( clk, start, led, din, cs, sck, dout );
    
    PROCESS
        -- All constants are for Vdd = 5.5 V, clock frequency = 1.8 MHz
        CONSTANT t_sucs : TIME := 100 ns; -- CS fall to first rising sck edge (min)
        CONSTANT t_su   : TIME :=  50 ns; -- Data input setup hold time (max)
        CONSTANT t_hd   : TIME :=  50 ns; -- Data input hold time (max)
        CONSTANT t_hi   : TIME := 250 ns; -- SCK high time (min)
        CONSTANT t_lo   : TIME := 250 ns; -- SCK low  time (min)
        CONSTANT t_en   : TIME := 200 ns; -- Clock fall to output enable (max)
        CONSTANT t_do   : TIME := 200 ns; -- Clock fall to output data valid (max)
        CONSTANT t_dis  : TIME := 100 ns; -- CS rise to output disable
        
        CONSTANT response : STD_LOGIC_VECTOR( 12 DOWNTO 0 ) := '0' & "110111001001";
    BEGIN
        din <= 'Z'; -- High impedence state
        WAIT FOR 400 ns;
        start <= '1';
        
        
        -- Test clock frequency limitations
        WAIT UNTIL falling_edge( sck );
        WAIT FOR t_lo;
        ASSERT sck'QUIET(t_lo)
            REPORT "SCK has too short low time (1.8MHz)"
            SEVERITY note;
        WAIT FOR t_lo;
        ASSERT sck'QUIET(t_lo*2)
            REPORT "SCK has too short low time (0.9MHz)"
            SEVERITY note;
        
        
        -- Wait for falling edge cs, sck must not rise too soon
        -- Dout must be stable before rising edge sck
        WAIT UNTIL falling_edge( cs );
        WAIT UNTIL rising_edge( sck );
        ASSERT cs'LAST_EVENT >= t_sucs
            REPORT "sck has a rising edge too soon after cs"
            SEVERITY note;
        ASSERT dout = '1'
            REPORT "dout should have been high here, start bit"
            SEVERITY error;
        ASSERT dout'QUIET( t_su )
            REPORT "dout isn't stable long enough before rising edge sck"
            SEVERITY note;
        
        -- Read the last three config bits 
        FOR i IN 1 TO 3 LOOP
            WAIT UNTIL rising_edge( sck );
            ASSERT cs = '0'
                REPORT "CS goes high in between the config bits"
                SEVERITY error;
        END LOOP;
        
        -- Send response
        FOR i IN 12 DOWNTO 0 LOOP
            WAIT UNTIL falling_edge( sck );
            IF i = 12 THEN
                din <= response(i) AFTER t_en;
            ELSE
                din <= response(i) AFTER t_do;
            END IF;
        END LOOP;
        
        
        WAIT UNTIL rising_edge( sck ); -- last value gets sampled
        WAIT UNTIL rising_edge( sck ); -- last value should be updated
        ASSERT cs = '1'
            REPORT "CS doesn't go high first sck rising edge, after communication"
            SEVERITY warning;
            
        -- FPGA should rise the cs signal now that communication is finished
        WAIT UNTIL rising_edge( cs );
        
        -- Input to ADC is high impedance when CS is high
        din <= 'Z' AFTER t_dis;
        
        WAIT FOR 20 ns;
        start <= '0';
        
        WAIT FOR 400 ns;
        
        -- Control output
        ASSERT led = "11011100"
            REPORT "led has the wrong value!!"
            SEVERITY warning;
        
        WAIT FOR 400 ns;
    END PROCESS;
END ARCHITECTURE tb_adc_behavioral;
        
        