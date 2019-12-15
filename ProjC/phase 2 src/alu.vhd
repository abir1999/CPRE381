library IEEE;
use IEEE.std_logic_1164.all;

entity alu is

port(
	A :		in std_logic_vector(31 downto 0);
	B : 		in std_logic_vector(31 downto 0);
	OPCODE :	in std_logic_vector(4 downto 0);
	unsignd:  	in std_logic;
	o_Overflow: 	out std_logic;
	o_ResultF: 	out std_logic_vector(31 downto 0);
	o_Carryout: 	out std_logic;
	o_zero: 	out std_logic);

end alu;

architecture structure of alu is


component alu_1b
port(
	i_A     	: in std_logic;
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
end component;

component xorg2 
port(  i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;

component invg
port(i_A          : in std_logic;
       o_F          : out std_logic);
end component;

component mux2_1dataflow
generic( N: integer := 1);
port(	i_S :in std_logic;
	i_A :in std_logic_vector(N-1 downto 0);
	i_B :in std_logic_vector(N-1 downto 0);
	o_F :out std_logic_vector(N-1 downto 0));
end component;

component andg2
port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);
end component;




signal s_carry  : std_logic_vector(32 downto 0);
signal s_set, s_overflow: std_logic_vector(31 downto 0);
signal s_slt : std_logic;
signal f_zer : std_logic:='0';
signal s_output : std_logic_vector(31 downto 0);
signal s_setsel : std_logic_vector(0 downto 0);
signal s_carryinvert : std_logic_vector(0 downto 0);
signal s_setbit : std_logic_vector(0 downto 0);

begin

o_Resultf <= s_output;
s_carry(0) <= OPCODE(0); --2's compliment subtraction purposes
o_Carryout <= s_carry(32);
o_Overflow <= s_overflow(31);

process(s_output)
begin
if(s_output = x"00000000") then
o_zero <= '1';
else
o_zero <= '0';
end if;
end process;

invertcarry : invg
port map(
	i_A => s_carry(32),
	o_F => s_carryinvert(0));

setsel : mux2_1dataflow
port map(
	i_S => unsignd,
	i_A => s_setbit,
	i_B => s_carryinvert,
	o_F => s_setsel);

xor1: xorg2
port map(
	i_A => s_setsel(0),
	i_B => s_overflow(31),
	o_F => s_slt);

andset : andg2
port map(i_A      => s_set(31),
       i_B        => '1',
       o_F        => s_setbit(0));


full_alu : alu_1b
port map(
	i_A => A(0),
	i_B => B(0),
	A_inv => OPCODE(1),
	B_inv => OPCODE(0),
	i_Carrin => s_carry(0),
	i_less => s_slt,
	i_opcode => OPCODE(4 downto 2),
	o_result => s_output(0),
	o_overflow => s_overflow(0),
	o_carryOut => s_carry(1),
	o_set => s_set(0));



G1: for i in 1 to 31 generate

full_alu : alu_1b

port map(
	i_A => A(i),
	i_B => B(i),
	A_inv => OPCODE(1),
	B_inv => OPCODE(0),
	i_Carrin => s_carry(i),
	i_less => f_zer,
	i_opcode => OPCODE(4 downto 2),
	o_result => s_output(i),
	o_overflow => s_overflow(i),
	o_carryOut => s_carry(i+1),
	o_set => s_set(i));
	
end generate;

end structure;