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

---Some changes done in phase 1: in the EX stage decide $31 or Rd = newRD, in mem stage choose whether newRD or Rt

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

--Abhilash added:---------------------------------
component shift26
port(	i_A : in std_logic_vector(25 downto 0);
		o_B : out std_logic_vector(27 downto 0));
end component;

component shiftALL
generic(N : integer := 32);
port(	input_A : in std_logic_vector(N-1 downto 0);
	     shiftBy_Sel : in std_logic_vector(4 downto 0);
	     left_right_Sel: in std_logic;
	     log_arith_Sel: in std_logic;
	     out_Shift : out std_logic_vector(N-1 downto 0));
end component;

component BEQvsBNE
port(  i_beq          : in std_logic;
       i_bne          : in std_logic;
       i_zero	      : in std_logic;
       o_PCsrc        : out std_logic);
end component;
--------------------------------------------------

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
port(	Opcode		: in std_logic_vector(31 downto 26);	-- Bits [31-26] of machine instruction
		Funct		: in std_logic_vector(5 downto 0);		-- Bits [5-0] of machine instruction
		Bne			: out std_logic;						-- Branch Not Equals, to be anded with (not ALUZero)
		Jump		: out std_logic;
		JumpType	: out std_logic;
		Beq			: out std_logic;
		MemWrite	: out std_logic;
		MemRead		: out std_logic;
		RegWrite	: out std_logic;
		MemtoReg	: out std_logic;
		ALUSrc		: out std_logic;
		RegDst		: out std_logic;
		ALUOpcode	: out std_logic_vector(5 downto 0);	-- Control signal for ALU
		Lui			: out std_logic;
		ShiftSrc	: out std_logic; --for v-type shifts or shamt from instruction
		BoolImmi	: out std_logic);
	
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
	signal s_JumpType	: std_logic;
	signal s_Beq		: std_logic;
	signal s_Bne		:std_logic;
	signal s_MemWrite	: std_logic;
	signal s_MemRead	: std_logic;
	signal s_RegWrite	: std_logic;
	signal s_MemtoReg	: std_logic;
	signal s_ALUSrc		: std_logic;
	signal s_RegDst		: std_logic;
	signal s_ShiftSrc	: std_logic;
	signal s_BoolImmi 	: std_logic;
	signal s_ALUOpcode	: std_logic_vector(5 downto 0);

--PC signals--
	signal pc_out	: std_logic_vector(31 downto 0);
	signal pcadder_out : std_logic_vector(31 downto 0);
	signal shifted28 : std_logic_vector(27 downto 0);	--Abhilash	= shifted 26 bit (from j-types) by 2
	signal s_28PC4	 : std_logic_vector(31 downto 0);	--Abhilash	=concat (PC+4) &  shifted28
	signal s_shiftBranch: std_logic_vector(31 downto 0);--Abhilash	=shifted s_immi_extend by 2
	signal s_BranchPC:	std_logic_vector(31 downto 0);  --Abhilash  =(PC+4)+imm
	signal s_Br_adderout: std_logic_vector(31 downto 0); --Abhilash mux result between 0:(adder_out) and 1:((PC+4)+imm)
	signal s_finalPC, s_JJal_Jr : std_logic_vector(31 downto 0);
	signal s_PCsrc : std_logic;
--regfile signals--
	signal s_regdata1 : std_logic_vector(31 downto 0);
	signal s_regdata2 : std_logic_vector(31 downto 0);
	signal s_register2: std_logic_vector(31 downto 0);

	signal s_immi_extend : std_logic_vector(31 downto 0);
	signal s_ALUSrc_mux  : std_logic_vector(31 downto 0);
	signal s_finalWriteAddr : std_logic_vector(4 downto 0);

--ALU signals--
	signal s_overflow,s_Zero,s_carryout : std_logic;
	signal s_ALUOut : std_logic_vector(31 downto 0);
	signal s_shiftmux : std_logic_vector(4 downto 0);
	signal s_alu_mem_out : std_logic_vector(31 downto 0);

