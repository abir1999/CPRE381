library IEEE;
use IEEE.std_logic_1164.all;

entity add4to32bits is
	generic(N : integer := 32);
	port(in_32bits		: in std_logic_vector(N-1 downto 0);	     
	     o_4plus32bits	: out std_logic_vector(N-1 downto 0);
	     o_COUT	: out std_logic);
end add4to32bits;

architecture structure of add4to32bits is

component fullAddNBitDF is
	generic(N : integer := 32);
	port(i_A	: in std_logic_vector(N-1 downto 0);
	     i_B	: in std_logic_vector(N-1 downto 0);
	     i_Cin	: in std_logic;
	     o_Sum	: out std_logic_vector(N-1 downto 0);
	     o_Cout	: out std_logic);
end component;

--begin port mapping
begin
	add4: fullAddNBitDF
	port map(i_A => in_32bits,
		 i_B => x"00000004",
		 i_Cin => '0',
		 o_Sum => o_4plus32bits,
		 o_Cout => o_COUT);
end structure;