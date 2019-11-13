library IEEE;
use IEEE.std_logic_1164.all;
use work.array_type.all;

entity regfile is
generic (N: integer := 32);
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
	

end regfile;

architecture structure of regfile is
  
component regn
generic(N: integer := 32);
port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
end component;

component decoder5to32

port(i_A  : in std_logic_vector(4 downto 0);
       o_F  : out std_logic_vector(31 downto 0));
end component;

component mux32to1

port(i_A  : in registerArray; --made an array of inputs
	i_S: in std_logic_vector(4 downto 0);
       o_F  : out std_logic_vector(31 downto 0));

end component;


signal sSel_wr : std_logic_vector(31 downto 0);
signal WEandWR : std_logic_vector(31 downto 0);
signal o_Rout : registerArray; --32 bit register ouput

begin

decoder : decoder5to32
port MAP(i_A => i_Waddr,
	o_F  =>  sSel_wr);

readmux1: mux32to1
port MAP(
	i_A => o_Rout,
	i_S => i_Raddr1,
	o_F  => o_Qout1
);


readmux2: mux32to1
port MAP(
	i_A => o_Rout,
	i_S => i_Raddr2,
	o_F  => o_Qout2
);

registerzero : regn
port MAP(
	i_CLK => i_CLK,
	i_RST => '1',
	i_WE  => '0', --$zero is always set to 0, cant write to it.
	i_D => x"00000000",
	o_Q => o_Rout(0)
);


register2 <= o_Rout(2);

G1: for i in 1 to 31 generate

WEandWR(i) <= i_WE AND sSel_wr(i); -- decoder output signal AND with Write enable

registerN : regn

port map( 
	i_CLK => i_CLK,
	i_RST => i_RST,
	i_WE => WEandWR(i),
	i_D => i_Din,
	o_Q => o_Rout(i));

end generate;
end structure;