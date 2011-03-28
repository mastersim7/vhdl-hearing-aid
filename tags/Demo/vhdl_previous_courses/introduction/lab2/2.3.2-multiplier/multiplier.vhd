-- multiplier.vhd
-- Mathias Lundell
-- 091020

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;
USE ieee.numeric_std.ALL;

ENTITY multiplier IS
    GENERIC ( N : NATURAL := 4  );
    PORT ( a        : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
           b        : IN  STD_LOGIC_VECTOR( N-1 DOWNTO 0 );
           clk      : IN  STD_LOGIC;
           start    : IN  STD_LOGIC;
           
           finished : OUT STD_LOGIC;
           y        : OUT STD_LOGIC_VECTOR( NATURAL(CEIL(LOG2(REAL( 2 ** ((2*N)-2)+1 )))) DOWNTO 0 ));
END ENTITY;

ARCHITECTURE multiplier_arch OF multiplier IS
    SIGNAL n_a : STD_LOGIC_VECTOR( y'RANGE );
    SIGNAL n_b : STD_LOGIC_VECTOR( b'RANGE );
    SIGNAL n_y : STD_LOGIC_VECTOR( y'RANGE );
    SIGNAL n_finished : STD_LOGIC;
    
    SIGNAL a_sign : STD_LOGIC;
    SIGNAL b_sign : STD_LOGIC;
    
    SIGNAL pos : NATURAL RANGE 0 TO N;
BEGIN
    multiplication: PROCESS( clk )
    BEGIN
        IF clk'event AND clk = '1' THEN
            IF start = '1' THEN
                a_sign <= a(a'LEFT); -- save sign
                b_sign <= b(b'LEFT); -- save sign
                
                -- absolute of a and b, also resize a to be able to shift
                n_a <= STD_LOGIC_VECTOR( RESIZE( ABS( SIGNED(a) ), y'LENGTH ) ); 
                n_b <= STD_LOGIC_VECTOR( ABS( SIGNED(b) ) );
                
                n_y <= ( OTHERS => '0' ); -- reset
                n_finished <= '0'; -- finished flag
                pos <= 0;          -- counter of positions
            ELSIF pos < N THEN
                -- Do the successive addition
                IF n_b(pos) = '1' THEN
                    n_y <= STD_LOGIC_VECTOR( UNSIGNED(n_y) + 
                                             SHIFT_LEFT(UNSIGNED(n_a), pos) );
                END IF;
                pos <= pos + 1;
                IF pos = N-1 THEN
                    n_finished <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    finished <= n_finished;
    y <= n_y WHEN (n_finished AND (a_sign XNOR b_sign)) = '1' ELSE
         STD_LOGIC_VECTOR( SIGNED(NOT n_y) + 1 ) WHEN n_finished = '1' ELSE
         (OTHERS => '0');
END ARCHITECTURE;
