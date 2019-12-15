library IEEE;
use IEEE.std_logic_1164.all;

entity fullAddNBitDF is
	generic(N : integer := 32);
	port(i_A		: in std_logic_vector(N-1 downto 0);
	     i_B		: in std_logic_vector(N-1 downto 0);
	     i_Cin		: in std_logic;
	     o_Sum	: out std_logic_vector(N-1 downto 0);
	     o_Cout	: out std_logic);
end fullAddNBitDF;

architecture dataflow of fullAddNBitDF is


--signals to be used to use while forming ripAdd adder
signal s_CARRY : std_logic_vector(N downto 0);



--begin port mapping
begin

s_CARRY(0) <= i_Cin;
G1: for i in 0 to N-1 generate
  
	o_Sum(i) <= i_A(i) XOR i_B(i) XOR s_CARRY(i);
	s_CARRY(i+1) <= (i_A(i) AND i_B(i)) OR ((i_A(i) XOR i_B(i)) AND s_CARRY(i));
		  
end generate;
o_Cout <= s_CARRY(N);
end dataflow;