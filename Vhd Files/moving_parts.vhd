library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Moving_Parts is
	Port (clk          : in  std_logic;
			  rst          : in  std_logic;
			  player1_up   : in  std_logic;
			  player1_down : in  std_logic;
			  player2_up   : in  std_logic;
			  player2_down : in  std_logic;
			  p1_goal	   : out std_logic;
			  p2_goal	   : out std_logic;
			  p1_winner    : out std_logic;
			  p2_winner    : out std_logic;
			  ball_north   : out natural range 0 to 479;
			  ball_south   : out natural range 0 to 479;
			  ball_east	   : out natural range 0 to 639;
			  ball_west	   : out natural range 0 to 639;
			  p1_plwrh     : out natural range 0 to 479;
			  p1_prumnh    : out natural range 0 to 479;
			  p2_plwrh     : out natural range 0 to 479;
			  p2_prumnh    : out natural range 0 to 479;
			  p1_score     : out natural range 0 to   9;
		      p2_score     : out natural range 0 to   9
	); 
end Moving_Parts;

architecture Behavioral of moving_parts is

	-- Needed signals
	-------------------------------------------------
	signal p1_up      : natural range 0 to 479 := 0;
	signal p2_up      : natural range 0 to 479 := 0;
	signal p1_down    : natural range 0 to 479 := 0;
	signal p2_down    : natural range 0 to 479 := 0;
	signal p1_point   : std_logic := '0';
	signal p2_point   : std_logic := '0';
	signal p1_wins	  : std_logic := '0';
	signal p2_wins	  : std_logic := '0';
	signal stop_game  : std_logic := '0';
	-------------------------------------------------
	
	-- Components
	-------------------------------------------------------
	-- component implementing the player movements
	component player_movement is
		port( clk         : in  std_logic;
			  rst 		  : in  std_logic;
			  player_up   : in  std_logic;
			  player_down : in  std_logic;
			  plwrh		  : out natural range 0 to 479;
			  prumnh	  : out natural range 0 to 479
		);	
	end component;
	-------------------------------------------------------
	-- component implementing the ball movement
	component ball_movement is
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
	end component;
	-------------------------------------------------------
	-- component implementing the score calculator
	component score_calculator is
		port ( clk    : in  std_logic;
			   rst    : in  std_logic;
	           point  : in  std_logic;
			   winner : out std_logic;
		       score  : out natural range 0 to 9
		);
	end component;
	-------------------------------------------------------
	
begin
	-----------------------------------------------------
	player_1 : player_movement
		port map ( clk         => clk,
			       rst 		   => rst,
				   player_up   => player1_up, 
				   player_down => player1_down,
				   plwrh	   => p1_up,
				   prumnh	   => p1_down
		);
	p1_plwrh  <= p1_up;
	p1_prumnh <= p1_down;
	-----------------------------------------------------	
	player_2 : player_movement
		port map ( clk         => clk,
			       rst 		   => rst,
				   player_up   => player2_up, 
				   player_down => player2_down,
				   plwrh	   => p2_up,
				   prumnh	   => p2_down
		);	
	p2_plwrh  <= p2_up;
	p2_prumnh <= p2_down;
	-----------------------------------------------------
	ball : ball_movement
		port map ( clk         => clk,
				   rst         => rst,
				   stop		   => stop_game,
				   p1_up       => player1_up,
				   p1_down     => player1_down,
				   p2_up	   => player2_up,
				   p2_down     => player2_down,
				   p1_up_pos   => p1_up,
				   p2_up_pos   => p2_up,
				   p1_down_pos => p1_down,
				   p2_down_pos => p2_down,
				   p1_point    => p1_point,
				   p2_point    => p2_point,
				   ball_up	   => ball_north,
				   ball_down   => ball_south,
				   ball_left   => ball_west,
				   ball_right  => ball_east
		);		
	-----------------------------------------------------
	p1_goals : score_calculator
		port map ( clk    => clk,
				   rst    => rst,
				   point  => p1_point,
		   		   winner => p1_wins,
				   score  => p1_score
		);
	-----------------------------------------------------	
	p2_goals : score_calculator
		port map ( clk    => clk,
				   rst    => rst,
				   point  => p2_point,
				   winner => p2_wins,
				   score  => p2_score
		);
	-----------------------------------------------------
	
	-- Updating the outputs
	---------------------------------
	stop_game <= p1_wins or p2_wins;
	p1_goal   <= p1_point;
	p2_goal   <= p2_point;
	p1_winner <= p1_wins;
	p2_winner <= p2_wins;
	---------------------------------
	
end Behavioral;
