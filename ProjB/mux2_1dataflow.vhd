library IEEE;
use IEEE.std_logic_1164.all;


entity mux2_1dataflow is
generic( N: integer := 32);

port(	i_S  : in std_logic;
	i_A  : in std_logic_vector(N-1 downto 0);
	i_B  : in std_logic_vector(N-1 downto 0);	
	o_F  : out std_logic_vector(N-1 downto 0));


end mux2_1dataflow;

	
architecture dataflow of mux2_1dataflow is

begin

-- We loop through and instantiate and connect N invg modules
G1: for i in 0 to N-1 generate

	o_F(i) <= ((NOT i_S) AND i_A(i)) OR (i_S AND i_B(i));

end generate;

  
end dataflow;