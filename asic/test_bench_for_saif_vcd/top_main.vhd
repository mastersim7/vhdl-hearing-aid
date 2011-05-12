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
         
            CLK_SCALE_20khz : NATURAL := 1000;
            
            N : NATURAL := 12 ); -- Bit length of the data vectors
            
    PORT (
            -- Spartan3 ports
            clk     : IN  STD_LOGIC;                     -- FPGA master clock
            --led     : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );-- LEDs
            reset   : IN STD_LOGIC;
            sample_in    : IN  sample;
            new_sample_ready : IN STD_LOGIC;
                 
            
	    sd_sign : OUT STD_LOGIC			
            );-- Latch DAC
         
END ENTITY top_main;

ARCHITECTURE top_main_arch OF top_main IS

constant temp_gains : Gained_result_Array := ( "0111111111111" ,"0111111111111","0111111111111","0111111111111","0111111111111","0111111111111","0111111111111","0111111111111");

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

component sd2 is
    generic ( N : integer:= 12);
  port ( input :in std_logic_vector(N-1 downto 0); 
         clk :in std_logic; 
         output,add1,add2,latch1 : out std_logic_vector(N-1 downto 0);
         sign: out std_logic);
end component;



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

              

              
                          

Equalizer_comp : eq_main 
	GENERIC MAP( NUM_OF_SAMPLES => 200,
            NUM_OF_COEFFS => 100,
            NUM_OF_BANDS  => 8)
    PORT MAP( 
              clk  	          => clk, -- System clock (50 MHz)
              reset	          => reset,
              sample_in        => sample_in, 
              new_sample_ready => new_sample_ready,    
              OE		          => OE_FILTERS,     
              Q			       => INTER_Q_sig);
				  
	



 Amplifier_COMP :  gain_amplifier
  GENERIC MAP ( NUM_BITS_OUT => 13,
				NUM_OF_GAINS => 8,  
				NUM_OF_FILTERS => 8)
   PORT MAP( clk      => clk,
             reset   => reset,
             FB_OE => OE_FILTERS,
             RAW_OUTPUT =>INTER_Q_sig, -- 1 to 8 of 36 to 0 
			    GAIN =>temp_gains,
             OE =>OE_AMP,
				 OUTPUT_TO_CLASSD => sd_input, --output to class d
              --   select_filters => select_filters,
             GAIND_Q_OUT => gain_multiplied_output);
             
             


 

 
sd_comp: sd2  
    GENERIC MAP(N => 12)   
    PORT MAP( input => sd_input,
                          clk => clk,
                          output => dummy_for_checking_1,
                          add1   => dummy_for_checking_2,
                          add2   => dummy_for_checking_3,
                          latch1 => dummy_for_checking_4,
                          sign => sd_sign );

                          



END ARCHITECTURE top_main_arch;
