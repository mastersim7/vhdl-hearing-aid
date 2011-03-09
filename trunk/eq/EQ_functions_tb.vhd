-- EQ_functions.vhd
-- Author:
-- Date:
-- Description:
-- Function used together with the symmetrical filters to add together the newest and
-- oldest sample before multiplication with common coefficient.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.all;
USE work.EQ_data_type.ALL;

entity EQ_functions_tb is
end;

architecture EQ_functions_tb_arch of EQ_functions_tb is
    signal clk : std_logic := '0';
    
    TYPE di_type IS ARRAY(0 TO 10) OF sample;
    CONSTANT di1 : di_type := (
        "011111111111",
        "100000000000",
        "011100000000",
        
begin
    clk <= not clk after 10 ns;
    
    tb: process( clk )
        variable result : sample := 0;
        variable i : integer range 0 to 10;
    begin
        result := function(
    end process;

 end architecture;
