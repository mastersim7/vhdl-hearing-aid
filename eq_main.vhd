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
            NUM_OF_BANDS  : NATURAL := 6);
    PORT( 
            clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  sample;
            new_input_ready : IN STD_LOGIC;
            Q : OUT STD_LOGIC_VECTOR(36 DOWNTO 0));-- interface will take this 
END eq_main;

ARCHITECTURE  eq_main_arch OF eq_main IS 


COMPONENT regular_buffer IS
     GENERIC ( N        : NATURAL := 12;    -- Bit length of the vectors
              NUM_OF_TAPS : NATURAL := 220 );  -- Number of taps
    
    PORT ( 
            clk          : IN  STD_LOGIC; -- System clock (50 MHz)
            reset        : IN  STD_LOGIC; -- reset
            sample_in    : IN  sample;
            nr           : IN  STD_LOGIC_VECTOR(6 DOWNTO 0); -- nr of sample to read
            RE           : IN  STD_LOGIC;
            WE           : IN  STD_LOGIC;
            updated      : OUT STD_LOGIC;
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
            sample1 : IN sample;
            sample2 : IN sample;
            updated : IN STD_LOGIC;
            Q       : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
            done    : OUT STD_LOGIC;
            next_sample : OUT STD_LOGIC;
            sample_nr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END COMPONENT;

SIGNAL sample_filter1, sample_filter2 : sample;
SIGNAL update_filters : STD_LOGIC;
SIGNAL done : STD_LOGIC;
SIGNAL sample_nr : STD_LOGIC_VECTOR( 6 DOWNTO 0 );
SIGNAL next_sample : STD_LOGIC;
SIGNAL output_from_filters : STD_LOGIC_VECTOR(36 DOWNTO 0);

BEGIN

--Instantiation
buffer_comp: regular_buffer 
    PORT MAP(
            clk          => clk, -- System clock (50 MHz)
            reset        => reset, -- reset
            sample_in    => sample_in,
            nr           => sample_nr,
            RE           => next_sample,
            WE           => new_input_ready,
            updated      => update_filters,
            sample_out_1 => sample_filter1,
            sample_out_2 => sample_filter2
            );

FILTER_BLOCK_MAIN: filterblock_main 
    PORT MAP( 
            clk     => clk,
            reset   => reset,
            sample1 => sample_filter1,
            sample2 => sample_filter2,
            updated => update_filters, 
            Q       => output_from_filters,
            done    => done,
            next_sample => next_sample,
            sample_nr => sample_nr);
	           
process(clk)
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        IF done = '1' THEN
            Q <= output_from_filters;
        END IF;
    END IF;
END PROCESS;

END ARCHITECTURE;










          



