-------------------------------------------------------------------------
-- Joseph Zambreno
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- dff.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an edge-triggered
-- flip-flop with parallel access and reset.
--
--
-- NOTES:
-- 8/19/16 by JAZ::Design created.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity dff_pipe is

  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_Data         : in std_logic;     -- Data value input
       o_Data          : out std_logic);   -- Data value output

end dff_pipe;

architecture mixed of dff_pipe is
  signal s_D    : std_logic;    -- Multiplexed input to the FF
  signal s_Q    : std_logic;    -- Output of the FF

begin

  -- The output of the FF is fixed to s_Q
  o_Data <= s_Q;
  
  -- Create a multiplexed input to the FF based on i_WE
  with i_WE select
    s_D <= i_Data when '1',
           s_Q when others;
  
  -- This process handles the asyncrhonous reset and
  -- synchronous write. We want to be able to reset 
  -- our processor's registers so that we minimize
  -- glitchy behavior on startup.
  process (i_CLK, i_RST)
  begin
  if (rising_edge(i_CLK)) then
    if (i_RST = '1') then
      s_Q <= '0'; -- Use "(others => '0')" for N-bit values
    else
      s_Q <= s_D;
    end if;
  end if;
  end process;
  
end mixed;
