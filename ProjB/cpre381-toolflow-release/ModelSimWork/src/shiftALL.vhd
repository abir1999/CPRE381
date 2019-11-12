library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftALL is
	generic(N : integer := 32);
	port(input_A : in std_logic_vector(N-1 downto 0);
	     shiftBy_Sel : in std_logic_vector(4 downto 0);
	     left_right_Sel: in std_logic;
	     log_arith_Sel: in std_logic;
	     out_Shift : out std_logic_vector(N-1 downto 0));

end shiftALL;

architecture structure of shiftALL is

--listing all components
component mux2to1
	port(i_Bit0	: in std_logic;
	     i_Bit1	: in std_logic;
	     i_Sel	: in std_logic;
	     o_out	: out std_logic);
end component;

component mux2to1NBitDF
	port(i_Bit0	: in std_logic_vector(N-1 downto 0);
	     i_Bit1	: in std_logic_vector(N-1 downto 0);
	     i_Sel	: in std_logic;
	     o_out	: out std_logic_vector(N-1 downto 0));
end component;

component flipper
	port(in_A	: in std_logic_vector(N-1 downto 0);
	     flip_A	: out std_logic_vector(N-1 downto 0));
end component;

signal s_BUFFER0: std_logic_vector(N-1 downto 0);
signal s_BUFFER1: std_logic_vector(N-1 downto 0);
signal s_BUFFER2: std_logic_vector(N-1 downto 0);
signal s_BUFFER3: std_logic_vector(N-1 downto 0);
signal s_out_left_right: std_logic_vector(N-1 downto 0);
signal s_InputUSED: std_logic_vector(N-1 downto 0);
signal s_flippedINPUT: std_logic_vector(N-1 downto 0);
signal s_flippedOUTPUT: std_logic_vector(N-1 downto 0);
signal s_logORarith: std_logic;
--signal s_leftORright: std_logic;


begin
----Select left shift(muxLEFT_RIGHT code: 0) and right shift(muxLEFT_RIGHT code: 1)
	
	flipINPUT: flipper
	port map( in_A => input_A,
		  flip_A => s_flippedINPUT);
	muxLEFT_RIGHT: mux2to1NBitDF
	port map( i_Bit0 => s_flippedINPUT,
	     	  i_Bit1 => input_A,
		  i_Sel  => left_right_Sel,
		  o_out  => s_InputUSED);
----Choose between logical (muxCHOOSE code: 0) and arithmetic (muxCHOOSE code: 1)
	muxCHOOSE: mux2to1
	port map( i_Bit0 => '0',
	     	  i_Bit1 => input_A(N-1),
		  i_Sel  => log_arith_Sel,
		  o_out  => s_logORarith);
-----------------------------------------------------------------------
--- Responsible for shifting by 1 bit--------------
	muxROW0open: mux2to1
	port map( i_Bit0 => s_InputUSED(N-1),
	     	  i_Bit1 => s_logORarith,
		  i_Sel  => shiftBy_Sel(0),
		  o_out  => s_BUFFER0(N-1));
	G1: for i in 0 to (N-2) generate
	muxROW0: mux2to1
	port map( i_Bit0 => s_InputUSED(i),
	     	  i_Bit1 => s_InputUSED(i+1),
		  i_Sel  => shiftBy_Sel(0),
		  o_out  => s_BUFFER0(i));
	end generate;
----------------------------------------------------
--- Responsible for shifting by 2 bits--------------
	G2: for i in 30 to N-1 generate
	muxROW1open: mux2to1
	port map( i_Bit0 => s_BUFFER0(i),
	     	  i_Bit1 => s_logORarith,
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
	     	  i_Bit1 => s_logORarith,
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
	     	  i_Bit1 => s_logORarith,
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
	     	  i_Bit1 => s_logORarith,
		  i_Sel  => shiftBy_Sel(4),
		  o_out  => s_out_left_right(i));
	end generate;
	G9: for i in 0 to (N-17) generate
	muxROW4: mux2to1
	port map( i_Bit0 => s_BUFFER3(i),
	     	  i_Bit1 => s_BUFFER3(i+16),
		  i_Sel  => shiftBy_Sel(4),
		  o_out  => s_out_left_right(i));
	end generate;
----------------------------------------------------	
------Flip if left shifter is chosen----------------
	flipOUTPUT: flipper
	port map( in_A => s_out_left_right,
		  flip_A => s_flippedOUTPUT);

	muxOUTPUT: mux2to1NBitDF
	port map( i_Bit0 => s_flippedOUTPUT,
	     	  i_Bit1 => s_out_left_right,
		  i_Sel  => left_right_Sel,
		  o_out  => out_Shift);
----------------------------------------------------
end structure;