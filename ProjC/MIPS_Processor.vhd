-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal v0             : std_logic_vector(N-1 downto 0); -- TODO: should be assigned to the output of register 2, used to implement the halt SYSCALL
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. This case happens when the syscall instruction is observed and the V0 register is at 0x0000000A. This signal is active high and should only be asserted after the last register and memory writes before the syscall are guaranteed to be completed.

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

component pc_reg
generic(	N	: integer :=32);
port(		 data_in	: in std_logic_vector(N-1 downto 0);
	    	 reset_PC	: in std_logic;
	     	 wr_en_PC	: in std_logic;
	    	 data_out	: out std_logic_vector(N-1 downto 0);
	    	 clk	: in std_logic);
end component;


component add4to32bits
generic (N : integer := 32);
port(	in_32bits	: in std_logic_vector(N-1 downto 0);	     
	o_4plus32bits	: out std_logic_vector(N-1 downto 0);
	o_COUT		: out std_logic);

end component; 

 component ripple_adder
 generic (N: integer:=32);
 port(	
	i_Cin : in std_logic;
	i_B0 : in std_logic_vector (N-1 downto 0);
	i_B1 : in std_logic_vector (N-1 downto 0);
	o_Out : out std_logic_vector (N-1 downto 0); --including final carry out
	o_cout: out std_logic);
end component;

component control
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

component regfile
port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_Waddr      : in std_logic_vector(4 downto 0);
       i_Raddr1     : in std_logic_vector(4 downto 0);
       i_Raddr2     : in std_logic_vector(4 downto 0);
       i_Din        : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Qout1      : out std_logic_vector(N-1 downto 0);    --Data output 1
	o_Qout2     : out std_logic_vector(N-1 downto 0);
	register2   : out std_logic_vector(31 downto 0));   -- Data output 2

end component;

component mux2_1dataflow
generic( N: integer := 32);
port(	i_S  : in std_logic;
	i_A  : in std_logic_vector(N-1 downto 0);
	i_B  : in std_logic_vector(N-1 downto 0);	
	o_F  : out std_logic_vector(N-1 downto 0));

end component;

component extender
generic (Z : integer := 16);
port(
	input : in std_logic_vector(Z-1 downto 0);
	output : out std_logic_vector(31 downto 0);
	sign : in std_logic);
end component;

component big_alu
port(
	opcode 	: in  std_logic_vector(5 downto 0);
	in_A 	: in std_logic_vector (31 downto 0);
	in_B	: in std_logic_vector (31 downto 0);
	shftamt	: in std_logic_vector (4 downto 0);
	output_alu	: out std_logic_vector (31 downto 0);
	o_overflow : out std_logic;
	o_carryout : out std_logic;
	o_Zero : out std_logic);

end component;

component lui_shifter
port(
	i_A : in std_logic_vector(15 downto 0);
	o_B : out std_logic_vector(31 downto 0));

end component;

--signals for Control--
	signal s_Opcode		: std_logic_vector(5 downto 0);	-- Bits [31-26] of machine instruction
	signal s_Funct		: std_logic_vector(5 downto 0);	-- Bits [5-0] of machine instruction
	signal s_Lui		: std_logic;
	signal s_Jump		: std_logic;
	signal s_Branch		: std_logic;
	signal s_MemWrite	: std_logic;
	signal s_MemRead	: std_logic;
	signal s_RegWrite	: std_logic;
	signal s_MemtoReg	: std_logic;
	signal s_ALUSrc		: std_logic;
	signal s_RegDst		: std_logic;
	signal s_ShiftSrc	: std_logic;
	signal s_ALUOpcode	: std_logic_vector(5 downto 0);

--PC signals--
	signal pc_out	: std_logic_vector(31 downto 0);
	signal adder_out : std_logic_vector(31 downto 0);

--regfile signals--
	signal s_regdata1 : std_logic_vector(31 downto 0);
	signal s_regdata2 : std_logic_vector(31 downto 0);

	signal s_immi_extend : std_logic_vector(31 downto 0);
	signal s_ALUSrc_mux  : std_logic_vector(31 downto 0);

--ALU signals--
	signal s_overflow,s_Zero,s_carryout : std_logic;
	signal s_ALUOut : std_logic_vector(31 downto 0);
	signal s_shiftmux : std_logic_vector(4 downto 0);
	signal s_alu_mem_out : std_logic_vector(31 downto 0);

