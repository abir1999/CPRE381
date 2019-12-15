library IEEE;
use IEEE.std_logic_1164.all;


entity mux2_1 is
port(i_S          : in std_logic;
       i_A		:in std_logic;
	i_B		:in std_logic;
	o_OUT          : out std_logic);


end mux2_1;

	
architecture structure of mux2_1 is

component invg

port(i_A          : in std_logic;
       o_F          : out std_logic);
end component;

component andg2

port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

component org2

port(i_A          : in std_logic;
       i_B          : in std_logic;
       o_F          : out std_logic);

end component;

-- Signals to store NOT value
  signal sVALUE_not : 		std_logic;
  -- Signal to store AND gate 1 value
  signal sVALUE_and : 		std_logic;
  -- Signal to store AND gate 2 value
  signal sVALUE_and2: 		std_logic;

begin

-- The logic is created here.

g_NOT1: invg
    port MAP(i_A          => i_S,
             o_F               => sVALUE_not);

g_AND1: andg2
	port MAP(
		i_A  =>  sVALUE_not,
		i_B  =>  i_A,
		o_F  =>  sVALUE_and);

g_AND2: andg2
	port MAP(
		i_A  =>  i_S,
		i_B  =>  i_B,
		o_F  =>  sVALUE_and2);

g_OR:  org2
	port MAP(
		i_A  =>  sVALUE_and,
		i_B  =>  sVALUE_and2,
		o_F  =>  o_OUT);
  
end structure;