library IEEE;
use IEEE.std_logic_1164.all;

entity mux5to1 is

port(
	I0,I1,I2,I3,I4 : in std_logic;
	Sel : in std_logic_vector(2 downto 0);
	res : out std_logic);
end mux5to1;

architecture mux_5x1 of mux5to1 is

begin

res <=	I0 when (Sel = "000") else
	I1 when (Sel = "001") else
	I2 when (Sel = "010") else
	I3 when (Sel = "011") else
	I4 when (Sel = "100") else
	'0';

end mux_5x1;

