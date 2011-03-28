-- add2b.vhd
-- 100910 Mathias Lundell
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY add2b IS
    PORT ( a    : IN  STD_LOGIC;
           b    : IN  STD_LOGIC;
           cin  : IN  STD_LOGIC;
           
           s    : OUT STD_LOGIC;
           cout : OUT STD_LOGIC);
END ENTITY add2b;

ARCHITECTURE add2b_arch OF add2b IS
BEGIN
    s    <= (a XOR b) XOR cin;
    cout <= (a AND b) OR (cin AND (a OR b));
END ARCHITECTURE add2b_arch;