--addition control mux signals--
	signal s_lui_mux_out, s_lui_out : std_logic_vector(31 downto 0);
--------------------------phase 2 stuff----------------------
	signal s_Rd_or_Rt : std_logic_vector(4 downto 0);
	signal s_JALMuxout  : std_logic_vector(31 downto 0);


--proj C phase 1 pipeline addition

component IF_ID
generic( N: integer:=32);
port(	flush	: in std_logic;			--When flush is 1, all write_en should be 0
	     stall	: in std_logic;			--When stall is 1, all write_en should be 0
	     reset	: in std_logic;
		 data32in	: in std_logic_vector(N-1 downto 0); --32bit instruction
	     PCreg_in	: in std_logic_vector(N-1 downto 0); --input for PC+4
	     data32out	: out std_logic_vector(N-1 downto 0); --when flush is 1, it outputs zero so it works like a NO-OP
	     PCreg_out	: out std_logic_vector(N-1 downto 0);
	     clk	: in std_logic);
		 
end component;

signal InstrOutID,PCOutID : std_logic_vector(31 downto 0);

component ID_EX
port(flush	: in std_logic;			--When flush is 1, all write_en should be 0
	     stall	: in std_logic;			--When stall is 1, all write_en should be 0
		 clk	: in std_logic;
		 reset	: in std_logic;
	   
	   i_PCp4	: in std_logic_vector(31 downto 0);
	   o_PCp4	: out std_logic_vector(31 downto 0);
	   
	   
	   -- Control signals -- 
		i_ALUOpcode: in std_logic_vector(5 downto 0);		-- ALUControl output from Control from ID
		o_ALUOpcode: out std_logic_vector(5 downto 0);		-- ALUControl output from Control for EXE
		
		i_ALUSrc	: in std_logic;							-- ALUSrc output from Control from ID
		o_ALUSrc	: out std_logic;						-- ALUSrc output from Control for EXE
		
		i_RegDst	: in std_logic;							-- RegDst output from Control from ID (Need this until WB stage)
		o_RegDst	: out std_logic;						-- RegDst output from Control for EXE
	   
		-- Normal signals --
		i_Instr		: in std_logic_vector(31 downto 0);		-- Instr output from ID
		o_Instr		: out std_logic_vector(31 downto 0);	-- Instr output for EXE
		
		i_RData1	: in std_logic_vector(31 downto 0);		-- Read Data 1 output from ID
		o_RData1	: out std_logic_vector(31 downto 0);	-- Read Data 1 output for EXE
		
		i_RData2	: in std_logic_vector(31 downto 0);		-- Read Data 2 output from ID
		o_RData2	: out std_logic_vector(31 downto 0);	-- Read Data 2 output for EXE
	   
		i_ImmiExt		: in std_logic_vector(31 downto 0);		-- Sign Extend output from ID
		o_ImmiExt		: out std_logic_vector(31 downto 0);	-- Sign Extend output for EXE
	   
		i_Rs		: in std_logic_vector(4 downto 0);		-- Rs output from ID
		o_Rs		: out std_logic_vector(4 downto 0);		-- Rs output for EXE
		
		i_Rt		: in std_logic_vector(4 downto 0);		-- Rt output from ID
		o_Rt		: out std_logic_vector(4 downto 0);		-- Rt output for EXE
		
		i_Rd		: in std_logic_vector(4 downto 0);		-- Rd output from ID
		o_Rd		: out std_logic_vector(4 downto 0);		-- Rd output for EXE
		
		i_32LUI		: in std_logic_vector(31 downto 0);		-- Output of Lui immediate mux from ID
		o_32LUI		: out std_logic_vector(31 downto 0);	-- Output of Lui immediate mux for EXE
		
		i_Register2	: in std_logic_vector(31 downto 0);		-- Output of Register2 from ID, used to halt program
		o_Register2	: out std_logic_vector(31 downto 0);	-- Output of Register2 for EXE, used to halt program
		
		-- Later control signals --
		i_Lui		: in std_logic;		-- Lui output from Control from ID
		o_Lui		: out std_logic;	-- Lui output from Control for EXE
		
		i_Jump		: in std_logic;
		o_Jump		: out std_logic;
		--no need BoolImmi
		
		i_ShiftSrc	: in std_logic;
		o_ShiftSrc	: out std_logic;
			
		i_MemWrite	: in std_logic;		-- MemWrite output from Control from EXE
		o_MemWrite	: out std_logic;	-- MemWrite output from Control for MEM
		
		i_MemRead	: in std_logic;		-- MemRead output from Control from EXE
		o_MemRead	: out std_logic;	-- MemRead output from Control for MEM
		
		i_RegWrite	: in std_logic;		-- RegWrite output from Control from EXE
		o_RegWrite	: out std_logic;	-- RegWrite output from Control for MEM
		
		i_MemToReg	: in std_logic;		-- MemToReg output from Control from EXE
		o_MemToReg	: out std_logic);	-- MemToReg output from Control for MEM
