library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity counter is
	-- max_val indicates the max value our counter will until it resets back to zero.
	generic( max_Val : natural range 0 to 666 := 666);
	port (clk 		: in  std_logic;
		  rst 		: in  std_logic;
		  enable 	: in  std_logic;
		  count_val : out natural range 0 to max_Val
	);
end counter;

architecture Behavioral of counter is
	
	-- Needed signals
	---------------------------------------------------------
	signal counter_sig : natural range 0 to max_Val := 0;
	---------------------------------------------------------

begin
	interrupt_proc: process (clk, rst, counter_sig)
		begin
			if (rising_edge(clk)) then
				-- Checking if we are reseting, so we have to make our counters zero.
				if (rst = '1') then 
					counter_sig <= 0;
				else  
					if (enable = '1') then 
					-- If the value of counter_sig is smaller than the max_val value (specific to fpga clock),
					-- 	we increment the counter_sig by 1.
						if (counter_sig < max_Val) then
							counter_sig <= counter_sig + 1;
						-- Else we have reached the desired value for counter_sig, so we reset the counter, 
						--  and raise interrupt.
						else
							counter_sig <= 0;
						end if;
					end if;
				end if;
			end if;
		end process interrupt_proc;	
	
	-- Returning the value which we have counted to
	count_val <= counter_sig;

end Behavioral;
