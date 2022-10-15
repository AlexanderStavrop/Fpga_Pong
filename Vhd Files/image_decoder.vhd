library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;               

entity Image_Decoder is
	generic ( H_length : positive := 639;
			  V_length : positive := 479
	);
	port ( clk       : in  std_logic;
		   p1_winner : in  std_logic;
		   p2_winner : in  std_logic;
		   video_on  : in  std_logic;
		   x   		 : in  natural range 0 to 799;
		   y   		 : in  natural range 0 to 524;
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
end Image_decoder;

architecture Behavioral of Image_Decoder is

	-- Constant
	------------------------------------------------------------
	constant top_border        : natural range 0 to   4 :=   4;
	constant bottom_border     : natural range 0 to 474 := 474;
	constant middle_div_start  : natural range 0 to 317 := 317;
	constant middle_div_width  : natural range 0 to   6 :=   6;
	constant middle_div_offset : natural range 0 to  20 :=  20;
	------------------------------------------------------------
	constant p1_left 		   : natural range 0 to   4 :=   4;
	constant p1_right 		   : natural range 0 to  12 :=  12;
	constant p2_left 		   : natural range 0 to 627 := 627;
	constant p2_right 		   : natural range 0 to 634 := 634;
	------------------------------------------------------------
 	constant p1_score_pos_x    : natural range 0 to 280 := 280; 
	constant p1_score_pos_y    : natural range 0 to  20 :=  20; 
	constant p2_score_pos_x    : natural range 0 to 338 := 338;
	constant p2_score_pos_y    : natural range 0 to  20 :=  20; 
	constant offset 		   : natural range 0 to  22 :=  22;
	------------------------------------------------------------
	constant y_disp_start 	   : natural range 0 to 206 := 206;
	constant x_disp_start      : natural range 0 to 214 := 214;
	constant y_disp_end        : natural range 0 to 255 := 255;
	constant x_disp_end        : natural range 0 to 403 := 403;
	------------------------------------------------------------

	-- Needed signals
	--------------------------------------------------------------------------------
	signal RGB     	  	       : std_logic_vector ( 7 downto 0) := (others => '0');
	signal p1_RGB     	  	   : std_logic_vector ( 7 downto 0) := (others => '0');
	signal p2_RGB     	  	   : std_logic_vector ( 7 downto 0) := (others => '0');
	signal winner_RGB 	  	   : std_logic_vector ( 7 downto 0) := (others => '0');
	--------------------------------------------------------------------------------
	
	-- Components
	------------------------------------------------------------
	-- Component implementing the score
	component score_img is
		port ( x	       : in  natural range 0 to 799;
			   y           : in  natural range 0 to 524;
		       points 	   : in  natural range 0 to   9;
		       start_pos_x : in  natural range 0 to 639;
			   start_pos_y : in  natural range 0 to 479;
		       offset      : in  natural range 0 to  50;
		       RGB_out 	   : out std_logic_vector(7 downto 0)
	);
	end component;
	------------------------------------------------------------
	-- Component implementing the winner graphics
	component winner_view is
		port ( clk 	     : in std_logic;
		       p1_winner : in  std_logic;
			   p2_winner : in  std_logic;
			   x         : in  natural range 0 to 639;
			   y         : in  natural range 0 to 479;
			   RGB_out   : out std_logic_vector (7 downto 0)
		);
	end component;
	------------------------------------------------------------
	
begin
		
	color_output : process (video_on, x, y, p1_plwrh, p2_plwrh, p1_prumnh, p2_prumnh, b_down, b_up, b_left, b_right, RGB, p1_RGB, p2_RGB, p1_winner, p2_winner, winner_RGB)
		begin
			if (video_on = '1') then
				-- Checking if one of the players won the game
				if (p1_winner /= '0' or p2_winner /= '0') then
					-- If the x and y pointers are inside the wanted boundries, we increment set the output RGB values to the winner_RGB values					
					if (y >= y_disp_start and y <= y_disp_end) then
						if (x >= x_disp_start and x <= x_disp_end) then
							RGB <= winner_RGB;
						else 
							RGB <= (others => '0');
						end if;
					else 
						RGB <= (others => '0');
					end if;
				elsif (p1_winner = '0' or p2_winner = '0') then
					----two players----
					--               width								  position(height)
					if((x > p1_left and x < p1_right and y > p1_plwrh and y < p1_prumnh) or -- Left player
					   (x > p2_left and x < p2_right and y > p2_plwrh and y < p2_prumnh) or	-- Right player
					   (x > b_left  and x < b_right  and y > b_up     and y < b_down )   or -- Ball
					   (y > bottom_border or y < top_border)) then										-- Top and Botton borders
						RGB <= (others => '1');
					-- Midle divider 
					elsif (x > middle_div_start and x < middle_div_start + middle_div_width) then							
						if ((y >=   4 and y <=   4 + middle_div_offset + 5) or (y >=  49 and y <=  49 + middle_div_offset) or
							(y >=  89 and y <=  89 + middle_div_offset)     or (y >= 129 and y <= 129 + middle_div_offset) or
							(y >= 169 and y <= 169 + middle_div_offset)     or (y >= 209 and y <= 209 + middle_div_offset) or
							---------------------------------------------------------------------------------------------------------------------
							(y >= 249 and y <= 249 + middle_div_offset)     or (y >= 289 and y <= 289 + middle_div_offset) or
							(y >= 329 and y <= 329 + middle_div_offset)     or (y >= 369 and y <= 369 + middle_div_offset) or
							(y >= 409 and y <= 409 + middle_div_offset)     or (y >= 449 and y <= 449 + middle_div_offset + 5)) then
							RGB <= (others => '1');
						else
							RGB <= (others => '0');
						end if;
					-- Player 1 score
					elsif (x >= p1_score_pos_x and x <= p1_score_pos_x + offset) then
						if (y >= p1_score_pos_y and y <= p1_score_pos_y + offset + offset) then
							RGB <= p1_RGB;
						else
							RGB <= (others => '0');
						end if;
					-- Player 2 score
					elsif (x >= p2_score_pos_x and x <= p2_score_pos_x + offset) then
						if (y >= p2_score_pos_y and y <= p2_score_pos_y + offset + offset) then
							RGB <= p2_RGB;
						else
							RGB <= (others => '0');
						 end if;	 
					else
						RGB <= (others => '0');
					end if;
				else
					RGB <= (others => '0');
				end if;
			else
				RGB <= (others => '0');
			end if;
		end process;
		
	outRed   <= RGB(7 downto 5);
	outGreen <= RGB(4 downto 2);
	outBlue  <= RGB(1 downto 0);
	-----------------------------------------------------------
	p1_score : score_img 
		port map ( x           => x,
				   y           => y,
				   points 	   => p1_points,
				   start_pos_x => p1_score_pos_x,
				   start_pos_y => p1_score_pos_y,
				   offset      => offset,
				   RGB_out     => p1_RGB
		);
	-----------------------------------------------------------
	p2_score : score_img 
		port map ( x           => x,
				   y           => y,
				   points 	   => p2_points,
				   start_pos_x => p2_score_pos_x,
				   start_pos_y => p2_score_pos_y,
				   offset      => offset,
				   RGB_out     => p2_RGB
		);	
	-----------------------------------------------------------	
	winner : winner_view
		port map ( clk 	     => clk, 
				   p1_winner => p1_winner,
				   p2_winner => p2_winner,
				   x 	   	 => x,
				   y 	     => y,
		           RGB_out   => winner_RGB
		);
		
end Behavioral;