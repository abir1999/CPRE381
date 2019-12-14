library IEEE;
use IEEE.std_logic_1164.all;
--Jump and Branch address is calculated within ID stage, this requirement needs to be changed for Proj part B implementation.
entity hzd_detect is
	port(	in_EXregAddr : in std_logic_vector (4 downto 0);
		EX_memRead : in std_logic;		--to detect if the EX stage is a load instruction
		in_ID_rs : in std_logic_vector (4 downto 0);
		in_ID_rt : in std_logic_vector (4 downto 0);
		in_PCsrc : in std_logic;
		in_Jump	 : in std_logic;
		IDEX_flush : out std_logic;
		IDEX_stall : out std_logic;
		IFID_flush : out std_logic;
		IFID_stall : out std_logic;
		PC_stall   : out std_logic);
		

end hzd_detect;

architecture dataflow of hzd_detect is

begin
	process(in_EXregAddr, EX_memRead, in_ID_rs, in_ID_rt, in_PCsrc, in_Jump)
	begin
	if (EX_memRead='1') and ((in_EXregAddr=in_ID_rs) or (in_EXregAddr=in_ID_rt)) then		
		IFID_flush <='0';
		IFID_stall <='1';
		IDEX_flush <='1';
		IDEX_stall <='0';
		PC_stall   <='1';
				
	elsif (in_PCsrc ='1') or (in_Jump ='1') then
		IFID_flush <='1';
		IFID_stall <='0';
		IDEX_flush <='0';
		IDEX_stall <='0';
		PC_stall   <='0';
	else 
		IFID_flush <='0';
		IFID_stall <='0';
		IDEX_flush <='0';
		IDEX_stall <='0';
		PC_stall   <='0';
	end if;

	end process;
	
end dataflow;