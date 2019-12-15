library IEEE;
use IEEE.std_logic_1164.all;

entity ripple_adder is
generic (N: integer:=5);
port(	
	i_Cin : in std_logic;
	i_B0 : in std_logic_vector (N-1 downto 0);
	i_B1 : in std_logic_vector (N-1 downto 0);
	o_Out : out std_logic_vector (N-1 downto 0); --including final carry out
	o_cout: out std_logic);
end ripple_adder;

architecture structure of ripple_adder is

-- Declare the component we are going to instantiate
component full_adder
port(	
	i_P0 : in std_logic;
	i_P1 : in std_logic;
	i_Cin : in std_logic;
	o_Sum : out std_logic;
	o_Cout : out std_logic);

end component;

signal s_carry : std_logic_vector(N downto 0);
--signal s_sum : std_logic_vector(N-1 downto 0);

begin

s_carry(0) <= i_Cin; 

G1: for i in 0 to N-1 generate

set_of_full_adder : full_adder

port map(
	i_P0 => i_B0(i),
	i_P1 => i_B1(i),
	i_Cin => s_carry(i),
	o_Sum => o_Out(i),
	o_Cout => s_carry(i+1));
	
end generate;

o_cout <= s_carry(N);
--o_Out <= s_carry(N) & s_sum; --using concatenation because seperate carry bit doesnt look nice

end structure;

