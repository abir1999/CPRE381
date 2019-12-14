-- a sign/zero extender  when sign input is 0, does zero padding, when sign input is 1, does sign extension

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity extender is 

generic (
	Z : integer := 16
	);

	port 
	(
	input : in std_logic_vector(Z-1 downto 0);
	output : out std_logic_vector(31 downto 0);
	sign : in std_logic
	);

end extender;


architecture dataflow of extender is
  
--signal temp : std_logic_vector(31 downto 0) := x"FFFFFFFF";
--signal temp_out : std_logic_vector(31 downto 0);
 
 begin

G0 : for i in 0 to Z-1 generate
output(i) <= input(i);  --store the 16 bits of input in output (remaining 16 bits of output are still U)

end generate;

G1 : for i in Z to 31 generate  --loop from bit 15 to 31

--temp_out(i) <= sign and input(Z-1); --testing purpose
output(i) <= sign and input(Z-1);  -- pad with value from highest input bit, AND with sign (zero/sign extension)

end generate;

 
end dataflow;