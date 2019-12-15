library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder5to32 is
  
  port(i_A  : in std_logic_vector(4 downto 0);
       o_F  : out std_logic_vector(31 downto 0));
end decoder5to32;


architecture dataflow of decoder5to32 is
 
 signal s_shifter : unsigned(31 downto 0):= x"00000001"; --start at bit 0 enabled

  begin
    o_F <= std_logic_vector(SHIFT_LEFT(unsigned(s_shifter), to_integer(unsigned(i_A)))); --converts the i_A binary value to int, shifts the signal by that amount of bits

end dataflow;