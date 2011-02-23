-- serial_adder.vhd
-- 100914 Mathias Lundell
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY serial_adder IS
    GENERIC ( WIDTH : NATURAL := 4 );
    PORT ( a        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 );
           b        : IN  STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 );
           start    : IN  STD_LOGIC;
           add      : IN  STD_LOGIC;
           clk      : IN  STD_LOGIC;
           
           y        : OUT STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 );
           finished  : OUT STD_LOGIC );   
END ENTITY serial_adder;

ARCHITECTURE serial_adder_arch OF serial_adder IS
    -- Internal "buffer" signals
    SIGNAL n_y   : STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 );
    SIGNAL n_b   : STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 );
    SIGNAL n_a   : STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 );
    SIGNAL n_add : STD_LOGIC;
    SIGNAL n_finished : STD_LOGIC;
    
    -- Constant zeroes and ones
    CONSTANT c_zeroes : STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 ) := (OTHERS => '0');
    CONSTANT c_ones   : STD_LOGIC_VECTOR( WIDTH-1 DOWNTO 0 ) := (OTHERS => '1');
    
    SIGNAL started : STD_LOGIC := '0';
    SIGNAL i : NATURAL RANGE 0 TO WIDTH := 0;
    SIGNAL cin  : STD_LOGIC;
    SIGNAL cout : STD_LOGIC;
BEGIN       
    PROCESS( clk )
    BEGIN
        IF clk'EVENT AND clk = '1' THEN
            IF start = '1' THEN
                IF add = '0' THEN
                    n_b <= NOT b;
                ELSE
                    n_b <= b;
                END IF;
                
                n_a <= a;
                n_add <= add;
                n_y <= (OTHERS => '0');
                
                started <= '1';
                n_finished <= '0';

                i <= 0;
                cin <= NOT add;
                
            ELSIF started = '1' THEN
                IF i < WIDTH THEN
                    n_y(i) <= (n_a(i) XOR n_b(i)) XOR cin;
                    cin <= (n_a(i) AND n_b(i)) OR (cin AND (n_a(i) OR n_b(i)));
                    i <= i + 1;
                    IF i = WIDTH-1 THEN
                        n_finished <= '1';
                        started <= '0';                       
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    finished <= n_finished;
    
    y <= n_y WHEN n_finished = '1' ELSE
         (OTHERS => '0');
END ARCHITECTURE serial_adder_arch;

