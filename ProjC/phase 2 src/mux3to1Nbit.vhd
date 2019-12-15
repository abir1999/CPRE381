library IEEE;
use IEEE.std_logic_1164.all;

entity mux3to1Nbit is
	generic(N : integer := 32);
	port(i_In0	: in std_logic_vector(N-1 downto 0);
	     i_In1	: in std_logic_vector(N-1 downto 0);
		 i_In2  : in std_logic_vector(N-1 downto 0);
	     i_Sel	: in std_logic_vector (1 downto 0);
	     o_out	: out std_logic_vector(N-1 downto 0));
end mux3to1NBit;

architecture behavior of mux3to1NBit is

begin

o_out <= i_In0 when (i_Sel = "00") else
	 i_In1 when (i_Sel = "01") else
	 i_In2 when (i_Sel = "10");
end behavior;