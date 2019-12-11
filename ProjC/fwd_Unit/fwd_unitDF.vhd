library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity fwd_unit is
	port(	MEM_rd : in std_logic_vector (4 downto 0);
		WB_rd  : in std_logic_vector (4 downto 0);
		MEM_regWr : in std_logic;
		WB_regWr  : in std_logic;
		read1_in  : in std_logic_vector (4 downto 0);
		read2_in  : in std_logic_vector (4 downto 0);
		fwd_out1  : out std_logic_vector (1 downto 0);
		fwd_out2  : out std_logic_vector (1 downto 0));

end fwd_unit;

architecture dataflow of fwd_unit is

begin
if (MEM_regWr=1) AND (WB_regWr=0) AND (MEM_rd=read1_in) then fwd_out1="10";
else fwd_out1="00";
endif;
if (MEM_regWr=0) AND (WB_regWr=1) AND (WB_rd=read1_in) then fwd_out1="01";
else fwd_out1="00";
endif;
if (MEM_regWr=1) AND (WB_regWr=1) then
	 if (WB_rd=read1_in)
	
end dataflow;