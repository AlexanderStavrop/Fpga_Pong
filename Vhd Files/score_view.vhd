library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity score_img is
	port ( x           : in  natural range 0 to 799;
		   y           : in  natural range 0 to 524;
		   points 	   : in  natural range 0 to   9;
		   start_pos_x : in  natural range 0 to 639;
		   start_pos_y : in  natural range 0 to 479;
		   offset      : in  natural range 0 to  50;
		   RGB_out     : out std_logic_vector(7 downto 0)
	);
end score_img;

architecture Behavioral of score_img is

	-- Needed signals
	-------------------------------------------
	signal RGB : std_logic_vector(7 downto 0);
	-------------------------------------------
	
begin

	point_decoder : process (x, y, points, RGB, start_pos_x, start_pos_y, offset)
		begin
			if (x = start_pos_x) then 
				-- Seven segment F
				if (y >= start_pos_y and y < start_pos_y + offset) then
					if (points /= 1 and points /= 2 and points /= 3 and points /= 7) then 
						RGB <= (others => '1');
					else
						RGB <= (others => '0');
					end if;
				-- Seven segment E	
				elsif (y >= start_pos_y + offset and y <= start_pos_y + offset + offset) then 
					if (points = 0 or points = 2 or points = 6 or points = 8) then 
						RGB <= (others => '1');
					else
						RGB <= (others => '0');
					end if;	
				else 
					RGB <= (others => '0');
				end if;
			elsif (x >= start_pos_x and x < start_pos_x + offset) then 
				-- Seven segment A
				if (y = start_pos_y) then			
					if (points /= 1 and points /= 4) then 
						RGB <= (others => '1');
					else
						RGB <= (others => '0');
					end if;
				-- Seven segment G
				elsif (y = start_pos_y + offset) then
					if (points /= 0 and points /= 1 and points /= 7) then 
						RGB <= (others => '1');
					else
						RGB <= (others => '0');
					end if;
				-- Seven segment D	
				elsif (y = start_pos_y + offset + offset) then
					if (points /= 1 and points /= 4 and points /= 7) then 
						RGB <= (others => '1');
					else
						RGB <= (others => '0');
					end if;
				else
					RGB <= (others => '0');
				end if;
			elsif (x = start_pos_x + offset) then 
				-- Seven segment B
				if (y >= start_pos_y and y < start_pos_y + offset) then
					if (points /= 5 and points /= 6) then 
						RGB <= (others => '1');
					else
						RGB <= (others => '0');
					end if;
				-- Seven segment C	
				elsif (y >= start_pos_y + offset and y <= start_pos_y + offset + offset) then 
					if (points /= 2) then 
						RGB <= (others => '1');
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
	
	-- Updating the output
	RGB_out <= RGB;
	
end Behavioral;


