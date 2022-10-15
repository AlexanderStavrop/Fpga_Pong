library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ball_movement is
	port ( clk         : in  std_logic;
		   rst         : in  std_logic;
		   stop 	   : in  std_logic;
		   p1_up       : in std_logic;
		   p1_down     : in std_logic;
		   p2_up	   : in std_logic;
		   p2_down     : in std_logic;
		   p1_up_pos   : in  natural range 0 to 479;
		   p2_up_pos   : in  natural range 0 to 479;
		   p1_down_pos : in  natural range 0 to 479;
		   p2_down_pos : in  natural range 0 to 479;
		   p1_point    : out std_logic;
		   p2_point    : out std_logic;
		   ball_up	   : out natural range 0 to 479;
		   ball_down   : out natural range 0 to 479;
		   ball_left   : out natural range 0 to 639;
		   ball_right  : out natural range 0 to 639
	);	   
		   
end ball_movement;

architecture Behavioral of ball_movement is
	
	-- Constants
	----------------------------------------------------------------
	constant ball_speed      : natural range 0 to 300000 := 300000;
	----------------------------------------------------------------
	constant upper_limit     : natural range 0 to      4 :=      4; 
	constant lower_limit     : natural range 0 to 	 474 :=    474; 
	constant right_limit 	 : natural range 0 to 	 630 :=    630; 
	constant left_limit 	 : natural range 0 to      2 :=      2; 
	----------------------------------------------------------------
	constant start_pos_up    : natural range 0 to 	 234 :=    234; 
	constant start_pos_down  : natural range 0 to 	 243 :=    243; 
	constant start_pos_left  : natural range 0 to 	 315 :=    315; 
	constant start_pos_right : natural range 0 to 	 323 :=    323; 
	constant offset_x 		 : natural range 0 to  	  60 :=     60;
	----------------------------------------------------------------
	constant ball_length 	 : natural range 0 to      9 :=      9;
	constant ball_field      : natural range 0 to    455 :=    455;
	----------------------------------------------------------------

	-- Needed signals
	--------------------------------------------------------------------------------------------
	signal point_p1    : std_logic := '0';
	signal point_p2    : std_logic := '0';
	--------------------------------------------------------------------------------------------
	signal b_up	       : natural range 0 to 479 := start_pos_up; 
	signal b_down      : natural range 0 to 479 := start_pos_down;
	signal b_left      : natural range 0 to 639 := start_pos_left;
	signal b_right 	   : natural range 0 to 639 := start_pos_right;
	signal ball_offset : natural range 0 to 455 := 455;
	--------------------------------------------------------------------------------------------
	signal x_movement  : std_logic := '1'; -- 0 => Moving to the left, 1 => Moving to the right 
	signal y_movement  : std_logic := '0'; -- 0 => Moving up,          1 => Moving down 
	--------------------------------------------------------------------------------------------
	signal timer	   : natural range 0 to ball_speed := 0;
	signal abbs  	   : std_logic := '0';
	signal game_on 	   : std_logic := '0';
	--------------------------------------------------------------------------------------------

	-- Components
	----------------------------------------------------------------
	component counter is
		generic ( max_Val : natural range 0 to ball_field);
		port ( clk 		 : in  std_logic;
			   rst 		 : in  std_logic;
			   enable 	 : in  std_logic;
			   count_val : out natural range 0 to max_Val
		);
	end component;
	----------------------------------------------------------------
begin
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	ball_spawn : counter
		generic map( max_Val => ball_field)
		port map ( clk 		 => clk,
				   rst 		 => rst,
				   enable 	 => '1',
				   count_val => ball_offset
		);
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	ball_collision: process(clk, rst, stop, ball_offset, p1_up, p2_up, p1_down, p2_down, p1_up_pos, p1_down_pos, p2_up_pos, p2_down_pos, b_left, b_right, b_up, b_down, x_movement, y_movement, timer, point_p1 , point_p2)
		begin
			if (rising_edge(clk)) then
				-- If reset is pressed, we reset the players and the ball
				if(rst = '1' or stop = '1') then
					game_on  <= '0';
					point_p1 <= '0';
					point_p2 <= '0';
					b_up     <= start_pos_up;
					b_down   <= start_pos_down;
					b_left   <= start_pos_left;
					b_right  <= start_pos_right;
				-- If the game hasn't started yet, we check if on of the buttons is pressed to start the game
				elsif (game_on = '0' and stop = '0') then
					if (p1_up = '1' or p2_up = '1' or p1_down = '1' or p2_down = '1') then
						game_on <= '1';
					else
						game_on <= '0';
					end if;
				else
					if(point_p2 = '1' or point_p1 = '1') then 
						point_p1 <= '0';
						point_p2 <= '0';
						-- Spawning the ball
						b_up   <= ball_offset + upper_limit; 
						b_down <= ball_offset + upper_limit + ball_length; 
						-- If player 1 scored a point
						if (point_p1 = '1') then
							-- We start moving to the left
							x_movement <= '1';
							-- Spawning at left side 
							b_left     <= start_pos_left;
							b_right    <= start_pos_right;
						-- If player 2 scored a point	
						elsif (point_p2 = '1') then
							-- We start moving to the right
							x_movement <= '0';
							-- Spawning at right side 
							b_left     <= start_pos_left;
							b_right    <= start_pos_right;
						end if;
					else
						-- Checking if enough cycles have passed
						if (timer = ball_speed) then
							timer <= 0;
							-- Checking if the ball hits the upper or the lower limit, it starts going the opposite direction
							if ((b_up <= upper_limit or b_down >= lower_limit) and abbs = '0') then
								y_movement <= not y_movement;
								abbs <= '1';
							-- Checking if the ball touched a player, so we start moving the ball to the other direction.
							elsif (((b_left  = 12  and ((b_up < p1_down_pos and b_up > p1_up_pos) or (b_down > p1_up_pos and b_down < p1_down_pos)))  or 
									(b_right = 629 and ((b_up < p2_down_pos and b_up > p2_up_pos) or (b_down > p2_up_pos and b_down < p2_down_pos)))) and 
									abbs = '0') then						
								abbs <= '1';
								x_movement <= not x_movement;
							elsif (b_left = left_limit) then
								point_p2 <= '1';
							elsif (b_right = right_limit) then
								point_p1 <= '1';
							else 
								b_up    <= b_up    + to_integer(unsigned'(y_movement & "0")) - 1;
								b_down  <= b_down  + to_integer(unsigned'(y_movement & "0")) - 1;		
								b_left  <= b_left  + to_integer(unsigned'(x_movement & "0")) - 1;
								b_right <= b_right + to_integer(unsigned'(x_movement & "0")) - 1;
								abbs <= '0';
							end if;
						else
							timer <= timer + 1;
						end if;
					end if;
				end if;
			end if;
	end process; 

	-- Updating the outputs
	p1_point  <= point_p1;
	p2_point  <= point_p2;

	ball_up	   <= b_up;
	ball_down  <= b_down;
	ball_left  <= b_left;
	ball_right <= b_right;

end Behavioral;