end component;

signal o_PCp4EX, o_InstrEX, o_RData1EX, o_RData2EX, o_ImmiExtEX, o_32LUIEX,o_Register2EX : std_logic_vector(31 downto 0);
signal o_ALUOpcodeEX : std_logic_vector(5 downto 0);
signal o_RsEX, o_RtEX, o_RdEX : std_logic_vector(4 downto 0);
signal o_ALUSrcEX, o_RegDstEX, o_LuiEX, o_JumpEX, o_ShiftSrcEX, o_MemWriteEX, o_MemReadEX,o_RegWriteEX,o_MemToRegEX : std_logic;

component EX_MEM
port(flush	: in std_logic;			--When flush is 1, all write_en should be 0
	     stall	: in std_logic;			--When stall is 1, all write_en should be 0
		 clk	: in std_logic;
		 reset	: in std_logic;
	   
	   i_PCp4	: in std_logic_vector(31 downto 0);
	   o_PCp4	: out std_logic_vector(31 downto 0);
	   
	   
	   -- Control signals -- 
		
		i_RegDst	: in std_logic;							-- RegDst output from Control from ID (Need this until WB stage)
		o_RegDst	: out std_logic;						-- RegDst output from Control for EXE
	   
		-- Normal signals --
		i_Instr		: in std_logic_vector(31 downto 0);		-- Instr output from ID
		o_Instr		: out std_logic_vector(31 downto 0);	-- Instr output for EXE
		
		i_ALUOut	: in std_logic_vector(31 downto 0);	
		o_ALUOut	: out std_logic_vector(31 downto 0);	
		
		i_RData2	: in std_logic_vector(31 downto 0);		-- Read Data 2 output from ID
		o_RData2	: out std_logic_vector(31 downto 0);	-- Read Data 2 output for EXE
	   
		--i_ImmiExt		: in std_logic_vector(31 downto 0);		-- Sign Extend output from ID
		--o_ImmiExt		: out std_logic_vector(31 downto 0);	-- Sign Extend output for EXE
		
		i_Rt		: in std_logic_vector(4 downto 0);		-- Rt output from ID
		o_Rt		: out std_logic_vector(4 downto 0);		-- Rt output for EXE
		
		i_Rd		: in std_logic_vector(4 downto 0);		-- Rd output from ID
		o_Rd		: out std_logic_vector(4 downto 0);		-- Rd output for EXE

		i_FinalRegAddr : in std_logic_vector(4 downto 0); 
		o_FinalRegAddr : out std_logic_vector(4 downto 0);
		
		i_32LUI		: in std_logic_vector(31 downto 0);		-- Output of Lui immediate mux from ID
		o_32LUI		: out std_logic_vector(31 downto 0);	-- Output of Lui immediate mux for EXE
		
		i_Register2	: in std_logic_vector(31 downto 0);		-- Output of Register2 from ID, used to halt program
		o_Register2	: out std_logic_vector(31 downto 0);	-- Output of Register2 for EXE, used to halt program
		
		-- Later control signals --
		
		i_Jump		: in std_logic;		--jump control input from Ex pipeline
		o_Jump		: out std_logic;	--jump control for Mem pipeline
		
		i_Lui		: in std_logic;		-- Lui output from Control from ID
		o_Lui		: out std_logic;	-- Lui output from Control for EXE
			
		i_MemWrite	: in std_logic;		-- MemWrite output from Control from EXE
		o_MemWrite	: out std_logic;	-- MemWrite output from Control for MEM
		
		i_MemRead	: in std_logic;		-- MemRead output from Control from EXE
		o_MemRead	: out std_logic;	-- MemRead output from Control for MEM
		
		i_RegWrite	: in std_logic;		-- RegWrite output from Control from EXE
		o_RegWrite	: out std_logic;	-- RegWrite output from Control for MEM
		
		i_MemToReg	: in std_logic;		-- MemToReg output from Control from EXE
		o_MemToReg	: out std_logic);	-- MemToReg output from Control for MEM
