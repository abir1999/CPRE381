library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID is
	generic(N	: integer :=32);
	port(flush	: in std_logic;			--When flush is 1, all write_en should be 0
	     stall	: in std_logic;			--When stall is 1, all write_en should be 0
	     data32in	: in std_logic_vector(N-1 downto 0);
	     PCreg_in	: in std_logic_vector(N-1 downto 0);
	     data32out	: out std_logic_vector(N-1 downto 0);
	     PCreg_out	: out std_logic_vector(N-1 downto 0);
	     clk	: in std_logic);
end IF_ID;
architecture structure of IF_ID is

               
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

--1 bit cpmlementer
component invg
  port(i_A  : in std_logic;
       o_F  : out std_logic);

end component;

--32 bit synchronous dff component
component dff32_pipe
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
       i_Data       : in std_logic;     -- Data value input (1 bit)
       o_Data       : out std_logic);   -- Data value output (1 bit)
end component;

signal s_we : std_logic;	--write enable should be 0 while stalling  
signal s_data: std_logic_vector(N-1 downto 0);  


begin

	staller: invg
	port map(i_A  => stall,
                 o_F  => s_we);

	flushDATA: dff32_pipe
	port map(i_CLK => clk,
		 i_RST => flush,
		 i_WE  => s_we,
		 i_D   => data32in,
		 o_Q   => data32out);
	storePC: dff32_pipe
	port map(i_CLK => clk,
		 i_RST => '0',
		 i_WE  => s_we,
		 i_D   => PCreg_in,
		 o_Q   => PCreg_out);
end structure;