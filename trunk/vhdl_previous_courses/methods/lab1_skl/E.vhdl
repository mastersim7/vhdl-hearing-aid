--------------------------------------------------------------------------------
-- E is part of the multiplier generated on 2007-02-22 using the
-- HMS  Multiplier Generator.
--
-- Copyright Magnus Sjalander
--
-- http://www.ce.chalmers.se/~hms/multiplier.html
--
-- Disclaimer: This service was provided "as is",
-- the service provider cannot guarantee that there are no discrepancies.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity E is
	port(	G	: in  std_logic;
		X	: in  std_logic;
		SUM	: out std_logic);
end;

architecture rtl of E is
begin
	SUM <= X XOR G;
end;