end component;

signal o_PCp4MEM, o_InstrMEM, o_RData2MEM, o_32LUIMEM,o_Register2MEM, o_ALUOutMEM : std_logic_vector(31 downto 0);
signal o_RtMEM, o_RdMEM, o_FinalRegAddrMEM : std_logic_vector(4 downto 0);
signal o_RegDstMEM, o_LuiMEM, o_JumpMEM, o_MemWriteMEM, o_MemReadMEM,o_RegWriteMEM,o_MemToRegMEM : std_logic;

component MEM_WB
port(flush	: in std_logic;			--When flush is 1, all write_en should be 0
	     stall	: in std_logic;			--When stall is 1, all write_en should be 0
		 clk	: in std_logic;
		 reset	: in std_logic;
	   
	   i_PCp4	: in std_logic_vector(31 downto 0);
	   o_PCp4	: out std_logic_vector(31 downto 0);
	   
	   
	   -- Control signals -- 
		
		i_RegDst	: in std_logic;							-- RegDst output from Control from ID (Need this until WB stage)
		o_RegDst	: out std_logic;						-- RegDst output from Control for EXE
	   
		-- Normal signals --
		i_Instr		: in std_logic_vector(31 downto 0);		-- Instr output from ID
		o_Instr		: out std_logic_vector(31 downto 0);	-- Instr output for EXE
		
		i_ALUOut	: in std_logic_vector(31 downto 0);	
		o_ALUOut	: out std_logic_vector(31 downto 0);	
		
		i_MemData	: in std_logic_vector(31 downto 0);
		o_MemData	: out std_logic_vector(31 downto 0);
		
	   
		--i_ImmiExt		: in std_logic_vector(31 downto 0);		-- Sign Extend output from ID
		--o_ImmiExt		: out std_logic_vector(31 downto 0);	-- Sign Extend output for EXE
		
		i_Rt		: in std_logic_vector(4 downto 0);		-- Rt output from ID
		o_Rt		: out std_logic_vector(4 downto 0);		-- Rt output for EXE
		
		i_Rd		: in std_logic_vector(4 downto 0);		-- Rd output from ID
		o_Rd		: out std_logic_vector(4 downto 0);		-- Rd output for EXE

		i_FinalRegAddr : in std_logic_vector(4 downto 0); 
		o_FinalRegAddr : out std_logic_vector(4 downto 0);
		
		i_32LUI		: in std_logic_vector(31 downto 0);		-- Output of Lui immediate mux from ID
		o_32LUI		: out std_logic_vector(31 downto 0);	-- Output of Lui immediate mux for EXE
		
		i_Register2	: in std_logic_vector(31 downto 0);		-- Output of Register2 from ID, used to halt program
		o_Register2	: out std_logic_vector(31 downto 0);	-- Output of Register2 for EXE, used to halt program
		
		-- Later control signals --
		i_Lui		: in std_logic;		-- Lui output from Control from ID
		o_Lui		: out std_logic;	-- Lui output from Control for EXE
			
		i_Jump		: in std_logic;		--jump control input from mem pipeline
		o_Jump		: out std_logic;	--jump control for WB stage
		
		i_RegWrite	: in std_logic;		-- RegWrite output from Control from EXE
		o_RegWrite	: out std_logic;	-- RegWrite output from Control for MEM
		
		i_MemToReg	: in std_logic;		-- MemToReg output from Control from EXE
		o_MemToReg	: out std_logic);	-- MemToReg output from Control for MEM
