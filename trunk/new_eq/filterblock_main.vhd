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
CONSTANT CO:taps_type:=(("111111111111101111011111","000000000001001101011111","000000000010100110111100","000000000001110111001100","111111111110110101101001","111111111100001100111110","111111111100110001101110","111111111111110010100010","000000000001010000100110","111111111111011101000011","111111111110011110001001","000000000011001110000111","000000001010101100111101","000000001010101001110110","111111111110011010011111","111111110000001100010001","111111101111001010101010","111111111011110001101101","000000000101010000111001","000000000000001100110101","111111111001001111011110","000000000101111000001101","000000100001111001100010","000000101010011011001100","000000000111011111110001","111111010011000001101010","111111000010110000001010","111111100110001111001101","000000001110000011001110","000000001000001011010110","111111101010111101001011","000000000010001010000011","000001100001010010011001","000010100100100011101010","000001001101010111011000","111101101010011100100001","111010111110100111110010","111100010000001110010110","000001001000111010110100","000101100101101100011001"),
("111111111111100010101111","111111111111100100011110","000000000000000010000100","000000000000111110000010","000000000010010001000001","000000000011100110010010","000000000100011100010011","000000000100001100111100","000000000010011100011110","111111111111001010111001","111111111010111110101101","111111110111000001010010","111111110100101001011110","111111110100111001011100","111111110111111100110110","111111111100110111110001","000000000001110011001100","000000000100101000100111","000000000011111111110110","000000000000000110011000","111111111011000100011110","111111111000011101101110","111111111011111101101111","000000000111101001101011","000000011010011111111100","000000101111110011000010","000000111111111100110011","000001000010101001010101","000000110001110101011000","000000001100100001010110","111111011000010011110111","111110100000111001100010","111101110101011001000010","111101100100000010110110","111101110101101101011000","111110101010011100100011","111111111000100100001111","000001001110100110010100","000010010111110001010011","000011000001101110001000"),
("111111111111101010011100","111111111111011110001110","111111111111010101101010","111111111111010011010100","111111111111011011001010","111111111111110010011011","000000000000011111000111","000000000001100110111010","000000000011001101110001","000000000101010100010110","000000000111110110011110","000000001010101010000000","000000001101011110010101","000000001111111100110001","000000010001101010000000","000000010010001000010101","000000010000111011000010","000000001101101010000100","000000001000000110000000","000000000000001011100111","111111110110000110100110","111111101010010011000000","111111011101011101000011","111111010000011111000000","111111000100011101010111","111110111010100001011001","111110110011110010100010","111110110001001111010111","111110110011100110100111","111110111011010001010100","111111001000001110011111","111111011010000001000101","111111101111110000011111","000000001000001011110001","000000100001101111010101","000000111010101100100101","000001010001010011000101","000001100011111010000001","000001110001001001010111","000001111000000001101010"),
("111111111111110111101010","111111111111001001111111","111111111110010110010011","111111111101011000011000","111111111100001100011001","111111111010101111000100","111111111000111110000101","111111110110111000010010","111111110100011101110111","111111110001110000100011","111111101110110011101001","111111101011101100000001","111111101000100000000100","111111100101010111100000","111111100010011011001000","111111011111110100100000","111111011101101101101000","111111011100010000011101","111111011011100110100001","111111011011111000011011","111111011101001101100001","111111011111101011010110","111111100011010101011011","111111101000001100111001","111111101110010000010110","111111110101011011101110","111111111101101000010100","000000000110101100110101","000000010000011101101011","000000011010101101001101","000000100101001100001000","000000101111101010000001","000000111001110101110010","000001000011011110010010","000001001100010010111001","000001010100000100000110","000001011010100011111111","000001011111100110110010","000001100011000011010010","000001100100110011001010"),
("111111111001100001000111","111111111001100110001110","111111111001011111110100","111111111001001111110110","111111111000111000101110","111111111000011101001111","111111111000000000100000","111111110111100101110110","111111110111010000110010","111111110111000100111000","111111110111000101101001","111111110111010110011110","111111110111111010100011","111111111000110100101110","111111111010000111011110","111111111011110100110011","111111111101111110001011","000000000000100100100000","000000000011101000000001","000000000111001000010101","000000001011000100011011","000000001111011010100011","000000010100001000010111","000000011001001010111001","000000011110011110101000","000000100011111111100001","000000101001101001001001","000000101111010110101010","000000110101000011000010","000000111010101001000100","000001000000000011011101","000001000101001101000001","000001001010000000101100","000001001110011001101010","000001010010010011100000","000001010101101010001101","000001011000011010010101","000001011010100001000001","000001011011111100000011","000001011100101001111100"),
("111111111111001011011111","111111111111011010010000","111111111111101000111010","111111111111111001000110","000000000000001100011111","000000000000100100101011","000000000001000011001101","000000000001101001011111","000000000010011000110100","000000000011010010010101","000000000100010111000010","000000000101100111101100","000000000111000100111000","000000001000101110111101","000000001010100110000100","000000001100101010000110","000000001110111010101110","000000010001010111011000","000000010011111111010001","000000010110110001011000","000000011001101100011111","000000011100101111001101","000000011111110111111101","000000100011000101000000","000000100110010100100000","000000101001100100100000","000000101100110010111110","000000101111111101110111","000000110011000011000100","000000110110000000100011","000000111000110100010001","000000111011011100010010","000000111101110110110000","000001000000000001111110","000001000001111100011000","000001000011100100100101","000001000100111001011010","000001000101111001111010","000001000110100101010100","000001000110111011001001"),
("000000000011000100011111","000000000011001011100000","000000000011011001111011","000000000011110000000010","000000000100001110000011","000000000100110100000110","000000000101100010001111","000000000110011000011111","000000000111010110101110","000000001000011100110100","000000001001101010100000","000000001010111111100000","000000001100011011011011","000000001101111101110100","000000001111100110001001","000000010001010011110110","000000010011000110010010","000000010100111100110001","000000010110110110100100","000000011000110010111001","000000011010110000111011","000000011100101111110110","000000011110101110110001","000000100000101100110110","000000100010101001001011","000000100100100010111000","000000100110011001000111","000000101000001011000000","000000101001110111101111","000000101011011110100000","000000101100111110100011","000000101110010111001011","000000101111100111101110","000000110000101111100100","000000110001101110001100","000000110010100011001000","000000110011001101111101","000000110011101110010111","000000110100000100000111","000000110100001111000001"),
("000000000001111000001110","000000000001111010100100","000000000010000001010000","000000000010001100010011","000000000010011011101000","000000000010101111001011","000000000011000110110011","000000000011100010011000","000000000100000001110000","000000000100100100101110","000000000101001011000110","000000000101110100100111","000000000110100001000001","000000000111010000000100","000000001000000001011011","000000001000110100110100","000000001001101001111010","000000001010100000010110","000000001011010111110100","000000001100001111111101","000000001101001000011001","000000001110000000110011","000000001110111000110010","000000001111110000000001","000000010000100110001000","000000010001011010110010","000000010010001101101001","000000010010111110010111","000000010011101100101010","000000010100011000001110","000000010101000000110001","000000010101100110000011","000000010110000111110100","000000010110100101110110","000000010110111111111110","000000010111010101111111","000000010111100111110010","000000010111110101001110","000000010111111110001111","000000011000000010110000"));


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
