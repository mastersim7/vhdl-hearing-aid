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
            NUM_BITS_OUT : NATURAL;
            NUM_OF_SAMPLES : NATURAL ;
            NUM_OF_COEFFS : NATURAL ;
            NUM_OF_BANDS: NATURAL );
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
CONSTANT CO:taps_type:=(("0000011000100","0000011000111","0000011001001","0000011001011","0000011001101","0000011001111","0000011010000","0000011010001","0000011010010","0000011010010","0000011010010","0000011010010","0000011010001","0000011010000","0000011001111","0000011001101","0000011001011","0000011001001","0000011000111","0000011000100"),
("0000011000001","0000011000110","0000011001011","0000011001111","0000011010010","0000011010101","0000011010111","0000011011001","0000011011010","0000011011011","0000011011011","0000011011010","0000011011001","0000011010111","0000011010101","0000011010010","0000011001111","0000011001011","0000011000110","0000011000001"),
("0000010110010","0000010111111","0000011001011","0000011010110","0000011100000","0000011101000","0000011101111","0000011110100","0000011111000","0000011111001","0000011111001","0000011111000","0000011110100","0000011101111","0000011101000","0000011100000","0000011010110","0000011001011","0000010111111","0000010110010"),
("0000000111100","0000001110001","0000010100101","0000011010111","0000100000100","0000100101101","0000101001111","0000101101010","0000101111100","0000110000101","0000110000101","0000101111100","0000101101010","0000101001111","0000100101101","0000100000100","0000011010111","0000010100101","0000001110001","0000000111100"),
("1111010010111","1111010111111","1111100001000","1111101101111","1111111101010","0000001101110","0000011101101","0000101011010","0000110101010","0000111010100","0000111010100","0000110101010","0000101011010","0000011101101","0000001101110","1111111101010","1111101101111","1111100001000","1111010111111","1111010010111"),
("0000011001000","0000001011000","1111110011011","1111011010010","1111001010100","1111001100111","1111100011000","0000000110010","0000101001111","0001000000001","0001000000001","0000101001111","0000000110010","1111100011000","1111001100111","1111001010100","1111011010010","1111110011011","0000001011000","0000011001000"),
("1111111101000","0000000101001","1111111010001","0000000100101","0000101001010","0000100010000","1111010100001","1110100011101","1111101011100","0001011100010","0001011100010","1111101011100","1110100011101","1111010100001","0000100010000","0000101001010","0000000100101","1111111010001","0000000101001","1111111101000"),
("1111100100000","0000000101011","1111111001110","0000101010010","1111001101101","0000001010101","1111110010010","0001110000100","1101000100000","0001100000111","0001100000111","1101000100000","0001110000100","1111110010010","0000001010101","1111001101101","0000101010010","1111111001110","0000000101011","1111100100000"));




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