end component;

signal o_PCp4WB, o_InstrWB, o_32LUIWB,o_Register2WB, o_ALUOutWB,o_MemDataWB  : std_logic_vector(31 downto 0);
signal o_RtWB, o_RdWB,o_FinalRegAddrWB : std_logic_vector(4 downto 0);
signal o_RegDstWB, o_LuiWB, o_JumpWB, o_RegWriteWB,o_MemToRegWB : std_logic;

component comparator
port(compA : in std_logic_vector (31 downto 0);
		compB  : in std_logic_vector (31 downto 0);
		compOut : out std_logic);
end component;

signal s_CompOut : std_logic;

begin
	--IF STAGE---
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
  

  s_Halt <='1' when (o_InstrWB(31 downto 26) = "000000") and (o_InstrWB(5 downto 0) = "001100") and (v0 = "00000000000000000000000000001010") else '0';

--IF stage
PC: pc_reg
generic map( N => 32)
port map(    data_in	=> s_finalPC,	--Abhilash added: change pcadder_out to whatever final signal happens to be (s_finalPC)
	     reset_PC	=> iRST,
	     wr_en_PC	=> '1',
	     data_out	=> pc_out,
	     clk	=> iCLK);

s_NextInstAddr <= pc_out; --instruction mem address

pcadder : add4to32bits
generic map( N => 32)
port map(	in_32bits	=> pc_out,	     
		o_4plus32bits	=> pcadder_out); --use this for new PC in straight line case
		--o_COUT		=> ;


--IF/ID register goes here****

IF_IDpipe : IF_ID
port map(
		 flush	=> '0',
	     stall	=> '0',
		 reset	=> iRST,
	     data32in	=> s_Inst, -- the instruction
	     PCreg_in	=> pcadder_out, --the PC+4 value from IF stage
	     data32out	=> InstrOutID,
	     PCreg_out	=> PCOutID,
	     clk	=> iCLK);



--ID STAGE ---
----Abhilash added:------BRANCH AND JUMP STUFF IN ID STAGE
shft26	:  shift26
port map(	i_A	=>	InstrOutID(25 downto 0),
			o_B	=>	shifted28);

s_28PC4 <= PCOutID(31 downto 28) & shifted28; --Jump address

jal_jr :	mux2_1dataflow
port map (	i_S  => s_JumpType, 
			i_A  => s_28PC4,  --if mux's selector =0,choose s_28PC4
			i_B  => s_regdata1,	--if mux's selector =1,choose s_regdata1
			o_F  => s_JJal_Jr); -- put s_JJal_Jr in signal initialization. s_JJal_Jr is the output b/w jr and jal/jump addr
			
shiftBranch: shiftALL --shift left 2 for branch operations
port map(	input_A => s_immi_extend,
			shiftBy_Sel => "00010",
			left_right_Sel => '0',
			log_arith_Sel => '0',
			out_Shift =>s_shiftBranch);

add_BranchAddr: ripple_adder
port map(	i_Cin => '0',
			i_B0  => PCOutID, --pc+4 
			i_B1  => s_shiftBranch, --the 16bit shifted 2 left output**
			o_Out => s_BranchPC); --including final carry out
			--o_cout: out std_logic);

