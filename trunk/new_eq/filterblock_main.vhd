-- Description:
-- filterblock_main.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- It is still in the implementation phase. 
-- This files adds needed components together to make a filterbank, you are welcome to make changes but make shure to update the whole chain of files that will be affected

-- 2011-03-30, Mathias Lundell
-- Works essentially in the same way. There is still a simulation error which
-- I believe is constrained to simulation and not implementation on fpga.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;
USE work.EQ_data_type.ALL;

ENTITY filterblock_main IS
	  GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_SAMPLES : NATURAL := 80;
            NUM_OF_COEFFS : NATURAL := 40;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            sample1 : IN sample;            
            sample2 : IN sample;
            updated : IN STD_LOGIC; 
            Q       : OUT Multi_Result_array;
            done    : OUT STD_LOGIC;
            next_sample : OUT STD_LOGIC;
            sample_nr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END filterblock_main;

ARCHITECTURE  filterblock_main_arch OF filterblock_main IS 
-- constants 
CONSTANT CO:taps_type:=(("0000000010000","0000000010101","0000000100011","0000000111001","0000001010100","0000001110010","0000010010000","0000010101001","0000010111011","0000011000101"),
("0000000011110","0000000101000","0000001000100","0000001110001","0000010101001","0000011100111","0000100100100","0000101011001","0000110000000","0000110010101"),
("0000000010101","0000000100000","0000000111011","0000001101001","0000010100110","0000011101110","0000100110111","0000101111001","0000110101011","0000111000101"),
("0000000000011","0000000001100","0000000100100","0000001010001","0000010010110","0000011101111","0000101010001","0000110101110","0000111110111","0001000011111"),
("1111111010010","1111111001111","1111111000111","1111111010111","0000000010110","0000010001111","0000100110111","0000111101101","0001010001001","0001011100011"),
("0000000001100","1111111110011","1111110110100","1111101000011","1111011010000","1111010111101","1111101011111","0000010110000","0001000110100","0001100111000"),
("0000000000100","1111111111011","1111111111110","0000001010011","0000011000001","0000000010000","1111000010000","1110101001110","1111111110011","0001110000100"),
("0000000000011","1111111111010","0000000110011","1111111010011","1111110110001","0000000001001","0000010010101","0000111010101","1101001110000","0001101101100"));




-- components 

-- The samples come from the main main 
-- The Coefficents will be here or in the package 

-- serialfilter component 
COMPONENT serial_filter IS 
  GENERIC(
        NUM_OF_COEFFS : NATURAL := 110);
    PORT( 
        clk     : IN STD_LOGIC;
        reset   : IN STD_LOGIC;
        CO      : IN coefficient_type;
        CE      : IN STD_LOGIC;
        sample1 : IN sample;
        sample2 : IN sample;
        Q	      : OUT Multi_Result);
END COMPONENT;

-- signals 
--SIGNAL CE_FIR1,OE_FIR1,CE_FIR2,OE_FIR2: STD_LOGIC; Not used ?? /shwan
SIGNAL Q_FIR1, Q_FIR2 :  Multi_Result;
SIGNAL CO_FIR1,CO_FIR2 : coefficient_type;

SIGNAL start_filter : STD_LOGIC;

BEGIN 
-- component instantiation 
FIR1:  serial_filter 
    GENERIC MAP (
        NUM_OF_COEFFS => NUM_OF_COEFFS)
    PORT MAP(
        clk => clk,
        reset => updated,
        CO => CO_FIR1,
        CE => start_filter,
        sample1 => sample1,
        sample2 => sample2,
        Q => Q_FIR1);
    
FIR2:  serial_filter
    GENERIC MAP (
        NUM_OF_COEFFS => NUM_OF_COEFFS)
    PORT MAP(
        clk => clk,
        reset => updated,
        CO => CO_FIR2,
        CE => start_filter,
        sample1 => sample1,
        sample2 => sample2,
        Q => Q_FIR2);

PROCESS(clk, updated)
    VARIABLE count : NATURAL RANGE 0 TO NUM_OF_COEFFS;
    VARIABLE count_filters : NATURAL RANGE 0 TO NUM_OF_BANDS+1;
    TYPE state_type IS (IDLE, READ_SAMPLE, UPDATE_FILTER, UPDATE_OUTPUT);
    VARIABLE state : state_type;
    VARIABLE Q_sig : Multi_Result_array;
BEGIN

IF clk'EVENT AND clk = '1' THEN
    IF updated = '1' THEN
        state := READ_SAMPLE;
        count := 0;
        count_filters := 0;
        start_filter <= '0';
        done <= '0';
    ELSE
            CASE (state) IS
                WHEN IDLE =>
                    done <= '0';
                WHEN READ_SAMPLE =>
                    next_sample <= '1';
                    start_filter <= '0';
                    sample_nr <= STD_LOGIC_VECTOR(TO_UNSIGNED(count, 7));
                    state := UPDATE_FILTER;
                    
                WHEN UPDATE_FILTER =>
                    next_sample <= '0';
                    CO_FIR1 <= CO(count_filters, count);
                    CO_FIR2 <= CO(count_filters+1, count);
                    start_filter <= '1';
                    IF count < NUM_OF_COEFFS-1 THEN
                        count := count + 1;
                        state := READ_SAMPLE;
                    ELSE
                        count := 0;
                        state := UPDATE_OUTPUT;
                    END IF;
                    
                WHEN UPDATE_OUTPUT =>
                    Q_sig(count_filters) := Q_FIR1;
                    Q_sig(count_filters+1) := Q_FIR2;
                    start_filter <= '0';
                    IF count_filters < NUM_OF_BANDS-2 THEN
                        count_filters := count_filters + 2; -- since we calculate 2 filters at the time
                        state := READ_SAMPLE;
                    ELSE
                        done <= '1';
                        count_filters := 0;
						Q <= Q_sig;
                        state := IDLE;
                    END IF;
            END CASE;
        END IF;
END IF; --clk
END PROCESS;

END ARCHITECTURE;
