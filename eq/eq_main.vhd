-- eq_main.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- It is still in the implementation phase. 
 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY eq_main IS
	  GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_SAMPLES : NATURAL := 200;
				NUM_OF_COEFFS : NATURAL := 110;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            WE           : IN  STD_LOGIC;
			   CE      : IN STD_LOGIC;
            updated: IN STD_LOGIC;
           
  			  REQ     :IN STD_LOGIC; -- from interface 
   			OUTPUT_TO_CLASSD:OUT sample; 
				OE      : OUT STD_LOGIC; -- to interface 
				Q       : OUT Gained_result_Array_16
           
           
		    );
END eq_main;

ARCHITECTURE  eq_main_arch OF eq_main IS 


COMPONENT regular_buffer IS
    GENERIC ( N        : NATURAL := 12;    -- Bit length of the vectors
              NUM_OF_TAPS : NATURAL := 220 );  -- Number of taps
    
    PORT (  clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            CE		       : IN STD_LOGIC;
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
            sample_out_1 : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
            sample_out_2 : OUT STD_LOGIC_VECTOR( N-1 DOWNTO 0 ));
END COMPONENT;

COMPONENT filterblock_main IS
	  GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_SAMPLES : NATURAL := 200;
				NUM_OF_COEFFS : NATURAL := 110;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            updated: IN STD_LOGIC;
		      RE      : OUT STD_LOGIC;
            OE      : OUT STD_LOGIC; 
	         Q2       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0);
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END COMPONENT;

COMPONENT gain_amplifier IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 13; --mathias is this number ok?
            NUM_OF_GAINS : NATURAL := 8;
            NUM_OF_FILTERS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
				reset   : IN STD_LOGIC;
            RAW_OUTPUT : IN extended_sample; --13 bits
            GAIN : IN extended_sample;
            --SUMMED_OUT_TO_AVERAGE : OUT extended_sample;
            OE      : OUT STD_LOGIC; 
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-2 DOWNTO 0));
END COMPONENT;

COMPONENT average_if IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 16;
            NUM_OF_SAMPLES : NATURAL := 200;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            REQ     :IN STD_LOGIC;
				reset   :IN STD_LOGIC;
            Gained_Samples: IN Gained_result_Array_16; --an 8 array of 16 bit vectors
            OE      : OUT STD_LOGIC; 
				OUTPUT_TO_CLASSD:
            Q       : OUT Gained_result_Array_16);
END COMPONENT;

-- between adc and regular buffer 



-- between regular buffer and filterblock_main
signal sample_out_1 : sample;
signal sample_out_2 : sample;
signal RE_FI_Block_Main :STD_LOGIC;
signal OE_FI_Block_Main :STD_LOGIC;

-- between filterblock_main and gain amp --- lot tobe added 

signal Q2_FI_Block_Main:extended_sample;
signal Q_FI_Block_Main:extended_sample;

-- between gain_amplifier and  average if 
signal Gained_Samples_out :Gained_result_Array_16;


begin
--Instantiation
BUFFER_REGULAR: regular_buffer PORT MAP(clk,reset,sample_in,CE re we     ,sample_out_1,sample_out_2);

FILTERBLOCK_MAIN: filterblock_main PORT MAP( clk,reset,CE,sample_out_1,sample_out_2,updated,RE_FI_Block_Main,OE_FI_Block_Main,Q2_FI_Block_Main,Q_FI_Block_Main);
	           
GAIN_AMPLIFIER :gain_amplifier PORT MAP( clk,CE,reset,       OUTPUT_TO_CLASSD);

AVERAGE_IF : average_if PORT MAP (clk,CE,REQ,reset,Gained_Samples_out,OE,Q);




          



