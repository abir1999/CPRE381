library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity tb_Control is

end tb_Control;

architecture behavior of tb_Control is

component Control
port(		Opcode		: in std_logic_vector(31 downto 26);	-- Bits [31-26] of machine instruction
		Funct		: in std_logic_vector(5 downto 0);		-- Bits [5-0] of machine instruction
		--Bne		: out std_logic;						-- Branch Not Equals, to be anded with (not ALUZero)
		Jump		: out std_logic;
		Branch		: out std_logic;
		MemWrite	: out std_logic;
		MemRead		: out std_logic;
		RegWrite	: out std_logic;
		MemtoReg	: out std_logic;
		ALUSrc		: out std_logic;
		RegDst		: out std_logic;
		ALUOpcode	: out std_logic_vector(5 downto 0);	-- Control signal for ALU
		Lui		: out std_logic;
		ShiftSrc	: out std_logic); --for v-type shifts or shamt from instruction
	
end component;

signal Opcode,Funct,ALUOpcode : std_logic_vector(5 downto 0);
signal Jump,Branch,MemWrite,MemRead,RegWrite,MemtoReg,ALUSrc,RegDst,Lui,ShiftSrc : std_logic;

begin

control_logic : Control
port map(
	Opcode => Opcode,
	Funct => Funct,
	Branch => Branch,
	MemWrite => MemWrite,
	MemRead => MemRead,
	RegWrite => RegWrite,
	MemtoReg => MemtoReg,
	ALUSrc => ALUSrc,
	RegDst => RegDst,
	ALUOpcode => ALUOpcode,
	Lui => Lui,
	ShiftSrc => ShiftSrc);

tbcontrol : process
begin

--addi
Opcode <= "001000";
Funct <= "000000";
wait for 100 ns;

--add
Opcode <= "000000";
Funct <= "100000";
wait for 100 ns;

--addiu
Opcode <= "001001";
Funct <= "000000";
wait for 100 ns;

--addu
Opcode <= "000000";
Funct <= "100001";
wait for 100 ns;

--and
Opcode <= "000000";
Funct <= "100100";
wait for 100 ns;

--andi
Opcode <= "001100";
Funct <= "000000";
wait for 100 ns;

--lui
Opcode <= "001111";
Funct <= "000000";
wait for 100 ns;

--lw
Opcode <= "100011";
Funct <= "000000";
wait for 100 ns;

--nor
Opcode <= "000000";
Funct <= "100111";
wait for 100 ns;

--xor
Opcode <= "100110";
Funct <= "000000";
wait for 100 ns;

--xori
Opcode <= "001110";
Funct <= "000000";
wait for 100 ns;
--or
Opcode <= "000000";
Funct <= "100101";
wait for 100 ns;
--ori
Opcode <= "001101";
Funct <= "000000";
wait for 100 ns;
--slt
Opcode <= "000000";
Funct <= "101010";
wait for 100 ns;
--slti
Opcode <= "001010";
Funct <= "000000";
wait for 100 ns;
--sltiu
Opcode <= "001011";
Funct <= "000000";
wait for 100 ns;
--sltu
Opcode <= "000000";
Funct <= "101011";
wait for 100 ns;
--sll
Opcode <= "000000";
Funct <= "000000";
wait for 100 ns;
--srl
Opcode <= "000000";
Funct <= "000010";
wait for 100 ns;
--sra
Opcode <= "000000";
Funct <= "000011";
wait for 100 ns;
--sllv
Opcode <= "000000";
Funct <= "000100";
wait for 100 ns;
--srlv
Opcode <= "000000";
Funct <= "000110";
wait for 100 ns;
--srav
Opcode <= "000000";
Funct <= "000111";
wait for 100 ns;
--sw
Opcode <= "101011";
Funct <= "000000";
wait for 100 ns;
--sub
Opcode <= "000000";
Funct <= "100010";
wait for 100 ns;
--subu
Opcode <= "000000";
Funct <= "100011";
wait for 100 ns;

wait;
end process;
end behavior;
