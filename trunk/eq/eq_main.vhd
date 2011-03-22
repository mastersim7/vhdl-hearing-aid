-- eq_main.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- It is still in the implementation phase. 

-- 2011-03-22
-- Changed some of the formatting
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY eq_main IS
	GENERIC(
            NUM_BITS_OUT  : NATURAL := 13;
            NUM_OF_SAMPLES: NATURAL := 200;
            NUM_OF_COEFFS : NATURAL := 110;
            NUM_OF_BANDS  : NATURAL := 8);
    PORT( 
            clk         : IN STD_LOGIC; -- System clock (50 MHz)
            reset       : IN STD_LOGIC; -- reset
            sample_in   : IN sample;
            WE          : IN STD_LOGIC;
            CE          : IN STD_LOGIC;
            --updated: IN STD_LOGIC;
            GAIN        : IN Gain_Array; --needs to be resetted to 1 for all bands from the iF   8 1 of 12 0 -- interface will give it
            REQ         : IN STD_LOGIC; -- from interface 
            
            OUTPUT_TO_CLASSD: OUT sample; 
            OE              : OUT STD_LOGIC; -- to interface 
            Q_SUM           : OUT Gained_result_Array_16);-- interface will take this 
END eq_main;

ARCHITECTURE  eq_main_arch OF eq_main IS 


COMPONENT regular_buffer IS
     GENERIC ( N        : NATURAL := 12;    -- Bit length of the vectors
              NUM_OF_TAPS : NATURAL := 220 );  -- Number of taps
    
    PORT (  clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN sample;
            CE		 : IN STD_LOGIC;
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
            UPDATED      : OUT STD_LOGIC;
            sample_out_1 : OUT sample;
            sample_out_2 : OUT sample);
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
            updated : IN STD_LOGIC;
		    RE      : OUT STD_LOGIC;
            OE      : OUT STD_LOGIC; 
            Q       : OUT Multi_Result_array);
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
            FB_OE   : IN STD_LOGIC;
            RAW_OUTPUT : IN Multi_Result_array ;--array (7 downto 0) of extended_sample; --13 bits
            GAIN : IN Gain_Array;
            OE      : OUT STD_LOGIC; 
            OUTPUT_TO_CLASSD: OUT sample;--output to class d
            GAIND_Q_OUT: OUT  Gained_result_Array_16);
END COMPONENT;

COMPONENT average_if IS
     GENERIC(
            NUM_BITS_OUT : NATURAL := 16;
            NUM_OF_SAMPLES : NATURAL := 200;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   :IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            OE_GAINAMP : IN STD_LOGIC;
            REQ     :IN STD_LOGIC;
            Gained_Samples: IN Gained_result_Array_16; --an 8 array of 16 bit vectors
            OE      : OUT STD_LOGIC; 
            Q       : OUT Gained_result_Array_16);
END COMPONENT;

-- between adc and regular buffer 



-- between regular buffer and filterblock_main
signal sample_out_1_sig : sample;
signal sample_out_2_sig : sample;
signal RE_FI_Block_Main_sig :STD_LOGIC;
signal OE_FI_Block_Main_sig :STD_LOGIC;
signal UPDATED_sig:STD_LOGIC;

-- between filterblock_main and gain amp --- lot tobe added 


signal Q_FI_Block_Main:multi_result_array;

-- between gain_amplifier and  average if 
signal Gained_Samples_out :Gained_result_Array_16;
signal OE_FromGAIN_sig: std_logic;
signal GAIND_Q_OUT_sig: Gained_result_Array_16;
begin

--Instantiation
BUFFER_REGULAR: regular_buffer 
    PORT MAP(
            clk => clk,
            reset => reset,
            sample_in => sample_in ,
            CE => CE,
            RE => RE_FI_Block_Main_sig,
            WE => WE,
            OE => UPDATED_sig,
            sample_out_1 => sample_out_1_sig,
            sample_out_2 => sample_out_2_sig);

FILTER_BLOCK_MAIN: filterblock_main 
    PORT MAP( 
            clk => clk,
            reset => reset,
            CE => CE,
            sample1 => sample_out_1_sig,
            sample2 => sample_out_2_sig,
            updated => UPDATED_sig,
            RE => RE_FI_Block_Main_sig,
            OE => OE_FI_Block_Main_sig,
            Q  => Q_FI_Block_Main);
	           
GAIN_AMPLIFIER_BLOCK :gain_amplifier 
    PORT MAP(
            clk => clk,
            CE => CE,
            reset => reset,
            FB_OE => OE_FI_Block_Main_sig,
            RAW_OUTPUT => Q_FI_Block_Main,
            GAIN => GAIN,
            OE => OE_FromGAIN_sig,
            OUTPUT_TO_CLASSD => OUTPUT_TO_CLASSD,
            GAIND_Q_OUT => GAIND_Q_OUT_sig);

AVERAGE_INTERFACE : average_if 
    PORT MAP (
            clk => clk,
            reset => reset,
            CE => CE,
            OE_GAINAMP => OE_FromGAIN_sig,
            REQ => REQ,
            GAIND_Q_OUT_sig,
            OE => OE,
            Q => Q_SUM);
end;











          