--COMPARATOR REPLACING ZERO BIT ALU
compare : comparator
port map(
		compA => s_regdata1,
		compB => s_regdata2,
		compOut => s_CompOut);

PCsrcVal :  BEQvsBNE
port map(i_beq     => s_Beq, 
		 i_bne     => s_Bne,	--put s_bne in signal initialization. s_bne is a part of a control signal
		 i_zero	   => s_CompOut,  -- the comparator output decides
		 o_PCsrc   => s_PCsrc);	--put s_PCsrc in signal initialization. s_PCsrc is a part of a control signal

PCsrcMUX :	mux2_1dataflow
port map (	i_S  => s_PCsrc, --DONE: change s_Beq to (s_Branch).(Z) + (~Z).(Bne)
			i_A  => pcadder_out,  --if mux's selector =0,choose pcadder_out (PC + 4) (from IF stage)
			i_B  => s_BranchPC,	--if mux's selector =1,choose s_BranchPC
			o_F  => s_Br_adderout);

finalPCmux: mux2_1dataflow
port map (	i_S  => s_Jump, 	
			i_A  => s_Br_adderout,  --if mux's selector =0,choose s_Br_adderout
			i_B  => s_JJal_Jr,	--if mux's selector =1,choose s_JJal_Jr
			o_F  => s_finalPC);	--put s_finalPC in signal initialization. s_finalPC is the value that goes in PCreg
			

---------------------------------------------------------------------------


ctrl: Control
port map(	Opcode		=> s_Opcode,
		Funct		=> s_Funct,
		ShiftSrc	=> s_ShiftSrc,
		BoolImmi	=> s_BoolImmi,
		Lui		=> s_Lui,
		Jump		=> s_Jump,
		JumpType	=> s_JumpType,
		Beq			=> s_Beq,
		Bne			=> s_Bne,
		MemWrite	=> s_MemWrite,
		MemRead		=> s_MemRead,
		RegWrite	=> s_RegWrite,
		MemtoReg	=> s_MemtoReg,
		ALUSrc		=> s_ALUSrc,
		RegDst		=> s_RegDst,
		ALUOpcode	=> s_ALUOpcode);

s_Opcode <= InstrOutID(31 downto 26);
s_Funct	 <= InstrOutID(5 downto 0);
s_RegWr  <= o_RegWriteWB; -- changing this to the WB stage regwrite signal

register_file: regfile
port map(	i_CLK        => iCLK,
      		i_RST        => iRST,
      		i_WE         => s_RegWr,
       		i_Waddr      => s_RegWrAddr,
       		i_Raddr1     => InstrOutID(25 downto 21),
       		i_Raddr2     => InstrOutID(20 downto 16),
       		i_Din        => s_RegWrData,
       		o_Qout1      => s_regdata1,
			o_Qout2      => s_regdata2,
			register2    => s_register2);

immi_extend : extender
port map(	input  => InstrOutID(15 downto 0),
		output => s_immi_extend,
		sign   => s_BoolImmi);
		
luishifter: lui_shifter
port map(	i_A	=> InstrOutID(15 downto 0),
		o_B	=> s_lui_out);

