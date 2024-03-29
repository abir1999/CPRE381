library IEEE;
use IEEE.std_logic_1164.all;

entity lui_shifter is

port(
	i_A : in std_logic_vector(15 downto 0);
	o_B : out std_logic_vector(31 downto 0));

end lui_shifter;

architecture dataflow of lui_shifter is

signal shifter : std_logic_vector(31 downto 0);

begin

shifter(31 downto 16) <= i_A;
shifter(15 downto 0) <= "0000000000000000";
o_B <= shifter;

end dataflow; 