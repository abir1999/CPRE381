library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity srl32 is
	generic(N : integer := 32);
	port(input_A : in std_logic_vector(N-1 downto 0);
	     shiftBy_Sel : in std_logic_vector(4 downto 0);
	     out_left : out std_logic_vector(N-1 downto 0));

end srl32;

architecture structure of srl32 is

--listing all components
component mux2to1
	port(i_Bit0	: in std_logic;
	     i_Bit1	: in std_logic;
	     i_Sel	: in std_logic;
	     o_out	: out std_logic);
end component;

signal s_BUFFER0: std_logic_vector(N-1 downto 0);
signal s_BUFFER1: std_logic_vector(N-1 downto 0);
signal s_BUFFER2: std_logic_vector(N-1 downto 0);
signal s_BUFFER3: std_logic_vector(N-1 downto 0);



begin

--- Responsible for shifting by 1 bit--------------
	muxROW0open: mux2to1
	port map( i_Bit0 => input_A(N-1),
	     	  i_Bit1 => '0',
		  i_Sel  => shiftBy_Sel(0),
		  o_out  => s_BUFFER0(N-1));
	G1: for i in 0 to (N-2) generate
	muxROW0: mux2to1
	port map( i_Bit0 => input_A(i),
	     	  i_Bit1 => input_A(i+1),
		  i_Sel  => shiftBy_Sel(0),
		  o_out  => s_BUFFER0(i));
	end generate;
----------------------------------------------------
--- Responsible for shifting by 2 bits--------------
	G2: for i in 30 to N-1 generate
	muxROW1open: mux2to1
	port map( i_Bit0 => s_BUFFER0(i),
	     	  i_Bit1 => '0',
		  i_Sel  => shiftBy_Sel(1),
		  o_out  => s_BUFFER1(i));
	end generate;
	G3: for i in 0 to (N-3) generate
	muxROW1: mux2to1
	port map( i_Bit0 => s_BUFFER0(i),
	     	  i_Bit1 => s_BUFFER0(i+2),
		  i_Sel  => shiftBy_Sel(1),
		  o_out  => s_BUFFER1(i));
	end generate;
----------------------------------------------------
--- Responsible for shifting by 4 bits--------------
	G4: for i in 28 to N-1 generate
	muxROW2open: mux2to1
	port map( i_Bit0 => s_BUFFER1(i),
	     	  i_Bit1 => '0',
		  i_Sel  => shiftBy_Sel(2),
		  o_out  => s_BUFFER2(i));
	end generate;
	G5: for i in 0 to (N-5) generate
	muxROW2: mux2to1
	port map( i_Bit0 => s_BUFFER1(i),
	     	  i_Bit1 => s_BUFFER1(i+4),
		  i_Sel  => shiftBy_Sel(2),
		  o_out  => s_BUFFER2(i));
	end generate;
----------------------------------------------------
--- Responsible for shifting by 8 bits--------------
	G6: for i in 24 to N-1 generate
	muxROW3open: mux2to1
	port map( i_Bit0 => s_BUFFER2(i),
	     	  i_Bit1 => '0',
		  i_Sel  => shiftBy_Sel(3),
		  o_out  => s_BUFFER3(i));
	end generate;
	G7: for i in 0 to (N-9) generate
	muxROW3: mux2to1
	port map( i_Bit0 => s_BUFFER2(i),
	     	  i_Bit1 => s_BUFFER2(i+8),
		  i_Sel  => shiftBy_Sel(3),
		  o_out  => s_BUFFER3(i));
	end generate;
----------------------------------------------------	
--- Responsible for shifting by 16 bits--------------
	G8: for i in 16 to N-1 generate
	muxROW4open: mux2to1
	port map( i_Bit0 => s_BUFFER3(i),
	     	  i_Bit1 => '0',
		  i_Sel  => shiftBy_Sel(4),
		  o_out  => out_left(i));
	end generate;
	G9: for i in 0 to (N-17) generate
	muxROW4: mux2to1
	port map( i_Bit0 => s_BUFFER3(i),
	     	  i_Bit1 => s_BUFFER3(i+16),
		  i_Sel  => shiftBy_Sel(4),
		  o_out  => out_left(i));
	end generate;
----------------------------------------------------	
 
end structure;