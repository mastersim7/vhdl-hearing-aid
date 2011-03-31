-- serial_filter.vhd
-- Author: Mathias Lundell,Shwan Ciyako,Anandhavel Sakthivel
-- Date: 2011-03-16
-- Description:
-- A serial filter
--
-- 2011-03-30, Mathias Lundell
-- Changed so that file uses specific filter types, like multi_result.
-- In order to look for an error i put the eq_adder function in this file.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--USE ieee.std_logic_signed.ALL;
USE work.EQ_data_type.ALL;

ENTITY serial_filter IS
    GENERIC(
            NUM_OF_COEFFS : NATURAL := 110);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            CO      : IN coefficient_type;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            Q	      : OUT Multi_result);
END ENTITY;

ARCHITECTURE serial_filter_arch OF serial_filter IS   
BEGIN

PROCESS(clk)
    VARIABLE two_samples : STD_LOGIC_VECTOR(12 DOWNTO 0); 
    VARIABLE count : NATURAL RANGE 0 TO NUM_OF_COEFFS;
    VARIABLE mac,temp : Multi_result;
    VARIABLE p1, p2 : STD_LOGIC_VECTOR(12 DOWNTO 0);
    CONSTANT MSB : NATURAL := 11;
BEGIN
    IF clk'EVENT AND clk = '1' THEN
        -- Synchronous reset
        IF reset ='1' THEN 
            mac := (OTHERS => '0');
            temp := (OTHERS => '0');
            Q   <= (OTHERS => '0');
        -- CE high, calculate a result. Output updated when all coefficients used
        ELSIF CE = '1' THEN
            -- Extend incoming parameters.
            IF sample1(MSB) = '1' THEN
                p1 := '1' & sample1;
            ELSE
                p1 := '0' & sample1;
            END IF;
        
            IF sample2(MSB) = '1' THEN
                p2 := '1' & sample2;
            ELSE
                p2 := '0' & sample2;
            END IF;
        
            -- Perform signed addition
            two_samples := STD_LOGIC_VECTOR( SIGNED(p1) + SIGNED(p2) );
            
            temp := STD_LOGIC_VECTOR(SHIFT_LEFT((SIGNED(two_samples)*SIGNED(CO)), 1));
            mac := STD_LOGIC_VECTOR(SIGNED(mac) + SIGNED(temp));
            Q <= mac;
        END IF;
    END IF;
END PROCESS;
END ARCHITECTURE serial_filter_arch;
