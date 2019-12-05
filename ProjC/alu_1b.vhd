library IEEE;
use IEEE.std_logic_1164.all;

entity alu_1b is

  port(	i_A     	: in std_logic;
       	i_B     	: in std_logic;
	A_inv		: in std_logic;
	B_inv		: in std_logic;
	i_Carrin	: in std_logic;
	i_less		: in std_logic;
	i_opcode	: in std_logic_vector(2 downto 0);
	o_result	: out std_logic;
	o_carryOut	: out std_logic;
	o_set		: out std_logic;
	o_overflow	: out std_logic);

end alu_1b;

architecture dataflow of alu_1b is

signal s_and,s_or,s_xor,s_sum,s_cout,s_cin,s_notA,s_notB,s_overflow : std_logic;
signal s_muxA,s_muxB : std_logic;


component full_adder
port( i_P0 : in std_logic;
	i_P1 : in std_logic;
	i_Cin : in std_logic;
	o_Sum : out std_logic;
	o_Cout : out std_logic);
end component;

component mux5to1
port( I0,I1,I2,I3,I4 : in std_logic;
	Sel : in std_logic_vector(2 downto 0);
	res : out std_logic);

end component;

component mux2_1
port(	i_S  : in std_logic;
	i_A  : in std_logic;
	i_B  : in std_logic;	
	o_OUT  : out std_logic);
end component;


begin

alu : full_adder
port map (
	i_P0 => s_muxB,
	i_P1 => s_muxA,
	i_Cin => i_Carrin,
	o_Sum => s_sum,
	o_Cout => s_cout);

s_notA <= not i_A;

muxA : mux2_1
port map(
	i_S => A_inv,
	i_A => i_A,
	i_B => s_notA,
	o_OUT => s_muxA);

s_notB <= not i_B;

muxB : mux2_1
port map(
	i_S => B_inv,
	i_A => i_B,
	i_B => s_notB,
	o_OUT => s_muxB);


s_Cin <= i_Carrin;
s_and <= s_muxA and s_muxB;
s_or <= s_muxA or s_muxB;
s_xor <= s_muxA xor s_muxB;
s_overflow <= s_cin xor s_cout;
o_overflow <= s_overflow;
o_carryOut <= s_cout;
o_set <= s_sum;

bigmux : mux5to1
port map(
	res => o_result,
	Sel => i_opcode,
	I0 => s_and,
	I1 => s_or,
	I2 => s_sum,
	I3 => i_less,
	I4 => s_xor);

end dataflow;
