library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity fwd_unit is
	port(	MEM_rd : in std_logic_vector (4 downto 0);
		WB_rd  : in std_logic_vector (4 downto 0);
		MEM_regWr : in std_logic;
		WB_regWr  : in std_logic;
		in_EX_rs  : in std_logic_vector (4 downto 0);	--(EX.rs)
		in_EX_rt  : in std_logic_vector (4 downto 0);   --(EX.rt)
		fwd_out1  : out std_logic_vector (1 downto 0);	--1stmux (ALU in A)
		fwd_out2  : out std_logic_vector (1 downto 0));	--2ndmux (ALU in A)

end fwd_unit;

architecture dataflow of fwd_unit is

begin
	process(MEM_rd, WB_rd, MEM_regWr, WB_regWr, in_EX_rs, in_EX_rt)
	begin
		if    (MEM_regWr='1') and (WB_regWr='0') and (MEM_rd=in_EX_rs) then fwd_out1<="10";
		elsif (MEM_regWr='0') and (WB_regWr='1') and (WB_rd=in_EX_rs) then fwd_out1<="01";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (MEM_rd=in_EX_rs) and (WB_rd/=in_EX_rs)  then fwd_out1<="10";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (MEM_rd/=in_EX_rs) and (WB_rd=in_EX_rs)  then fwd_out1<="01";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (MEM_rd=in_EX_rs) and (WB_rd=in_EX_rs)  then fwd_out1<="10";
		else fwd_out1<="00";
		end if;

		if (MEM_regWr='1') and (WB_regWr='0') and (MEM_rd=in_EX_rt) then fwd_out2<="10";
		elsif (MEM_regWr='0') and (WB_regWr='1') and (WB_rd=in_EX_rt) then fwd_out2<="01";	
		elsif (MEM_regWr='1') and (WB_regWr='1') and (MEM_rd=in_EX_rt) and (WB_rd/=in_EX_rt)  then fwd_out2<="10";	
		elsif (MEM_regWr='1') and (WB_regWr='1') and (MEM_rd/=in_EX_rt) and (WB_rd=in_EX_rt)  then fwd_out2<="01";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (MEM_rd=in_EX_rt) and (WB_rd=in_EX_rt)  then fwd_out2<="10";
		else fwd_out2<="00";
		end if;

	end process;
	
end dataflow;