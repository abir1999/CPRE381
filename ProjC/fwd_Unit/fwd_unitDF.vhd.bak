library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity fwd_unit is
	port(	
		in_WBregAddr  : in std_logic_vector (4 downto 0);
		MEM_regWr : in std_logic;
		WB_regWr  : in std_logic;
		in_MEMregAddr : in std_logic_vector (4 downto 0);
		in_EX_rs  : in std_logic_vector (4 downto 0);	--(EX.rs)
		in_EX_rt  : in std_logic_vector (4 downto 0);   --(EX.rt)
		in_ID_rs  : in std_logic_vector(4 downto 0);
		in_ID_rt  : in std_logic_vector(4 downto 0);
		fwd_outA  : out std_logic_vector (1 downto 0);	--1stmux (ALU in A)
		fwd_outB  : out std_logic_vector (1 downto 0);	--2ndmux (ALU in B)
		fwd_branchA : out std_logic_vector(1 downto 0);
		fwd_branchB : out std_logic_vector (31 downto 0));
end fwd_unit;

architecture dataflow of fwd_unit is

begin
	process(in_MEMregAddr, in_WBregAddr, MEM_regWr, WB_regWr, in_EX_rs, in_EX_rt)
	begin
		if    (MEM_regWr='1') and (WB_regWr='0') and (in_MEMregAddr=in_EX_rs) then fwd_outA<="10";
		elsif (MEM_regWr='0') and (WB_regWr='1') and (in_WBregAddr=in_EX_rs) then fwd_outA<="01";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (in_MEMregAddr=in_EX_rs) and (in_WBregAddr/=in_EX_rs)  then fwd_outA<="10";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (in_MEMregAddr/=in_EX_rs) and (in_WBregAddr=in_EX_rs)  then fwd_outA<="01";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (in_MEMregAddr=in_EX_rs) and (in_WBregAddr=in_EX_rs)  then fwd_outA<="10";
		else fwd_outA<="00";
		end if;

		if (MEM_regWr='1') and (WB_regWr='0') and (in_MEMregAddr=in_EX_rt) then fwd_outB<="10";
		elsif (MEM_regWr='0') and (WB_regWr='1') and (in_WBregAddr=in_EX_rt) then fwd_outB<="01";	
		elsif (MEM_regWr='1') and (WB_regWr='1') and (in_MEMregAddr=in_EX_rt) and (in_WBregAddr/=in_EX_rt)  then fwd_outB<="10";	
		elsif (MEM_regWr='1') and (WB_regWr='1') and (in_MEMregAddr/=in_EX_rt) and (in_WBregAddr=in_EX_rt)  then fwd_outB<="01";
		elsif (MEM_regWr='1') and (WB_regWr='1') and (in_MEMregAddr=in_EX_rt) and (in_WBregAddr=in_EX_rt)  then fwd_outB<="10";
		else fwd_outB<="00";
		end if;
		
		if (in_EX_rs="00000") then fwd_outA<="00";
		if (in_EX_rt="00000") then fwd_outB<="00";
		
		if(in_ID_rs = in_WBregAddr) then fwd_branchA <= '1';	
		elsif (in_ID_rt = in_WBregAddr) then fwd_branchB <= '1';
		else 
		fwd_branchA <='0';
		fwd_branchB <= '0';
		end if;
	end process;
	
end dataflow;