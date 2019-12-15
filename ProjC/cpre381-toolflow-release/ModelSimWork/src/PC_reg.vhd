library IEEE;
use IEEE.std_logic_1164.all;

entity PC_reg is
	generic(N	: integer :=32);
	port(data_in	: in std_logic_vector(N-1 downto 0);
	     reset_PC	: in std_logic;
	     stallPC	: in std_logic;
	     data_out	: out std_logic_vector(N-1 downto 0);
	     clk	: in std_logic);
end PC_reg;
architecture structure of PC_reg is

signal s_data	:  std_logic_vector(N-1 downto 0);
signal s_we	:  std_logic;
signal s_wr_en	:  std_logic;
signal resetTO  : std_logic_vector (31 downto 0);

component invg

	port(i_A          : in std_logic;
       o_F          : out std_logic);
end component;

  --OR gate component
component org2
	port(i_A	: in std_logic;
	     i_B	: in std_logic;
	     o_F	: out std_logic);
end component;

--mux 32 to1 component
component mux32_2to1 is
	port(i_Bit0	: in std_logic_vector(N-1 downto 0);
	     i_Bit1	: in std_logic_vector(N-1 downto 0);
	     i_Sel	: in std_logic;
	     o_out	: out std_logic_vector(N-1 downto 0));
end component;


--dff component
component dff32bit
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input (32 bits)
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output (32 bits)
end component;




begin

	resetTO <= x"00400000";

	notStall:invg
	port map(i_A  =>stallPC,
			o_F  =>s_wr_en);
	
	
	rstORwre: org2
	port map(i_A => reset_PC,
		 i_B => s_wr_en,
		 o_F => s_we);

	chooseData: mux32_2to1
	port map(i_Bit0 => data_in,
		 i_Bit1 => x"00400000",
		 i_Sel  => reset_PC,
		 o_out  => s_data);

	resetDATA: dff32bit
	port map(i_CLK => clk,
		 i_RST => '0',
		 i_WE  => s_we,
		 i_D   => s_data,
		 o_Q   => data_out);
end structure;