--addition control mux signals--
	signal s_lui_mux_out, s_lui_out : std_logic_vector(31 downto 0);

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  s_Halt <='1' when (s_Inst(31 downto 26) = "000000") and (s_Inst(5 downto 0) = "001100") and (v0 = "00000000000000000000000000001010") else '0';

  -- TODO: Implement the rest of your processor below this comment! 


PC: pc_reg
generic map( N => 32)
port map(    data_in	=> adder_out,
	     reset_PC	=> iRST,
	     wr_en_PC	=> '1',
	     data_out	=> pc_out,
	     clk	=> iCLK);

pcadder : add4to32bits
generic map( N => 32)
port map(	in_32bits	=> pc_out,	     
		o_4plus32bits	=> adder_out);
		--o_COUT		=> ;

s_NextInstAddr <= pc_out;

ctrl: Control
port map(	Opcode		=> s_Opcode,
		Funct		=> s_Funct,
		ShiftSrc	=> s_ShiftSrc,		
		Lui		=> s_Lui,
		Jump		=> s_Jump,
		Branch		=> s_Branch, --not hooked to anything
		MemWrite	=> s_MemWrite,
		MemRead		=> s_MemRead,
		RegWrite	=> s_RegWrite,
		MemtoReg	=> s_MemtoReg,
		ALUSrc		=> s_ALUSrc,
		RegDst		=> s_RegDst,
		ALUOpcode	=> s_ALUOpcode);

s_Opcode <= s_Inst(31 downto 26);
s_Funct	 <= s_Inst(5 downto 0);
s_RegWr  <= s_RegWrite;

regdst_mux : mux2_1dataflow
generic map(N => 5)
port map(	i_S	=> s_RegDst,
		i_A	=> s_Inst(20 downto 16),
		i_B	=> s_Inst(15 downto 11),
		o_F	=> s_RegWrAddr);


register_file: regfile
port map(	i_CLK        => iCLK,
      		i_RST        => iRST,
      		i_WE         => s_RegWr,
       		i_Waddr      => s_RegWrAddr,
       		i_Raddr1     => s_Inst(25 downto 21),
       		i_Raddr2     => s_Inst(20 downto 16),
       		i_Din        => s_RegWrData,
       		o_Qout1      => s_regdata1,
		o_Qout2      => s_regdata2,
		register2    => v0);

immi_extend : extender
port map(	input  => s_Inst(15 downto 0),
		output => s_immi_extend,
		sign   => '1');

ALUsrc_mux : mux2_1dataflow
port map(	i_S	=> s_ALUSrc,
		i_A 	=> s_regdata2,
		i_B	=> s_immi_extend,
		o_F	=> s_ALUSrc_mux);

mainALU : big_alu
port map(	opcode 		=> s_ALUOpcode,
		in_A 		=> s_regdata1,
		in_B		=> s_ALUSrc_mux,
		shftamt		=> s_shiftmux, -- choose from v-type shift or R-type shamt.
		output_alu	=> s_ALUOut,
		o_overflow 	=> s_overflow,
		o_carryout 	=> s_carryout,
		o_Zero 		=> s_Zero);

oALUOut <= s_ALUOut;

s_DMemWr	<= s_MemWrite; --from Control unit
s_DMemAddr	<= s_ALUOut; --address from ALU output
s_DMemData	<= s_regdata2;  --write data to mem from regfile read data 2

shiftmux : mux2_1dataflow
generic map( N => 5)
port map(	i_S	=> s_ShiftSrc,
		i_A 	=> s_Inst(10 downto 6),
		i_B	=> s_regdata1(4 downto 0),
		o_F	=> s_shiftmux);
	
ALUorMEM_mux : mux2_1dataflow
port map(	i_S	=> s_MemtoReg,
		i_A 	=> s_ALUOut,
		i_B	=> s_DMemOut,
		o_F	=> s_alu_mem_out);

luishifter: lui_shifter
port map(	i_A	=> s_Inst(15 downto 0),
		o_B	=> s_lui_out);

lui_mux : mux2_1dataflow
port map(	i_S	=> s_Lui,
		i_A	=> s_alu_mem_out,
		i_B	=> s_lui_out,
		o_F	=> s_lui_mux_out);

s_RegWrData <= s_lui_mux_out;

end structure;