--ID/EX PIPELINE GOES HERE  just after the regfile
ID_EXpipe : ID_EX
port map(flush => '0',
	     stall => '0',
		 clk => iCLK,
		 reset => iRST,
	   
	   i_PCp4 => PCOutID,
	   o_PCp4 => o_PCp4EX,
	   
		i_ALUOpcode =>s_ALUOpcode,
		o_ALUOpcode =>o_ALUOpcodeEX,
		
		i_ALUSrc => s_ALUSrc,
		o_ALUSrc =>o_ALUSrcEX,
		
		i_RegDst => s_RegDst,	
		o_RegDst => o_RegDstEX,

		i_Instr	=> InstrOutID,
		o_Instr	=> o_InstrEX,
		
		i_RData1 => s_regdata1,
		o_RData1 => o_RData1EX,
		
		i_RData2 => s_regdata2,
		o_RData2 => o_RData2EX,
	   
		i_ImmiExt =>s_immi_extend,
		o_ImmiExt => o_ImmiExtEX,
	   
		i_Rs => InstrOutID(25 downto 21),
		o_Rs=> o_RsEX,
		
		i_Rt => InstrOutID(20 downto 16),
		o_Rt => o_RtEX,
		
		i_Rd => InstrOutID(15 downto 11),
		o_Rd => o_RdEX,
		
		i_32LUI => s_lui_out,
		o_32LUI	=> 	o_32LUIEX,
		
		i_Register2	=> s_register2,
		o_Register2 => o_Register2EX,
		
		i_Lui => s_Lui,	
		o_Lui => o_LuiEX,
		
		i_Jump =>s_Jump,
		o_Jump => o_JumpEX,
		
		i_ShiftSrc => s_ShiftSrc,
		o_ShiftSrc => o_ShiftSrcEX,
			
		i_MemWrite => s_MemWrite,
		o_MemWrite => o_MemWriteEX,
		
		i_MemRead => s_MemRead,
		o_MemRead => o_MemReadEX,
		
		i_RegWrite => s_RegWrite,
		o_RegWrite => o_RegWriteEX,
		
		i_MemToReg => s_MemtoReg,
		o_MemToReg	=> o_MemToRegEX);

--Final destination address (register to write to) decided in EX stage, and passed to pipelines
Rd_or_Rt_EX : mux2_1dataflow --choose Rd or Rt as Write address to register file
generic map(N => 5)
port map(	i_S	=> o_RegDstEX,
		i_A	=> o_RtEX,
		i_B	=> o_RdEX,
		o_F	=> s_Rd_or_Rt);
		
RtRD_or_31 : mux2_1dataflow  --selects between rt/rd and $31(for JAL insturction's write to reg $ra)
generic map(N => 5)
port map(i_S	=> o_JumpEX,
		i_A	=> s_Rd_or_Rt,
		i_B	=> "11111",  --write to reg31
		o_F	=> s_finalWriteAddr);


ALUsrc_mux : mux2_1dataflow
port map(	i_S	=> o_ALUSrcEX,
		i_A 	=> o_RData2EX,
		i_B	=> o_ImmiExtEX,
		o_F	=> s_ALUSrc_mux);

mainALU : big_alu
port map(	opcode 	=>o_ALUOpcodeEX,
		in_A 		=> o_RData1EX,
		in_B		=> s_ALUSrc_mux,
		shftamt		=> s_shiftmux, -- choose from v-type shift or R-type shamt.
		output_alu	=> s_ALUOut,
		o_overflow 	=> s_overflow,
		o_carryout 	=> s_carryout,
		o_Zero 		=> s_Zero);

--- alu out in EX stage to final signal ***
oALUOut <= s_ALUOut;

shiftmux : mux2_1dataflow
generic map( N => 5)
port map(	i_S	=> o_ShiftSrcEX,
		i_A 	=> o_InstrEX(10 downto 6),
		i_B	=> o_RData1EX(4 downto 0),
		o_F	=> s_shiftmux);
	
	
EX_MEMpipe: EX_MEM
port map(
		flush => '0',
	    stall=> '0',
		clk	=> iCLK,
		reset=> iRST,
	   
	   i_PCp4 => o_PCp4EX,
	   o_PCp4=> o_PCp4MEM,
		
		i_RegDst => o_RegDstEX,
		o_RegDst => o_RegDstMEM,

		i_Instr	=> o_InstrEX,
		o_Instr	=> o_InstrMEM,	
		
		i_ALUOut => s_ALUOut,
		o_ALUOut => o_ALUOutMEM,
		
		i_RData2 => o_RData2EX, 
		o_RData2=> o_RData2MEM,
	   
		i_Rt =>o_RtEX, 		
		o_Rt => o_RtMEM,
		
		i_Rd => o_RdEX,	
		o_Rd => o_RdMEM,

		i_FinalRegAddr => s_finalWriteAddr,
		o_FinalRegAddr => o_FinalRegAddrMEM,
		
		i_32LUI	=> o_32LUIEX,
		o_32LUI	=> o_32LUIMEM,
		
		i_Register2	=> o_Register2EX,
		o_Register2	=>o_Register2MEM,
			
		i_Jump	=> o_JumpEX,	
		o_Jump	=> o_JumpMEM,
		
		i_Lui	=> o_LuiEX, 	
		o_Lui	=> o_LuiMEM,
			
		i_MemWrite	=> o_MemWriteEX,
		o_MemWrite	=> o_MemWriteMEM,
		
		i_MemRead	=> o_MemReadEX,
		o_MemRead	=> o_MemReadMEM,
		
		i_RegWrite	=> o_RegWriteEX,
		o_RegWrite	=> o_RegWriteMEM,
		
		i_MemToReg	=> o_MemToRegEX,
		o_MemToReg	=> o_MemToRegMEM);
	
--at mem stage pipeline
s_DMemWr	<= o_MemWriteMEM; --from Control unit
s_DMemAddr	<= o_ALUOutMEM; --address from ALU output
s_DMemData	<= o_RData2MEM;  --write data to mem from regfile read data 2
	
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);
	
