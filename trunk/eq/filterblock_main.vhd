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
            reset   : IN STD_LOGIC;
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
            CE      : IN STD_LOGIC; -- same as buffer
            reset   : IN STD_LOGIC;
            OE_buffer : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            RE	    : OUT STD_LOGIC; -- used to ask for a new pair of samples
            OE      : OUT STD_LOGIC;
            Q,Q2       : OUT Multi_Result); --STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END;


-- signals 
SIGNAL CE_FIR1,OE_FIR1,CE_FIR2,OE_FIR2: STD_LOGIC;
SIGNAL Q_FIR1,Q_FIR2 :  Multi_Result;
SIGNAL CO_FIR1,CO_FIR2 : coefficient_type;
SIGNAL STATE ,NEXT_STATE : state_type_Filter_Bank;
BEGIN 
-- component instantiation 
FIR1: serial_filter PORT MAP(clk,reset,CO_FIR1,CE_FIR1,sample1,sample2,OE_FIR1,Q_FIR1);
FIR2:  serial_filter PORT MAP(clk,reset,CO_FIR2,CE_FIR2,sample1,sample2,OE_FIR2,Q_FIR2);

PROCESS(clk, CE)
    VARIABLE count : NATURAL RANGE 0 TO NUM_OF_COEFFS;

BEGIN

IF clk'EVENT AND clk = '1' THEN
        -- Synchronous reset
        IF reset ='1' THEN 
            Q,Q2   <= (OTHERS => '0');
            count := 0;
            OE    <= '0';
        ELSIF CE = '1' THEN 
        
        CASE STATE IS 
        
        WHEN WAIT_SAMPLE => 
        	--OE <= '0';
	        IF UPDATED = '1' THEN 
	        RE <= '1'; 
	        NEXT_STATE <= COMPUTE_DATA ; 
	        END IF ;
        	
        WHEN COMPUTE_DATA =>
        	-- same CE for the filters and the buffer will result in one value per CE moved from buffers to the filters 
        		IF count_filters /= (NUM_OF_BANDS/2)-1; -- 4 filters right now are serially implemented can be changed
	        		IF count /= NUM_OF_COEFFS; 
	        		OE<='0'; -- move this ?
        			CE_FIR1,OE_FIR1 <= CE; -- needs to be the same for buffer
        			CO_FIR1 <=CO(count_filters,count);
        			CO_FIR2 <=CO(count_filters+((NUM_OF_BANDS/2)-1),count);
       		 		count := count +1;
       		 		ELSE 
       		 		count := 0;
        			END IF; -- count

        			IF OE_FIR1 AND OE_FIR2 THEN 
	        		Q <= Q_FIR1;
        			Q2 <= Q_FIR2;
        			OE <='1';
        			END IF;

        			count_filters = count_filters + 1 ;
        		ELSE 
	        		OE <='0';
	        		count_filters = 0;
	        		NEXT_STATE <= WAIT_SAMPLE;
        		END IF ;-- count_filters
        		
        	END CASE;
        
        
        END IF; --reset 
END IF; --clk
END;
