library IEEE;
use IEEE.std_logic_1164.all;

entity BEQvsBNE is

  port(i_beq          : in std_logic;
       i_bne          : in std_logic;
       i_zero	      : in std_logic;
       o_PCsrc        : out std_logic);

end BEQvsBNE;

architecture structure of BEQvsBNE is

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


--signals to be used for BEQvsBNE
signal s_beq_z, s_bne_z, s_notZero	: std_logic;
begin

	NOT_Z : invg
	port map(i_A => i_zero,
		 o_F => s_notZero);

	AND_beqZ : andg2 
	port map(i_A => i_beq,
		 i_B => i_zero,
		 o_F => s_beq_z);

	AND_bneZ : andg2
	port map(i_A => i_bne,
		 i_B=> s_notZero,
		 o_F => s_bne_z);

	OR_gate : org2
	port map(i_A => s_beq_z,
		 i_B => s_bne_z,
		 o_F => o_PCsrc);
end structure;