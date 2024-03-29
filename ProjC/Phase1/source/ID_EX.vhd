library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity ID_EX is
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
	    
end ID_EX;
architecture structure of ID_EX is

               
  --OR gate component
component org2
	port(i_A	: in std_logic;
	     i_B	: in std_logic;
	     o_F	: out std_logic);
end component;


--1 bit cpmlementer
component invg
  port(i_A  : in std_logic;
       o_F  : out std_logic);

end component;

--32 bit synchronous dff component (a 32bit register)
component dff32_pipe
generic(N	: integer :=32);
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input (32 bits)
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output (32 bits)
end component;

--1 bit synchronous dff coponent
component dff_pipe
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D       : in std_logic;     -- Data value input (1 bit)
       o_Q       : out std_logic);   -- Data value output (1 bit)
end component;

signal s_we : std_logic;	--write enable should be 0 while stalling   
signal s_flushreset : std_logic;

begin

	staller: invg
	port map(i_A  => stall,
             o_F  => s_we);
				 
	flushORreset : org2
	port map(i_A => flush,
			i_B => reset,
			o_F => s_flushreset);
	
	PCp4: dff32_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_PCp4,
		 o_Q   => o_PCp4);
	
	ALUOpcode: dff32_pipe
	generic map( N => 6)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_ALUOpcode,
		 o_Q   => o_ALUOpcode);
		 
	ALUSrc: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_ALUSrc,
		 o_Q   => o_ALUSrc);
	
	RegDst: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_RegDst,
		 o_Q   => o_RegDst);
		 
	Instrc: dff32_pipe
	generic map(N => 32)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Instr,
		 o_Q   => o_Instr);
		 
	Rdata1: dff32_pipe
	generic map(N => 32)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_RData1,
		 o_Q   => o_RData1);
		 
	Rdata2: dff32_pipe
	generic map(N => 32)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_RData2,
		 o_Q   => o_RData2);
	
	ImmiExt: dff32_pipe
	generic map(N => 32)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_ImmiExt,
		 o_Q   => o_ImmiExt);
	
	Rs: dff32_pipe
	generic map(N => 5)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Rs,
		 o_Q   => o_Rs);
	
	Rt: dff32_pipe
	generic map(N => 5)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Rt,
		 o_Q   => o_Rt);

	Rd: dff32_pipe
	generic map(N => 5)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Rd,
		 o_Q   => o_Rd);
	
	LUI32bit: dff32_pipe
	generic map(N => 32)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_32LUI,
		 o_Q   => o_32LUI);
		
	Lui: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Lui,
		 o_Q   => o_Lui);
	
	Jump: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Jump,
		 o_Q   => o_Jump);
		 
	ShiftSrc: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_ShiftSrc,
		 o_Q   => o_ShiftSrc);
		 
	MemWrite: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_MemWrite,
		 o_Q   => o_MemWrite);
		 
	MemRead: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_MemRead,
		 o_Q   => o_MemRead);
		 
	RegWrite: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_RegWrite,
		 o_Q   => o_RegWrite);
		 
	MemToReg: dff_pipe
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_MemToReg,
		 o_Q   => o_MemToReg);
		 
	Reg2: dff32_pipe
	generic map(N => 32)
	port map(i_CLK => clk,
		 i_RST => s_flushreset,
		 i_WE  => s_we,
		 i_D   => i_Register2,
		 o_Q   => o_Register2);	 
		 
end structure;