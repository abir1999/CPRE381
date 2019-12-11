library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity fwd_unit is
	port(	MEM_rd : in std_logic_vector (4 downto 0);
		WB_rd  : in std_logic_vector (4 downto 0);
		MEM_regWr : in std_logic;
		WB_regWr  : in std_logic;
		read1_in  : in std_logic_vector (4 downto 0);
		read2_in  : in std_logic_vector (4 downto 0);
		fwd_out1  : out std_logic_vector (2 downto 0);
		fwd_out2  : out std_logic_vector (2 downto 0));

end fwd_unit;

--OR gate component
component org2
	port(i_A	: in std_logic;
	     i_B	: in std_logic;
	     o_F	: out std_logic);
end component;

component fwd_compare
	port(compA   : in std_logic;
	     compB   : in std_logic;
	     compOut : out std_logic);
end component;

component fwd_compare5 is
	port(compA   : in std_logic_vector (4 downto 0);
	     compB   : in std_logic_vector (4 downto 0);
	     compOut : out std_logic);
end component;

architecture structure of fwd_unit is

signal some: std_logic_vector (4 downto 0);
signal s_noWrite: std_logic;
signal s_cmprMEM1: std_logic;
signal s_cmprMEM2: std_logic;
signal s_cmprWB1: std_logic;
signal s_cmprWB2: std_logic;

begin

	OR_gate : org2
	port map(i_A => MEM_regWr,
		 i_B => WB_regWr,
		 o_F => s_noWrite);

	cmprMEM1: fwd_compare5
	port map(compA =>read1_in,
		 compB =>MEM_rd,
		 compOut=>s_cmprMEM1);

	cmprWB1: fwd_compare5
	port map(compA =>read1_in,
		 compB =>WB_rd,
		 compOut=>s_cmprWB1);

	cmprMEM2: fwd_compare5
	port map(compA =>read2_in,
		 compB =>MEM_rd,
		 compOut=>s_cmprMEM2);

	cmprWB2: fwd_compare5
	port map(compA =>read2_in,
		 compB =>WB_rd,
		 compOut=>s_cmprMWB2);

	fwd_out1 <= "00";
	fwd_out2 <= "00";
	
process(s_noWrite)
begin
if(compare = "11111") then
	compOut <= '1';
else
	compOut <= '0';
end if;
end process;

end structure;