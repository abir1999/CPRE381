library IEEE;
use IEEE.std_logic_1164.all;

entity shift26 is

port(
	i_A : in std_logic_vector(25 downto 0);
	o_B : out std_logic_vector(27 downto 0));

end shift26;

architecture dataflow of shift26 is

signal shifter : std_logic_vector(27 downto 0);

begin

shifter(25 downto 0) <= i_A;
shifter(27 downto 26) <= "00";
o_B <= shifter;

end dataflow; 