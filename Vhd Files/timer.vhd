library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity timer is
	-- max_val indicates how many cycle equal to 1 second.
	-- 1 second is represented as follows for 50 clock mhz
	-- The result is equal to 49999998
	generic(max_val : natural range 0 to 49999998 := 49999998);
	port (clk 		: in  std_logic;
		  rst 		: in  std_logic;
		  enable	: in  std_logic;
		  interrupt : out std_logic
	);
end timer;

architecture Behavioral of timer is
	-- Needed signals
	--------------------------------------------------------
	signal clock_counter : natural range 0 to max_val := 0;
	signal intrpt_sig    : std_logic := '0';
	--------------------------------------------------------

begin

	interrupt_proc: process (clk, rst, clock_counter, intrpt_sig)
	begin
		if (rising_edge(clk)) then
		  if(enable = '1') then
			-- Checking if we are reseting or sending an interrupt, so we have to make our counters zero.
			if (rst = '1' or intrpt_sig = '1') then
				interrupt     <= '0';
				intrpt_sig    <= '0';
				clock_counter <=  0;
			end if;

			-- If the value of clock_counter is smaller than the max_val value (specific to fpga clock),
			-- 	we increment the secs_counter by 1.
			if (clock_counter < max_val and rst = '0') then
				clock_counter <= clock_counter + 1;
			-- Else we have reached the desired value for clock_counter, so we reset the counter,
			--  and raise interrupt.
			else
				interrupt     <= '1';
				intrpt_sig    <= '1';
				clock_counter <=  0;
			end if;
		  end if;
		end if;
	end process;

end Behavioral;
