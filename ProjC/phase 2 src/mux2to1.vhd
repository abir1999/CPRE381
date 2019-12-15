library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1 is
	port(i_Bit0	: in std_logic;
	     i_Bit1	: in std_logic;
	     i_Sel	: in std_logic;
	     o_out	: out std_logic);
end mux2to1;

architecture structure of mux2to1 is

--NOT gate component
component invg
	port(i_A	: in std_logic;
	     o_F	: out std_logic);
end component;

--AND gate component
component andg2
	port(i_A	: in std_logic;
	     i_B	: in std_logic;
	     o_F	: out std_logic);
end component;

--OR gate component
component org2
	port(i_A	: in std_logic;
	     i_B	: in std_logic;
	     o_F	: out std_logic);
end component;

--signals to be used to form 2 to 1 mux
signal s_VALUE_NOT, s_VALUE_AND1, s_VALUE_AND2	: std_logic;

--begin port mapping
begin

	NOT_gate : invg
	port map(i_A => i_Sel,
		 o_F => s_VALUE_NOT);

	AND1_gate : andg2 
	port map(i_A => i_Bit0,
		 i_B => s_VALUE_NOT,
		 o_F => s_VALUE_AND1);

	AND2_gate : andg2
	port map(i_A => i_Bit1,
		 i_B=> i_Sel,
		 o_F => s_VALUE_AND2);

	OR_gate : org2
	port map(i_A => s_VALUE_AND1,
		 i_B => s_VALUE_AND2,
		 o_F => o_out);
end structure;

