library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity fwd_compare5 is
	port(compA : in std_logic_vector (4 downto 0);
		compB  : in std_logic_vector (4 downto 0);
		compOut : out std_logic);
		
end fwd_compare5;


architecture dataflow of fwd_compare5 is

signal compare: std_logic_vector (4 downto 0);

begin

compare <= compA XNOR compB;

process(compare)
begin
	if(compare = "11111") then
		compOut <= '1';
	else
		compOut <= '0';
	end if;
end process;

end dataflow;