library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity fwd_compare is
	port(compA : in std_logic;
	     compB : in std_logic;
	     compOut : out std_logic);
		
end fwd_compare;


architecture dataflow of fwd_compare is


begin

compOut <= compA XNOR compB;

end dataflow;