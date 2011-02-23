library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity sklansky is
   port(
	OpA	: in	std_logic_vector(31 downto 0);
	OpB	: in	std_logic_vector(31 downto 0);
	Cin	: in	std_logic;
	Cout	: out	std_logic;
    	V       : out   std_logic;
	Result	: out	std_logic_vector(31 downto 0));
end;

architecture rtl of sklansky is
	component InitCarry
	   port(
		A	: in	std_logic;
		B	: in	std_logic;
		C	: in	std_logic;
		G	: out	std_logic;
		P	: out	std_logic);
	end component;

	component Init
	   port(
		A	: in	std_logic;
		B	: in	std_logic;
		G	: out	std_logic;
		P	: out	std_logic);
	end component;

	component DOTs
	   port(
		P1	: in	std_logic;
		G1	: in	std_logic;
		P2	: in	std_logic;
		G2	: in	std_logic;
		P	: out	std_logic;
		G	: out	std_logic);
	end component;

	component Gdot
	   port(
		P1	: in	std_logic;
		G1	: in	std_logic;
		G2	: in	std_logic;
		G	: out	std_logic);
	end component;

	component E
	   port(
		G	: in	std_logic;
		X	: in	std_logic;
		SUM	: out	std_logic);
	end component;

signal NULL1 : std_logic;
signal NULL2 : std_logic;
signal NULL3 : std_logic;
signal NULL4 : std_logic;
signal NULL5 : std_logic;
signal NULL6 : std_logic;
signal NULL7 : std_logic;
signal NULL8 : std_logic;
signal NULL9 : std_logic;
signal NULL10 : std_logic;
signal NULL11 : std_logic;
signal NULL12 : std_logic;
signal G1_0	: std_logic;
signal P1_0	: std_logic;
signal G1_1	: std_logic;
signal P1_1	: std_logic;
signal G1_2	: std_logic;
signal P1_2	: std_logic;
signal G1_3	: std_logic;
signal P1_3	: std_logic;
signal G1_4	: std_logic;
signal P1_4	: std_logic;
signal G1_5	: std_logic;
signal P1_5	: std_logic;
signal G1_6	: std_logic;
signal P1_6	: std_logic;
signal G1_7	: std_logic;
signal P1_7	: std_logic;
signal G1_8	: std_logic;
signal P1_8	: std_logic;
signal G1_9	: std_logic;
signal P1_9	: std_logic;
signal G1_10	: std_logic;
signal P1_10	: std_logic;
signal G1_11	: std_logic;
signal P1_11	: std_logic;
signal G1_12	: std_logic;
signal P1_12	: std_logic;
signal G1_13	: std_logic;
signal P1_13	: std_logic;
signal G1_14	: std_logic;
signal P1_14	: std_logic;
signal G1_15	: std_logic;
signal P1_15	: std_logic;
signal G1_16	: std_logic;
signal P1_16	: std_logic;
signal G1_17	: std_logic;
signal P1_17	: std_logic;
signal G1_18	: std_logic;
signal P1_18	: std_logic;
signal G1_19	: std_logic;
signal P1_19	: std_logic;
signal G1_20	: std_logic;
signal P1_20	: std_logic;
signal G1_21	: std_logic;
signal P1_21	: std_logic;
signal G1_22	: std_logic;
signal P1_22	: std_logic;
signal G1_23	: std_logic;
signal P1_23	: std_logic;
signal G1_24	: std_logic;
signal P1_24	: std_logic;
signal G1_25	: std_logic;
signal P1_25	: std_logic;
signal G1_26	: std_logic;
signal P1_26	: std_logic;
signal G1_27	: std_logic;
signal P1_27	: std_logic;
signal G1_28	: std_logic;
signal P1_28	: std_logic;
signal G1_29	: std_logic;
signal P1_29	: std_logic;
signal G1_30	: std_logic;
signal P1_30	: std_logic;
signal G1_31	: std_logic;
signal P1_31	: std_logic;
signal P2_1	: std_logic;
signal G2_1	: std_logic;
signal P2_3	: std_logic;
signal G2_3	: std_logic;
signal P2_5	: std_logic;
signal G2_5	: std_logic;
signal P2_7	: std_logic;
signal G2_7	: std_logic;
signal P2_9	: std_logic;
signal G2_9	: std_logic;
signal P2_11	: std_logic;
signal G2_11	: std_logic;
signal P2_13	: std_logic;
signal G2_13	: std_logic;
signal P2_15	: std_logic;
signal G2_15	: std_logic;
signal P2_17	: std_logic;
signal G2_17	: std_logic;
signal P2_19	: std_logic;
signal G2_19	: std_logic;
signal P2_21	: std_logic;
signal G2_21	: std_logic;
signal P2_23	: std_logic;
signal G2_23	: std_logic;
signal P2_25	: std_logic;
signal G2_25	: std_logic;
signal P2_27	: std_logic;
signal G2_27	: std_logic;
signal P2_29	: std_logic;
signal G2_29	: std_logic;
signal P2_31	: std_logic;
signal G2_31	: std_logic;
signal G6_3	: std_logic;
signal P3_3	: std_logic;
signal G3_3	: std_logic;
signal P3_6	: std_logic;
signal G3_6	: std_logic;
signal P3_7	: std_logic;
signal G3_7	: std_logic;
signal P4_10	: std_logic;
signal G4_10	: std_logic;
signal P3_11	: std_logic;
signal G3_11	: std_logic;
signal P3_14	: std_logic;
signal G3_14	: std_logic;
signal P3_15	: std_logic;
signal G3_15	: std_logic;
signal P5_18	: std_logic;
signal G5_18	: std_logic;
signal P3_19	: std_logic;
signal G3_19	: std_logic;
signal P3_22	: std_logic;
signal G3_22	: std_logic;
signal P3_23	: std_logic;
signal G3_23	: std_logic;
signal P4_26	: std_logic;
signal G4_26	: std_logic;
signal P3_27	: std_logic;
signal G3_27	: std_logic;
signal P3_30	: std_logic;
signal G3_30	: std_logic;
signal P3_31	: std_logic;
signal G3_31	: std_logic;
signal G6_5	: std_logic;
signal G6_6	: std_logic;
signal G6_7	: std_logic;
signal P4_7	: std_logic;
signal G4_7	: std_logic;
signal P4_12	: std_logic;
signal G4_12	: std_logic;
signal P4_13	: std_logic;
signal G4_13	: std_logic;
signal P4_14	: std_logic;
signal G4_14	: std_logic;
signal P4_15	: std_logic;
signal G4_15	: std_logic;
signal P5_20	: std_logic;
signal G5_20	: std_logic;
signal P5_21	: std_logic;
signal G5_21	: std_logic;
signal P5_22	: std_logic;
signal G5_22	: std_logic;
signal P4_23	: std_logic;
signal G4_23	: std_logic;
signal P4_28	: std_logic;
signal G4_28	: std_logic;
signal P4_29	: std_logic;
signal G4_29	: std_logic;
signal P4_30	: std_logic;
signal G4_30	: std_logic;
signal P4_31	: std_logic;
signal G4_31	: std_logic;
signal G6_9	: std_logic;
signal G6_10	: std_logic;
signal G6_11	: std_logic;
signal G6_12	: std_logic;
signal G6_13	: std_logic;
signal G6_14	: std_logic;
signal G6_15	: std_logic;
signal G5_15	: std_logic;
signal P5_24	: std_logic;
signal G5_24	: std_logic;
signal P5_25	: std_logic;
signal G5_25	: std_logic;
signal P5_26	: std_logic;
signal G5_26	: std_logic;
signal P5_27	: std_logic;
signal G5_27	: std_logic;
signal P5_28	: std_logic;
signal G5_28	: std_logic;
signal P5_29	: std_logic;
signal G5_29	: std_logic;
signal P5_30	: std_logic;
signal G5_30	: std_logic;
signal P5_31	: std_logic;
signal G5_31	: std_logic;
signal G6_17	: std_logic;
signal G6_18	: std_logic;
signal G6_19	: std_logic;
signal G6_20	: std_logic;
signal G6_21	: std_logic;
signal G6_22	: std_logic;
signal G6_23	: std_logic;
signal G6_24	: std_logic;
signal G6_25	: std_logic;
signal G6_26	: std_logic;
signal G6_27	: std_logic;
signal G6_28	: std_logic;
signal G6_29	: std_logic;
signal G6_30	: std_logic;
signal G6_31	: std_logic;
signal nCout    : std_logic;
begin
	INIT0:InitCarry
	   port map(
		A	=> OpA(0),
		B	=> OpB(0),
		C	=> Cin,
		G	=> G1_0,
		P	=> P1_0);

	INIT1:Init
	   port map(
		A	=> OpA(1),
		B	=> OpB(1),
		G	=> G1_1,
		P	=> P1_1);

	INIT2:Init
	   port map(
		A	=> OpA(2),
		B	=> OpB(2),
		G	=> G1_2,
		P	=> P1_2);

	INIT3:Init
	   port map(
		A	=> OpA(3),
		B	=> OpB(3),
		G	=> G1_3,
		P	=> P1_3);

	INIT4:Init
	   port map(
		A	=> OpA(4),
		B	=> OpB(4),
		G	=> G1_4,
		P	=> P1_4);

	INIT5:Init
	   port map(
		A	=> OpA(5),
		B	=> OpB(5),
		G	=> G1_5,
		P	=> P1_5);

	INIT6:Init
	   port map(
		A	=> OpA(6),
		B	=> OpB(6),
		G	=> G1_6,
		P	=> P1_6);

	INIT7:Init
	   port map(
		A	=> OpA(7),
		B	=> OpB(7),
		G	=> G1_7,
		P	=> P1_7);

	INIT8:Init
	   port map(
		A	=> OpA(8),
		B	=> OpB(8),
		G	=> G1_8,
		P	=> P1_8);

	INIT9:Init
	   port map(
		A	=> OpA(9),
		B	=> OpB(9),
		G	=> G1_9,
		P	=> P1_9);

	INIT10:Init
	   port map(
		A	=> OpA(10),
		B	=> OpB(10),
		G	=> G1_10,
		P	=> P1_10);

	INIT11:Init
	   port map(
		A	=> OpA(11),
		B	=> OpB(11),
		G	=> G1_11,
		P	=> P1_11);

	INIT12:Init
	   port map(
		A	=> OpA(12),
		B	=> OpB(12),
		G	=> G1_12,
		P	=> P1_12);

	INIT13:Init
	   port map(
		A	=> OpA(13),
		B	=> OpB(13),
		G	=> G1_13,
		P	=> P1_13);

	INIT14:Init
	   port map(
		A	=> OpA(14),
		B	=> OpB(14),
		G	=> G1_14,
		P	=> P1_14);

	INIT15:Init
	   port map(
		A	=> OpA(15),
		B	=> OpB(15),
		G	=> G1_15,
		P	=> P1_15);

	INIT16:Init
	   port map(
		A	=> OpA(16),
		B	=> OpB(16),
		G	=> G1_16,
		P	=> P1_16);

	INIT17:Init
	   port map(
		A	=> OpA(17),
		B	=> OpB(17),
		G	=> G1_17,
		P	=> P1_17);

	INIT18:Init
	   port map(
		A	=> OpA(18),
		B	=> OpB(18),
		G	=> G1_18,
		P	=> P1_18);

	INIT19:Init
	   port map(
		A	=> OpA(19),
		B	=> OpB(19),
		G	=> G1_19,
		P	=> P1_19);

	INIT20:Init
	   port map(
		A	=> OpA(20),
		B	=> OpB(20),
		G	=> G1_20,
		P	=> P1_20);

	INIT21:Init
	   port map(
		A	=> OpA(21),
		B	=> OpB(21),
		G	=> G1_21,
		P	=> P1_21);

	INIT22:Init
	   port map(
		A	=> OpA(22),
		B	=> OpB(22),
		G	=> G1_22,
		P	=> P1_22);

	INIT23:Init
	   port map(
		A	=> OpA(23),
		B	=> OpB(23),
		G	=> G1_23,
		P	=> P1_23);

	INIT24:Init
	   port map(
		A	=> OpA(24),
		B	=> OpB(24),
		G	=> G1_24,
		P	=> P1_24);

	INIT25:Init
	   port map(
		A	=> OpA(25),
		B	=> OpB(25),
		G	=> G1_25,
		P	=> P1_25);

	INIT26:Init
	   port map(
		A	=> OpA(26),
		B	=> OpB(26),
		G	=> G1_26,
		P	=> P1_26);

	INIT27:Init
	   port map(
		A	=> OpA(27),
		B	=> OpB(27),
		G	=> G1_27,
		P	=> P1_27);

	INIT28:Init
	   port map(
		A	=> OpA(28),
		B	=> OpB(28),
		G	=> G1_28,
		P	=> P1_28);

	INIT29:Init
	   port map(
		A	=> OpA(29),
		B	=> OpB(29),
		G	=> G1_29,
		P	=> P1_29);

	INIT30:Init
	   port map(
		A	=> OpA(30),
		B	=> OpB(30),
		G	=> G1_30,
		P	=> P1_30);

	INIT31:Init
	   port map(
		A	=> OpA(31),
		B	=> OpB(31),
		G	=> G1_31,
		P	=> P1_31);

	DOT1_1:DOTs
	   port map(
		P1	=> P1_1,
		G1	=> G1_1,
		P2	=> P1_0,
		G2	=> G1_0,
		P	=> P2_1,
		G	=> G2_1);

	DOT1_3:DOTs
	   port map(
		P1	=> P1_3,
		G1	=> G1_3,
		P2	=> P1_2,
		G2	=> G1_2,
		P	=> P2_3,
		G	=> G2_3);

	DOT1_5:DOTs
	   port map(
		P1	=> P1_5,
		G1	=> G1_5,
		P2	=> P1_4,
		G2	=> G1_4,
		P	=> P2_5,
		G	=> G2_5);

	DOT1_7:DOTs
	   port map(
		P1	=> P1_7,
		G1	=> G1_7,
		P2	=> P1_6,
		G2	=> G1_6,
		P	=> P2_7,
		G	=> G2_7);

	DOT1_9:DOTs
	   port map(
		P1	=> P1_9,
		G1	=> G1_9,
		P2	=> P1_8,
		G2	=> G1_8,
		P	=> P2_9,
		G	=> G2_9);

	DOT1_11:DOTs
	   port map(
		P1	=> P1_11,
		G1	=> G1_11,
		P2	=> P1_10,
		G2	=> G1_10,
		P	=> P2_11,
		G	=> G2_11);

	DOT1_13:DOTs
	   port map(
		P1	=> P1_13,
		G1	=> G1_13,
		P2	=> P1_12,
		G2	=> G1_12,
		P	=> P2_13,
		G	=> G2_13);

	DOT1_15:DOTs
	   port map(
		P1	=> P1_15,
		G1	=> G1_15,
		P2	=> P1_14,
		G2	=> G1_14,
		P	=> P2_15,
		G	=> G2_15);

	DOT1_17:DOTs
	   port map(
		P1	=> P1_17,
		G1	=> G1_17,
		P2	=> P1_16,
		G2	=> G1_16,
		P	=> P2_17,
		G	=> G2_17);

	DOT1_19:DOTs
	   port map(
		P1	=> P1_19,
		G1	=> G1_19,
		P2	=> P1_18,
		G2	=> G1_18,
		P	=> P2_19,
		G	=> G2_19);

	DOT1_21:DOTs
	   port map(
		P1	=> P1_21,
		G1	=> G1_21,
		P2	=> P1_20,
		G2	=> G1_20,
		P	=> P2_21,
		G	=> G2_21);

	DOT1_23:DOTs
	   port map(
		P1	=> P1_23,
		G1	=> G1_23,
		P2	=> P1_22,
		G2	=> G1_22,
		P	=> P2_23,
		G	=> G2_23);

	DOT1_25:DOTs
	   port map(
		P1	=> P1_25,
		G1	=> G1_25,
		P2	=> P1_24,
		G2	=> G1_24,
		P	=> P2_25,
		G	=> G2_25);

	DOT1_27:DOTs
	   port map(
		P1	=> P1_27,
		G1	=> G1_27,
		P2	=> P1_26,
		G2	=> G1_26,
		P	=> P2_27,
		G	=> G2_27);

	DOT1_29:DOTs
	   port map(
		P1	=> P1_29,
		G1	=> G1_29,
		P2	=> P1_28,
		G2	=> G1_28,
		P	=> P2_29,
		G	=> G2_29);

	DOT1_31:DOTs
	   port map(
		P1	=> P1_31,
		G1	=> G1_31,
		P2	=> P1_30,
		G2	=> G1_30,
		P	=> P2_31,
		G	=> G2_31);

	DOT2_2:DOTs
	   port map(
		P1	=> P1_2,
		G1	=> G1_2,
		P2	=> P2_1,
		G2	=> G2_1,
		P	=> NULL1,
		G	=> G6_3);

	DOT2_3:DOTs
	   port map(
		P1	=> P2_3,
		G1	=> G2_3,
		P2	=> P2_1,
		G2	=> G2_1,
		P	=> P3_3,
		G	=> G3_3);

	DOT2_6:DOTs
	   port map(
		P1	=> P1_6,
		G1	=> G1_6,
		P2	=> P2_5,
		G2	=> G2_5,
		P	=> P3_6,
		G	=> G3_6);

	DOT2_7:DOTs
	   port map(
		P1	=> P2_7,
		G1	=> G2_7,
		P2	=> P2_5,
		G2	=> G2_5,
		P	=> P3_7,
		G	=> G3_7);

	DOT2_10:DOTs
	   port map(
		P1	=> P1_10,
		G1	=> G1_10,
		P2	=> P2_9,
		G2	=> G2_9,
		P	=> P4_10,
		G	=> G4_10);

	DOT2_11:DOTs
	   port map(
		P1	=> P2_11,
		G1	=> G2_11,
		P2	=> P2_9,
		G2	=> G2_9,
		P	=> P3_11,
		G	=> G3_11);

	DOT2_14:DOTs
	   port map(
		P1	=> P1_14,
		G1	=> G1_14,
		P2	=> P2_13,
		G2	=> G2_13,
		P	=> P3_14,
		G	=> G3_14);

	DOT2_15:DOTs
	   port map(
		P1	=> P2_15,
		G1	=> G2_15,
		P2	=> P2_13,
		G2	=> G2_13,
		P	=> P3_15,
		G	=> G3_15);

	DOT2_18:DOTs
	   port map(
		P1	=> P1_18,
		G1	=> G1_18,
		P2	=> P2_17,
		G2	=> G2_17,
		P	=> P5_18,
		G	=> G5_18);

	DOT2_19:DOTs
	   port map(
		P1	=> P2_19,
		G1	=> G2_19,
		P2	=> P2_17,
		G2	=> G2_17,
		P	=> P3_19,
		G	=> G3_19);

	DOT2_22:DOTs
	   port map(
		P1	=> P1_22,
		G1	=> G1_22,
		P2	=> P2_21,
		G2	=> G2_21,
		P	=> P3_22,
		G	=> G3_22);

	DOT2_23:DOTs
	   port map(
		P1	=> P2_23,
		G1	=> G2_23,
		P2	=> P2_21,
		G2	=> G2_21,
		P	=> P3_23,
		G	=> G3_23);

	DOT2_26:DOTs
	   port map(
		P1	=> P1_26,
		G1	=> G1_26,
		P2	=> P2_25,
		G2	=> G2_25,
		P	=> P4_26,
		G	=> G4_26);

	DOT2_27:DOTs
	   port map(
		P1	=> P2_27,
		G1	=> G2_27,
		P2	=> P2_25,
		G2	=> G2_25,
		P	=> P3_27,
		G	=> G3_27);

	DOT2_30:DOTs
	   port map(
		P1	=> P1_30,
		G1	=> G1_30,
		P2	=> P2_29,
		G2	=> G2_29,
		P	=> P3_30,
		G	=> G3_30);

	DOT2_31:DOTs
	   port map(
		P1	=> P2_31,
		G1	=> G2_31,
		P2	=> P2_29,
		G2	=> G2_29,
		P	=> P3_31,
		G	=> G3_31);

	DOT3_4:DOTs
	   port map(
		P1	=> P1_4,
		G1	=> G1_4,
		P2	=> P3_3,
		G2	=> G3_3,
		P	=> NULL2,
		G	=> G6_5);

	DOT3_5:DOTs
	   port map(
		P1	=> P2_5,
		G1	=> G2_5,
		P2	=> P3_3,
		G2	=> G3_3,
		P	=> NULL3,
		G	=> G6_6);

	DOT3_6:DOTs
	   port map(
		P1	=> P3_6,
		G1	=> G3_6,
		P2	=> P3_3,
		G2	=> G3_3,
		P	=> NULL4,
		G	=> G6_7);

	DOT3_7:DOTs
	   port map(
		P1	=> P3_7,
		G1	=> G3_7,
		P2	=> P3_3,
		G2	=> G3_3,
		P	=> P4_7,
		G	=> G4_7);

	DOT3_12:DOTs
	   port map(
		P1	=> P1_12,
		G1	=> G1_12,
		P2	=> P3_11,
		G2	=> G3_11,
		P	=> P4_12,
		G	=> G4_12);

	DOT3_13:DOTs
	   port map(
		P1	=> P2_13,
		G1	=> G2_13,
		P2	=> P3_11,
		G2	=> G3_11,
		P	=> P4_13,
		G	=> G4_13);

	DOT3_14:DOTs
	   port map(
		P1	=> P3_14,
		G1	=> G3_14,
		P2	=> P3_11,
		G2	=> G3_11,
		P	=> P4_14,
		G	=> G4_14);

	DOT3_15:DOTs
	   port map(
		P1	=> P3_15,
		G1	=> G3_15,
		P2	=> P3_11,
		G2	=> G3_11,
		P	=> P4_15,
		G	=> G4_15);

	DOT3_20:DOTs
	   port map(
		P1	=> P1_20,
		G1	=> G1_20,
		P2	=> P3_19,
		G2	=> G3_19,
		P	=> P5_20,
		G	=> G5_20);

	DOT3_21:DOTs
	   port map(
		P1	=> P2_21,
		G1	=> G2_21,
		P2	=> P3_19,
		G2	=> G3_19,
		P	=> P5_21,
		G	=> G5_21);

	DOT3_22:DOTs
	   port map(
		P1	=> P3_22,
		G1	=> G3_22,
		P2	=> P3_19,
		G2	=> G3_19,
		P	=> P5_22,
		G	=> G5_22);

	DOT3_23:DOTs
	   port map(
		P1	=> P3_23,
		G1	=> G3_23,
		P2	=> P3_19,
		G2	=> G3_19,
		P	=> P4_23,
		G	=> G4_23);

	DOT3_28:DOTs
	   port map(
		P1	=> P1_28,
		G1	=> G1_28,
		P2	=> P3_27,
		G2	=> G3_27,
		P	=> P4_28,
		G	=> G4_28);

	DOT3_29:DOTs
	   port map(
		P1	=> P2_29,
		G1	=> G2_29,
		P2	=> P3_27,
		G2	=> G3_27,
		P	=> P4_29,
		G	=> G4_29);

	DOT3_30:DOTs
	   port map(
		P1	=> P3_30,
		G1	=> G3_30,
		P2	=> P3_27,
		G2	=> G3_27,
		P	=> P4_30,
		G	=> G4_30);

	DOT3_31:DOTs
	   port map(
		P1	=> P3_31,
		G1	=> G3_31,
		P2	=> P3_27,
		G2	=> G3_27,
		P	=> P4_31,
		G	=> G4_31);

	DOT4_8:DOTs
	   port map(
		P1	=> P1_8,
		G1	=> G1_8,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL5,
		G	=> G6_9);

	DOT4_9:DOTs
	   port map(
		P1	=> P2_9,
		G1	=> G2_9,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL6,
		G	=> G6_10);

	DOT4_10:DOTs
	   port map(
		P1	=> P4_10,
		G1	=> G4_10,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL7,
		G	=> G6_11);

	DOT4_11:DOTs
	   port map(
		P1	=> P3_11,
		G1	=> G3_11,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL8,
		G	=> G6_12);

	DOT4_12:DOTs
	   port map(
		P1	=> P4_12,
		G1	=> G4_12,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL9,
		G	=> G6_13);

	DOT4_13:DOTs
	   port map(
		P1	=> P4_13,
		G1	=> G4_13,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL10,
		G	=> G6_14);

	DOT4_14:DOTs
	   port map(
		P1	=> P4_14,
		G1	=> G4_14,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL11,
		G	=> G6_15);

	DOT4_15:DOTs
	   port map(
		P1	=> P4_15,
		G1	=> G4_15,
		P2	=> P4_7,
		G2	=> G4_7,
		P	=> NULL12,
		G	=> G5_15);

	DOT4_24:DOTs
	   port map(
		P1	=> P1_24,
		G1	=> G1_24,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_24,
		G	=> G5_24);

	DOT4_25:DOTs
	   port map(
		P1	=> P2_25,
		G1	=> G2_25,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_25,
		G	=> G5_25);

	DOT4_26:DOTs
	   port map(
		P1	=> P4_26,
		G1	=> G4_26,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_26,
		G	=> G5_26);

	DOT4_27:DOTs
	   port map(
		P1	=> P3_27,
		G1	=> G3_27,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_27,
		G	=> G5_27);

	DOT4_28:DOTs
	   port map(
		P1	=> P4_28,
		G1	=> G4_28,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_28,
		G	=> G5_28);

	DOT4_29:DOTs
	   port map(
		P1	=> P4_29,
		G1	=> G4_29,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_29,
		G	=> G5_29);

	DOT4_30:DOTs
	   port map(
		P1	=> P4_30,
		G1	=> G4_30,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_30,
		G	=> G5_30);

	DOT4_31:DOTs
	   port map(
		P1	=> P4_31,
		G1	=> G4_31,
		P2	=> P4_23,
		G2	=> G4_23,
		P	=> P5_31,
		G	=> G5_31);

	DOT5_16:Gdot
	   port map(
		P1	=> P1_16,
		G1	=> G1_16,
		G2	=> G5_15,
		G	=> G6_17);

	DOT5_17:Gdot
	   port map(
		P1	=> P2_17,
		G1	=> G2_17,
		G2	=> G5_15,
		G	=> G6_18);

	DOT5_18:Gdot
	   port map(
		P1	=> P5_18,
		G1	=> G5_18,
		G2	=> G5_15,
		G	=> G6_19);

	DOT5_19:Gdot
	   port map(
		P1	=> P3_19,
		G1	=> G3_19,
		G2	=> G5_15,
		G	=> G6_20);

	DOT5_20:Gdot
	   port map(
		P1	=> P5_20,
		G1	=> G5_20,
		G2	=> G5_15,
		G	=> G6_21);

	DOT5_21:Gdot
	   port map(
		P1	=> P5_21,
		G1	=> G5_21,
		G2	=> G5_15,
		G	=> G6_22);

	DOT5_22:Gdot
	   port map(
		P1	=> P5_22,
		G1	=> G5_22,
		G2	=> G5_15,
		G	=> G6_23);

	DOT5_23:Gdot
	   port map(
		P1	=> P4_23,
		G1	=> G4_23,
		G2	=> G5_15,
		G	=> G6_24);

	DOT5_24:Gdot
	   port map(
		P1	=> P5_24,
		G1	=> G5_24,
		G2	=> G5_15,
		G	=> G6_25);

	DOT5_25:Gdot
	   port map(
		P1	=> P5_25,
		G1	=> G5_25,
		G2	=> G5_15,
		G	=> G6_26);

	DOT5_26:Gdot
	   port map(
		P1	=> P5_26,
		G1	=> G5_26,
		G2	=> G5_15,
		G	=> G6_27);

	DOT5_27:Gdot
	   port map(
		P1	=> P5_27,
		G1	=> G5_27,
		G2	=> G5_15,
		G	=> G6_28);

	DOT5_28:Gdot
	   port map(
		P1	=> P5_28,
		G1	=> G5_28,
		G2	=> G5_15,
		G	=> G6_29);

	DOT5_29:Gdot
	   port map(
		P1	=> P5_29,
		G1	=> G5_29,
		G2	=> G5_15,
		G	=> G6_30);

	DOT5_30:Gdot
	   port map(
		P1	=> P5_30,
		G1	=> G5_30,
		G2	=> G5_15,
		G	=> G6_31);

	DOT5_31:Gdot
	   port map(
		P1	=> P5_31,
		G1	=> G5_31,
		G2	=> G5_15,
		G	=> nCout);

	E1:E
	   port map(
		G	=> G1_0,
		X	=> P1_1,
		SUM	=> Result(1));

	E2:E
	   port map(
		G	=> G2_1,
		X	=> P1_2,
		SUM	=> Result(2));

	E3:E
	   port map(
		G	=> G6_3,
		X	=> P1_3,
		SUM	=> Result(3));

	E4:E
	   port map(
		G	=> G3_3,
		X	=> P1_4,
		SUM	=> Result(4));

	E5:E
	   port map(
		G	=> G6_5,
		X	=> P1_5,
		SUM	=> Result(5));

	E6:E
	   port map(
		G	=> G6_6,
		X	=> P1_6,
		SUM	=> Result(6));

	E7:E
	   port map(
		G	=> G6_7,
		X	=> P1_7,
		SUM	=> Result(7));

	E8:E
	   port map(
		G	=> G4_7,
		X	=> P1_8,
		SUM	=> Result(8));

	E9:E
	   port map(
		G	=> G6_9,
		X	=> P1_9,
		SUM	=> Result(9));

	E10:E
	   port map(
		G	=> G6_10,
		X	=> P1_10,
		SUM	=> Result(10));

	E11:E
	   port map(
		G	=> G6_11,
		X	=> P1_11,
		SUM	=> Result(11));

	E12:E
	   port map(
		G	=> G6_12,
		X	=> P1_12,
		SUM	=> Result(12));

	E13:E
	   port map(
		G	=> G6_13,
		X	=> P1_13,
		SUM	=> Result(13));

	E14:E
	   port map(
		G	=> G6_14,
		X	=> P1_14,
		SUM	=> Result(14));

	E15:E
	   port map(
		G	=> G6_15,
		X	=> P1_15,
		SUM	=> Result(15));

	E16:E
	   port map(
		G	=> G5_15,
		X	=> P1_16,
		SUM	=> Result(16));

	E17:E
	   port map(
		G	=> G6_17,
		X	=> P1_17,
		SUM	=> Result(17));

	E18:E
	   port map(
		G	=> G6_18,
		X	=> P1_18,
		SUM	=> Result(18));

	E19:E
	   port map(
		G	=> G6_19,
		X	=> P1_19,
		SUM	=> Result(19));

	E20:E
	   port map(
		G	=> G6_20,
		X	=> P1_20,
		SUM	=> Result(20));

	E21:E
	   port map(
		G	=> G6_21,
		X	=> P1_21,
		SUM	=> Result(21));

	E22:E
	   port map(
		G	=> G6_22,
		X	=> P1_22,
		SUM	=> Result(22));

	E23:E
	   port map(
		G	=> G6_23,
		X	=> P1_23,
		SUM	=> Result(23));

	E24:E
	   port map(
		G	=> G6_24,
		X	=> P1_24,
		SUM	=> Result(24));

	E25:E
	   port map(
		G	=> G6_25,
		X	=> P1_25,
		SUM	=> Result(25));

	E26:E
	   port map(
		G	=> G6_26,
		X	=> P1_26,
		SUM	=> Result(26));

	E27:E
	   port map(
		G	=> G6_27,
		X	=> P1_27,
		SUM	=> Result(27));

	E28:E
	   port map(
		G	=> G6_28,
		X	=> P1_28,
		SUM	=> Result(28));

	E29:E
	   port map(
		G	=> G6_29,
		X	=> P1_29,
		SUM	=> Result(29));

	E30:E
	   port map(
		G	=> G6_30,
		X	=> P1_30,
		SUM	=> Result(30));

	E31:E
	   port map(
		G	=> G6_31,
		X	=> P1_31,
		SUM	=> Result(31));

Result(0) <= P1_0;
V <= nCout XOR G6_31;
Cout <= nCout;
end;
