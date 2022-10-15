library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pong is
	port (clk          : in std_logic;
		  rst      	   : in  std_logic;
		  player1_up   : in  std_logic;
		  player1_down : in  std_logic;
		  player2_up   : in  std_logic;
		  player2_down : in  std_logic;
		  Hsync        : out std_logic;
		  Vsync   	   : out std_logic;
		  leds		   : out std_logic_vector (1 downto 0);
		  outRed   	   : out std_logic_vector (2 downto 0);
		  outGreen 	   : out std_logic_vector (2 downto 0);
		  outBlue  	   : out std_logic_vector (1 downto 0)
	);
end pong;

architecture Behavioral of pong is
	
	-- Needed signals
	-------------------- Vga Driver --------------------
	signal video_on_sig : std_logic := '0';
	signal pixel_x_sig  : natural range 0 to 799 := 0;
	signal pixel_y_sig  : natural range 0 to 524 := 0;
	------------------- Moving Parts -------------------
	---------------------- Players ---------------------
	signal p1_winner    : std_logic := '0';
	signal p2_winner    : std_logic := '0';
	signal p1_goal      : std_logic := '0';
	signal p2_goal      : std_logic := '0';
	signal p1_up_pos	: natural range 0 to 479 := 0;
	signal p1_down_pos  : natural range 0 to 479 := 0;
	signal p2_up_pos	: natural range 0 to 479 := 0;
	signal p2_down_pos  : natural range 0 to 479 := 0;
	signal p1_points	: natural range 0 to   9 := 0;
	signal p2_points	: natural range 0 to   9 := 0;
	----------------------- Ball ---------------------- 
	signal ball_north	: natural range 0 to 479 := 0;	
	signal ball_south	: natural range 0 to 479 := 0;
	signal ball_east	: natural range 0 to 639 := 0;	
	signal ball_west	: natural range 0 to 639 := 0;
	--------------------- Fake tick -------------------
	signal fake_tick    : std_logic := '0';
	---------------------------------------------------
	
	-- Components
	------------------------------------------------------------
	-- component implementing the vga driver
	component vga_driver is 
		Port ( clk      : in  std_logic;
			   rst      : in  std_logic;
		       HSync    : out std_logic;
		       VSync    : out std_logic;
		       video_on : out std_logic;
		       pixel_x  : out natural range 0 to 799;
			   pixel_y  : out natural range 0 to 524
	   ); 
	end component;
	------------------------------------------------------------
	-- component implementing the image decoder
	component image_decoder is 
		port ( clk       : in  std_logic;
			   p1_winner : in  std_logic;
			   p2_winner : in  std_logic;
		       video_on  : in  std_logic;
			   x	     : in  natural range 0 to 799;
			   y 	     : in  natural range 0 to 524;
		       p1_plwrh  : in  natural range 0 to 479;
		       p1_prumnh : in  natural range 0 to 479;
		       p2_plwrh  : in  natural range 0 to 479;
		       p2_prumnh : in  natural range 0 to 479;
		       b_up	 	 : in  natural range 0 to 479;
		       b_down    : in  natural range 0 to 479;
		       b_left    : in  natural range 0 to 639;
		       b_right   : in  natural range 0 to 639;
		       p1_points : in  natural range 0 to   9;
		       p2_points : in  natural range 0 to   9;
		       outRed    : out std_logic_vector (2 downto 0);
		       outGreen  : out std_logic_vector (2 downto 0);
		       outBlue   : out std_logic_vector (1 downto 0)
		); 
	end component;
	------------------------------------------------------------
	-- component implementing the player and ball 
	component moving_parts is
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
	end component;
	------------------------------------------------------------
	component led_driver is
		port ( i_clk 	  : in  std_logic;
			   i_rst 	  : in  std_logic;
			   i_led_1_en : in  std_logic;
			   i_led_2_en : in  std_logic;
			   o_led_1    : out std_logic;
			   o_led_2    : out std_logic
		);
	end component;
	------------------------------------------------------------
	
begin
	-- Fake tick
	not_actual_tick : process(clk, fake_tick)
		begin
			if (rising_edge(clk)) then
				-- Checking whether the reset button is pressed, so we make fake tick zero.
				if (rst = '1') then 
					fake_tick   <= '0';
				-- Else we invert the value of fake_tick
				else
					fake_tick <= not fake_tick;										
				end if;	
			end if;
	end process; 
	----------------------------------------------	
	led : led_driver
		port map ( i_clk 	  => clk,
				   i_rst 	  => rst,
				   i_led_1_en => p1_goal,
				   i_led_2_en => p2_goal,
				   o_led_1    => leds(0),
				   o_led_2    => leds(1)
		);
	----------------------------------------------
	vga : vga_driver
		port map ( clk      => fake_tick,
				   rst      => rst,
		           HSync    => HSync,
		           VSync    => VSync,
		           video_on => video_on_sig,
		           pixel_x  => pixel_x_sig,
		           pixel_y  => pixel_y_sig
	   ); 
	----------------------------------------------	
	img : image_decoder
		port map ( clk       => fake_tick,
				   x   		 => pixel_x_sig,
			       y   		 => pixel_y_sig,
				   p1_plwrh  => p1_up_pos,
				   p1_prumnh => p1_down_pos,
				   p2_plwrh  => p2_up_pos,
				   p2_prumnh => p2_down_pos,
				   p1_points => p1_points,
				   p2_points => p2_points,
				   b_up	     => ball_north,
				   b_left    => ball_west,
				   b_down    => ball_south,
				   b_right   => ball_east,
				   p1_winner => p1_winner,
				   p2_winner => p2_winner,
			       video_on  => video_on_sig,
			       outRed    => outRed,
			       outGreen  => outGreen,
			       outBlue   => outBlue
		); 
	----------------------------------------------
	moving_components : moving_parts 
		Port map( clk          => clk,
				  rst          => rst,
				  player1_up   => player1_up,
			      player1_down => player1_down,
			      player2_up   => player2_up,
			      player2_down => player2_down,
			      ball_north   => ball_north,
				  ball_east	   => ball_east,
				  ball_south   => ball_south,
				  ball_west	   => ball_west,
				  p1_plwrh 	   => p1_up_pos,
				  p1_prumnh    => p1_down_pos,
				  p2_plwrh 	   => p2_up_pos,
				  p2_prumnh    => p2_down_pos,
				  p1_goal	   => p1_goal,
				  p2_goal	   => p2_goal,
				  p1_score     => p1_points,
			  	  p2_score     => p2_points,
				  p1_winner    => p1_winner,
				  p2_winner    => p2_winner
		);  

end Behavioral; 
