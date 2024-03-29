library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity tb_pipeline is
generic(gCLK_HPER   : time := 50 ns);
end tb_pipeline;

architecture behavior of tb_pipeline is

constant cCLK_PER  : time := gCLK_HPER * 2; 

component IF_ID
generic( N: integer:=32);
port(	flush	: in std_logic;			--When flush is 1, all write_en should be 0
	     stall	: in std_logic;			--When stall is 1, all write_en should be 0
	     data32in	: in std_logic_vector(N-1 downto 0); --32bit instruction
	     PCreg_in	: in std_logic_vector(N-1 downto 0); --input for PC+4
	     data32out	: out std_logic_vector(N-1 downto 0); --when flush is 1, it outputs zero so it works like a NO-OP
	     PCreg_out	: out std_logic_vector(N-1 downto 0);
	     clk	: in std_logic);
		 
end component;

signal InstIN, PC_IN : std_logic_vector(31 downto 0);
signal data32outID,PCreg_outID : std_logic_vector(31 downto 0);

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
signal ALUinEX : std_logic_vector(31 downto 0);

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
signal o_RtMEM, o_RdMEM : std_logic_vector(4 downto 0);
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
signal o_RtWB, o_RdWB : std_logic_vector(4 downto 0);
signal o_RegDstWB, o_LuiWB, o_JumpWB, o_RegWriteWB,o_MemToRegWB : std_logic;
signal MemDataIn : std_logic_vector (31 downto 0);

signal s_clock : std_logic;
begin

  P_CLK: process
  begin
    s_clock <= '0';
    wait for gCLK_HPER;
    s_clock <= '1';
    wait for gCLK_HPER;
  end process;


IF_IDpipe : IF_ID
port map(
		flush	=> '0',
	     stall	=> '0',
	     data32in	=> InstIN,
	     PCreg_in	=> PC_IN,
	     data32out	=> data32outID,
	     PCreg_out	=> PCreg_outID,
	     clk	=> s_clock);

ID_EXpipe : ID_EX
port map(flush => '0',
	     stall => '0',
		 clk => s_clock,
		 reset => '0',
	   
	   i_PCp4 => PCreg_outID,
	   o_PCp4 => o_PCp4EX,
	   
		i_ALUOpcode => data32outID(31 downto 26),
		o_ALUOpcode =>o_ALUOpcodeEX,
		
		i_ALUSrc => data32outID(0),
		o_ALUSrc =>o_ALUSrcEX,
		
		i_RegDst => data32outID(1),	
		o_RegDst => o_RegDstEX,

		i_Instr	=> data32outID,
		o_Instr	=> o_InstrEX,
		
		i_RData1 => x"B001EA3F",
		o_RData1 => o_RData1EX,
		
		i_RData2 => x"11223344",
		o_RData2 => o_RData2EX,
	   
		i_ImmiExt =>x"11111111",
		o_ImmiExt => o_ImmiExtEX,
	   
		i_Rs => data32outID(31 downto 27),
		o_Rs=> o_RsEX,
		
		i_Rt => data32outID(27 downto 23),
		o_Rt => o_RtEX,
		
		i_Rd => data32outID(23 downto 19),
		o_Rd => o_RdEX,
		
		i_32LUI => data32outID,
		o_32LUI	=> 	o_32LUIEX,
		
		i_Register2	=> x"FFFF0000",
		o_Register2 => o_Register2EX,
		
		i_Lui => data32outID(5),	
		o_Lui => o_LuiEX,
		
		i_Jump => data32outID(6),
		o_Jump => o_JumpEX,
		
		i_ShiftSrc => data32outID(7),
		o_ShiftSrc => o_ShiftSrcEX,
			
		i_MemWrite => data32outID(8),
		o_MemWrite => o_MemWriteEX,
		
		i_MemRead => data32outID(9),
		o_MemRead => o_MemReadEX,
		
		i_RegWrite => data32outID(10),
		o_RegWrite => o_RegWriteEX,
		
		i_MemToReg => data32outID(11),
		o_MemToReg	=> o_MemToRegEX);
		
		
EX_MEMpipe: EX_MEM
port map(
		flush => '0',
	    stall=> '0',
		clk	=> s_clock,
		reset=> '0',
	   
	   i_PCp4 => o_PCp4EX,
	   o_PCp4=> o_PCp4MEM,
		
		i_RegDst => o_RegDstEX,
		o_RegDst => o_RegDstMEM,

		i_Instr	=> o_InstrEX,
		o_Instr	=> o_InstrMEM,	
		
		i_ALUOut => ALUinEX,
		o_ALUOut => o_ALUOutMEM,
		
		i_RData2 => o_RData2EX, 
		o_RData2=> o_RData2MEM,
	   
		i_Rt =>o_RtEX, 		
		o_Rt => o_RtMEM,
		
		i_Rd => o_RdEX,	
		o_Rd => o_RdMEM,
		
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
		
MEM_WBpipe: MEM_WB
port map(
		flush => '0',
	    stall=> '0',
		clk	=> s_clock,
		reset=> '0',
	   
	   i_PCp4 => o_PCp4MEM,
	   o_PCp4=> o_PCp4WB,
		
		i_RegDst => o_RegDstMEM,
		o_RegDst => o_RegDstWB,

		i_Instr	=> o_InstrMEM,
		o_Instr	=> o_InstrWB,	
		
		i_ALUOut => o_ALUOutMEM,
		o_ALUOut => o_ALUOutWB,
		
		i_MemData => MemDataIn, 
		o_MemData=> o_MemDataWB,
	   
		i_Rt =>o_RtMEM, 		
		o_Rt => o_RtWB,
		
		i_Rd => o_RdMEM,	
		o_Rd => o_RdWB,
		
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
	
		
 pipelineTB: process
  begin
  
  --first instruction
 InstIN <= x"1234ABCD";
PC_IN <= x"ABCD1234";
wait for cCLK_PER;

--second instruction
 InstIN <= x"FFFFFFFF";
PC_IN <= x"00000000";
wait for cCLK_PER;

ALUinEX <= x"ABAB1212"; --cycle 3 ALUoutput generated
wait for cCLK_PER;

MemDataIn <= x"00FF00FF"; --cycle 4 MEMdata generated 
wait for cCLK_PER;

wait for cCLK_PER;

wait for cCLK_PER;

wait for cCLK_PER;

wait for cCLK_PER;

wait;

end process;

end behavior;
  