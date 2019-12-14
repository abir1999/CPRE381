library IEEE;
use IEEE.std_logic_1164.all;

package array_type is
  type registerArray is array(0 to 31) of std_logic_vector(31 downto 0); --array size 32 that is 32 bits wide (a 32 x 32 array)
end package array_type;