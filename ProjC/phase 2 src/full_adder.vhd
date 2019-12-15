library IEEE;
use IEEE.std_logic_1164.all;

-- This is an empty entity so we don't need to declare ports
entity full_adder is

port(	
	i_P0 : in std_logic;
	i_P1 : in std_logic;
	i_Cin : in std_logic;
	o_Sum : out std_logic;
	o_Cout : out std_logic);

end full_adder;

architecture structure of full_adder is

-- Declare the component we are going to instantiate
component xorg2

 port(i_A          : in std_logic;
       i_B          : in std_logic;
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

-- Signals to store XOR value
  signal sVALUE_xor : 		std_logic;
  -- Signal to store AND gate 1 value
  signal sVALUE_and : 		std_logic;
  -- Signal to store AND gate 2 value
  signal sVALUE_and2: 		std_logic;

begin 

xor1: xorg2
port MAP(
	i_A => i_P0,
	i_B => i_P1,
	o_F => sVALUE_xor);

xor2: xorg2
port MAP(
	i_A  =>  sVALUE_xor,
	i_B  =>  i_Cin,
	o_F  =>  o_Sum);

and1: andg2
port MAP(
	i_A => i_P0,
	i_B => i_P1,
	o_F => sVALUE_and);

and2: andg2
port MAP(
	i_A => sVALUE_xor,
	i_B => i_Cin,
	o_F => sVALUE_and2);

or1 : org2
port MAP(
	i_A => sVALUE_and,
	i_B => sVALUE_and2,
	o_F => o_Cout);

end structure;