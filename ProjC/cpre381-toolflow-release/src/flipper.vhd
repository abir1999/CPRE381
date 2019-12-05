library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity flipper is
	generic(N : integer := 32);
	port(in_A : in std_logic_vector(N-1 downto 0);
	     flip_A : out std_logic_vector(N-1 downto 0));
end flipper;
architecture dataflow of flipper is

signal s_flipped : std_logic_vector(31 downto 0);

begin
	flip: for i in 0 to N-1 generate
		s_flipped(i) <= in_A(N-1-i); --flip and store in a signal
	end generate;

flip_A <= s_flipped; --set the output to the flipped signal

end dataflow;