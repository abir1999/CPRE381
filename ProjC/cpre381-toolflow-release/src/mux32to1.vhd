library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_type.all;


entity mux32to1 is
  
  port(i_A  : in registerArray; --made an array of inputs
	i_S: in std_logic_vector(4 downto 0);
       o_F  : out std_logic_vector(31 downto 0));
end mux32to1;


architecture dataflow of mux32to1 is
 


  begin
    o_F <= i_A(to_integer(unsigned(i_S))); --converts select bits to unsigned integer and this nth input from the array is mapped to output.

end dataflow;



