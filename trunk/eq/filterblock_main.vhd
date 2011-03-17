-- Description:
-- filterblock_main.vhd
-- Author: Shwan Ciyako,Anandhavel Sakthivel
-- It is still in the implementation phase. 
-- This files adds needed components together to make a filterbank, you are welcome to make changes but make shure to update the whole chain of files that will be affected
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.EQ_data_type.ALL;
USE work.EQ_functions.ALL;

ENTITY filterblock_main IS
	  GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_SAMPLES : NATURAL := 200;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
 	    sample1 : IN sample;
            sample2 : IN sample;
            OE      : OUT STD_LOGIC; 
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END filterblock_main;

ARCHITECTURE  filterblock_main_arch OF filterblock_main IS 


-- components 

-- The samples come from the main main 
-- The Coefficents will be here or in the package 

-- serialfilter component 
COMPONENT serial_filter IS
    GENERIC(
            NUM_BITS_OUT : NATURAL := 37;
            NUM_OF_COEFFS : NATURAL := 110);
    PORT( 
            clk     : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            RE	    : OUT STD_LOGIC; -- used to ask for a new pair of samples
            OE      : OUT STD_LOGIC;
            Q       : OUT Multi_Result); --STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;


-- signals 
SIGNAL CE_FIR1,OE_FIR1,CE_FIR2,OE_FIR2: STD_LOGIC;
SIGNAL Q_FIR1,Q_FIR2 :  Multi_Result;

BEGIN 
PROCESS(clk, CE)
    VARIABLE count : NATURAL RANGE 0 TO NUM_OF_COEFFS;

BEGIN
-- component instantiation 
FIR1: serial_filter PORT MAP(clk,CE_FIR1,sample1,sample2,OE_FIR1,Q_FIR1);
FIR2:  serial_filter PORT MAP(clk,CE_FIR2,sample1,sample2,OE_FIR2,Q_FIR2);




IF clk'EVENT AND clk = '1' THEN
        -- Synchronous reset
        IF reset ='1' THEN 
            Q   <= (OTHERS => '0');
            count := 0;
            OE    <= '0';
        ELSIF CE = '1' THEN 
        -- do the job
        END IF; --reset 
END IF; --clk
END;