MEM_WBpipe: MEM_WB
port map(
		flush => '0',
	    stall=> '0',
		clk	=> iCLK,
		reset=> iRST,
	   
	   i_PCp4 => o_PCp4MEM,
	   o_PCp4=> o_PCp4WB,
		
		i_RegDst => o_RegDstMEM,
		o_RegDst => o_RegDstWB,

		i_Instr	=> o_InstrMEM,
		o_Instr	=> o_InstrWB,	
		
		i_ALUOut => o_ALUOutMEM,
		o_ALUOut => o_ALUOutWB,
		
		i_MemData => s_DMemOut, 
		o_MemData=> o_MemDataWB,
	   
		i_Rt =>o_RtMEM, 		
		o_Rt => o_RtWB,
		
		i_Rd => o_RdMEM,	
		o_Rd => o_RdWB,

		i_FinalRegAddr => o_FinalRegAddrMEM, 
		o_FinalRegAddr => o_FinalRegAddrWB,
		
		i_32LUI	=> o_32LUIMEM,
		o_32LUI	=> o_32LUIWB,
		
		i_Register2	=> o_Register2MEM,
		o_Register2	=>o_Register2WB,
			
		i_Jump	=> o_JumpMEM,
		o_Jump	=> o_JumpWB,
		
		i_Lui	=> o_LuiMEM, 	
		o_Lui	=> o_LuiWB,
		
		i_RegWrite	=> o_RegWriteMEM,
		o_RegWrite	=> o_RegWriteWB,
		
		i_MemToReg	=> o_MemToRegMEM,
		o_MemToReg	=> o_MemToRegWB);

	
ALUorMEM_mux : mux2_1dataflow
port map(	i_S	=> o_MemToRegWB,
		i_A 	=> o_ALUOutWB,
		i_B	=> o_MemDataWB,
		o_F	=> s_alu_mem_out);
		
JALwriteMux : mux2_1dataflow
port map(	i_S	=> o_JumpWB,
		i_A 	=> s_alu_mem_out,
		i_B	=> o_PCp4WB,
		o_F	=> s_JALMuxout);

lui_mux : mux2_1dataflow
port map(	i_S	=> o_LuiWB,
		i_A	=> s_JALMuxout,
		i_B	=> o_32LUIWB,
		o_F	=> s_lui_mux_out);

s_RegWrData <= s_lui_mux_out; --final write data to regfile that comes from WB stage
v0 <= o_Register2WB;

s_RegWrAddr <= o_FinalRegAddrWB;

end structure;

