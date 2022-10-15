library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity score_calculator is
	port ( clk    : in  std_logic;
		   rst    : in  std_logic;
	       point  : in  std_logic;
		   winner : out std_logic;
		   score  : out natural range 0 to 9
	);   
end score_calculator;

architecture Behavioral of score_calculator is
	
	-- Needed Constants
	------------------------------------------------
	constant max_goals : natural range 0 to 9 := 9;
	------------------------------------------------
	
	-- Needed signals
	------------------------------------------------
	signal goals : natural range 0 to 9 := 0;
	------------------------------------------------

begin
	
	score_calc : process (clk, point, goals)
		begin
			if (rising_edge(clk)) then 
				-- When the rst button is high, we reset
			    if (rst = '1') then
					goals <= 0;
					winner <= '0';
				-- When a player scored a point
				elsif (point = '1') then 
					-- If we have reached the max number of goals, we declare a winner
					if (goals = max_goals - 1) then
						winner <= '1';
					-- Else we increment the score value by 1
					else 
						goals <= goals + 1 ;
						winner <= '0';
					end if;
				end if;
			end if;
	end process;
	
	-- Updating the score value	
	score <= goals;

end Behavioral;

