library IEEE;
use IEEE.std_logic_1164.all;

entity big_alu is

port(

	opcode 	: in  std_logic_vector(5 downto 0);
	in_A 	: in std_logic_vector (31 downto 0);
	in_B	: in std_logic_vector (31 downto 0);
	shftamt	: in std_logic_vector (4 downto 0);
	output_alu	: out std_logic_vector (31 downto 0);
	o_overflow : out std_logic;
	o_carryout : out std_logic;
	o_Zero : out std_logic);

end big_alu;

architecture structure of big_alu is

component alu
port(
	A :		in std_logic_vector(31 downto 0);
	B : 		in std_logic_vector(31 downto 0);
	unsignd:	in std_logic;
	OPCODE :	in std_logic_vector(4 downto 0);
	o_Overflow: 	out std_logic;
	o_ResultF: 	out std_logic_vector(31 downto 0);
	o_Carryout: 	out std_logic;
	o_zero: 	out std_logic);
end component;

component shiftall
generic( N: integer := 32);
port(
	     input_A : in std_logic_vector(N-1 downto 0);
	     shiftBy_Sel : in std_logic_vector(4 downto 0);
	     left_right_Sel: in std_logic;
	     log_arith_Sel: in std_logic;
	     out_Shift : out std_logic_vector(N-1 downto 0));
end component;

component mux2_1dataflow
generic( N: integer := 32);

port(	i_S  : in std_logic;
	i_A  : in std_logic_vector(N-1 downto 0);
	i_B  : in std_logic_vector(N-1 downto 0);	
	o_F  : out std_logic_vector(N-1 downto 0));
end component;


signal s_aluout, s_shifterout : std_logic_vector(31 downto 0);
signal s_outputsrc ,s_overflow: std_logic;

begin

process(OPCODE)
begin
if(OPCODE = "100000") then
s_outputsrc <= '1';
if(OPCODE = "110000") then
s_outputsrc <= '1';
if(OPCODE = "111000") then
s_outputsrc <= '1';
else
s_outputsrc <= '0';
end if;
end process;


mainalu : alu
port map(
	A => in_A,
	B => in_B,
	unsignd => OPCODE(5);
	OPCODE => opcode(4 downto 0),
	o_Overflow => s_overflow,
	o_ResultF => s_aluout,
	o_Carryout => o_carryout,
	o_zero => o_Zero);

shifter : shiftall
port map(
	input_A => in_A,
	shiftBy_Sel => shftamt,
	left_right_Sel => opcode(4),
	log_arith_Sel => opcode(3),
	out_Shift => s_shifterout);

aluselect : mux2_1dataflow
port map(
	i_S => s_outputsrc,
	i_A => s_aluout,
	i_B => s_shifterout,
	o_F => output_alu);

add_subunsigned : mux2_1dataflow  --when unsigned we want overflow = 0
port map(
	i_S => OPCODE(5),
	i_A => s_overflow,
	i_B => '0',
	o_F => o_overflow);

end structure;



	
