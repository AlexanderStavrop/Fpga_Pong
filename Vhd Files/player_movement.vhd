library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity player_movement is
	port( clk         : in  std_logic;
		  rst 		  : in  std_logic;
		  player_up   : in  std_logic;
		  player_down : in  std_logic;
		  plwrh		  : out natural range 0 to 479;
		  prumnh	  : out natural range 0 to 479
	);
end player_movement;

architecture Behavioral of player_movement is

	-- Needed constants
	---------------------------------------------------------------
	constant upper_limit    : natural range 0 to      4 :=      4; 
	constant lower_limit    : natural range 0 to    474 :=    474;
	---------------------------------------------------------------
	constant start_pos_up   : natural range 0 to    213 :=    213; 
	constant start_pos_down : natural range 0 to    267 :=    267; 
	---------------------------------------------------------------
	constant timer_max_val  : natural range 0 to 350000 := 350000; 
	---------------------------------------------------------------

	-- Needed signals
	--------------------------------------------------------------- 
	signal up_pos   : natural range 0 to 479 := start_pos_up;
	signal down_pos : natural range 0 to 479 := start_pos_down;
	---------------------------------------------------------------
	signal timer    : natural range 0 to timer_max_val := 0;
	---------------------------------------------------------------

begin
	
	player_movement: process(clk, rst, player_up, player_down, timer)
		begin
			if (rising_edge(clk)) then
				-- If the rst is high, we initialize the players
				if (rst = '1') then 
					up_pos	 <=  start_pos_up;
					down_pos <=  start_pos_down;
				else
					-- Checking if enough cycles have passed
					if (timer = timer_max_val) then
						timer <= 0;
						-- when up and only up is pressed, player goes up 
						if (player_up /= player_down) then
							-- THIS CREATES THE WARNINGS
							-- Player has reached its upper limit, so we can only move down
							if (up_pos = upper_limit) then 
								up_pos    <= up_pos   + to_integer(unsigned'("" & player_down));
								down_pos  <= down_pos + to_integer(unsigned'("" & player_down));
							-- Player has reached its lower limit, so we can only move up
							elsif (down_pos = lower_limit) then
								up_pos    <= up_pos   - to_integer(unsigned'("" & player_up));
								down_pos  <= down_pos - to_integer(unsigned'("" & player_up));
							-- Player hasn't reached any limit, so we can move freely
							else
								up_pos    <= up_pos   - to_integer(unsigned'("" & player_up)) + to_integer(unsigned'("" & player_down));
								down_pos  <= down_pos - to_integer(unsigned'("" & player_up)) + to_integer(unsigned'("" & player_down));
							end if;
						end if;
					-- Else incrementing the timer value by 1
					else 
						timer <= timer + 1;
					end if;
				end if;
			end if;
	end process; 
			
	-- Updating the output variables		
	plwrh  <= up_pos;
	prumnh <= down_pos;

end Behavioral;

