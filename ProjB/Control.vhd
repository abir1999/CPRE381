library IEEE;
use IEEE.std_logic_1164.all;

entity Control is
	
   port(	Opcode		: in std_logic_vector(31 downto 26);	-- Bits [31-26] of machine instruction
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
	
end Control;


architecture behavior of Control is
begin

	Lui		<= '1' when (Opcode = "001111") 
			else '0';

	ShiftSrc	<= '1' when (Opcode = "000000" and Funct = "000100") or
					(Opcode = "000000" and Funct = "000110") or
					(Opcode = "000000" and Funct = "000111") else
			   '0';

	
-- regDst is 1 in R-type, when opcode is 000000
	RegDst		<= '1' when (Opcode = "000000") else
			   '-' when (Opcode = "101011") or
			       	    (Opcode = "000100") or
			            (Opcode = "000101") or
			            (Opcode = "101011") or
			            (Opcode = "000010") or
			            (Opcode = "000011") or
				    (Opcode = "000000" and Funct = "001000") 
				else '0';

	Jump		<= '1' when (Opcode = "000010") or
				    (Opcode = "000011") or
				    (Opcode = "000000" and Funct = "001000") 
				else '0';


	Branch 		<= '1' when (Opcode = "000100") else '0';	

	MemWrite	<= '1' when Opcode = "101011" else '0';

	MemRead		<= '1' when (Opcode = "100011") else '0'; -- lw

	RegWrite	<= '0' when (Opcode = "101011") or							-- Sw
				    (Opcode = "000100") or							-- Beq
				    (Opcode = "000101") or							-- Bne
				    (Opcode = "000010") or 							-- J
				    --(Opcode = "000011") or							-- Jal	 - Writes to reg 31
				    (Opcode = "000000" and Funct = "001000")		-- Jr
				   else '1';

	MemtoReg	<= '1' when (Opcode = "100011") else
			    '-' when (Opcode = "101011") or							-- Sw
				     (Opcode = "000100") or							-- Beq
				     (Opcode = "000101") or							-- Bne
				     (Opcode = "000010") or 							-- J
				     (Opcode = "000011") or							-- Jal
				     (Opcode = "000000" and Funct = "001000")		-- Jr
				else '0';

	AlUSrc		<= '1' when (Opcode = "001000") or
				     (Opcode = "001001") or
			   	     (Opcode = "001100") or
				     (Opcode = "001111") or
			   	     (Opcode = "100011") or
				     (Opcode = "001110") or
			   	     (Opcode = "001101") or
				     (Opcode = "001010") or
			   	     (Opcode = "001011") or
				     (Opcode = "101011") or
			   	     (Opcode = "000100") or
				     (Opcode = "000101") or
			   	     (Opcode = "000010") or
				     (Opcode = "000011") else '0';

	
	ALUOpcode  <= 		"001000" when 	(Opcode = "001000") or
						(Opcode = "000000" and Funct = "100000") or
						(Opcode = "100011") or
						(Opcode = "101011") or
						(Opcode = "000000" and Funct = "001000")  else --jr uses add
				"101000" when	(Opcode = "001001") or (Opcode = "000000" and Funct = "100001") else  --unsigned addition
			 	 "000000" when	(Opcode = "000000" and Funct = "100100") or
						(Opcode = "001100") else
			 	 "000011" when	(Opcode = "000000" and Funct = "100111") else
			  	 "010000" when 	(Opcode = "000000" and Funct = "100110") or 
						(Opcode = "001110") else
				"000100" when	(Opcode = "000000" and Funct  = "100101")or
						(Opcode = "001101") else
				"001101" when	(Opcode = "000000" and Funct = "101010")or --slt
						(Opcode = "001010")else
				"101101" when	(Opcode = "001011") or --sltiu
						(Opcode = "000000" and Funct = "101011")else --sltu
				"100000" when 	(Opcode = "000000" and Funct = "000000") or --sll,sllv
						(Opcode = "000000" and Funct = "000100") else
				"110000" when	(Opcode = "000000" and Funct = "000010")or --srl,sllv
						(Opcode = "000000" and Funct = "000110") else
				"111000" when	(Opcode = "000000" and Funct = "000011")or --sra,srav
						(Opcode = "000000" and Funct = "000111") else
				"001001" when	(Opcode = "000000" and Funct = "100010") or
						(Opcode = "000100") or 
						(Opcode = "000101") else
				"101001" when	(Opcode = "000000" and Funct = "100011"); -- subu
				
end behavior;
