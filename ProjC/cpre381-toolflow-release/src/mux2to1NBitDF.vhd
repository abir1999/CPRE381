library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1NBitDF is
	generic(N : integer := 32);
	port(i_Bit0	: in std_logic_vector(N-1 downto 0);
	     i_Bit1	: in std_logic_vector(N-1 downto 0);
	     i_Sel	: in std_logic;
	     o_out	: out std_logic_vector(N-1 downto 0));
end mux2to1NBitDF;

architecture dataflow of mux2to1NBitDF is

begin
G1: for i in 0 to N-1 generate
	o_out(i) <= ((NOT i_Sel)AND i_Bit0(i))OR(i_Sel AND i_Bit1(i));
end generate;
end dataflow;