library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity comparator is
	port(compA : in std_logic_vector (31 downto 0);
		compB  : in std_logic_vector (31 downto 0);
		compOut : out std_logic);
		
end comparator;


architecture dataflow of comparator is

signal compare: std_logic_vector (31 downto 0);

begin

compare <= compA XNOR compB;

process(compare)
begin
if(compare = x"FFFFFFFF") then
compOut <= '1';
else
compOut <= '0';
end if;
end process;

end dataflow;