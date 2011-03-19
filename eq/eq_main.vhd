
ENTITY eq_main IS
	  GENERIC(
            NUM_BITS_OUT : NATURAL := 13;
            NUM_OF_SAMPLES : NATURAL := 200;
				NUM_OF_COEFFS : NATURAL := 110;
            NUM_OF_BANDS: NATURAL := 8);
    PORT( 
            clk     : IN STD_LOGIC;
            reset   : IN STD_LOGIC;
            CE      : IN STD_LOGIC;
            sample1 : IN sample;
            sample2 : IN sample;
            updated: IN STD_LOGIC;
		RE      : OUT STD_LOGIC;
            OE      : OUT STD_LOGIC; 
	      Q2       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0);
            Q       : OUT STD_LOGIC_VECTOR(NUM_BITS_OUT-1 DOWNTO 0));
END eq_main;

ARCHITECTURE  filterblock_main_arch OF filterblock_main IS 
