library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_driver is
	generic ( H_disp : natural range 0 to 640 := 640;
			  H_fp   : natural range 0 to  16 := 16;
			  H_bp   : natural range 0 to  48 := 48;
			  H_Sync : natural range 0 to  96 := 96;
			  ----------------------------------------
			  V_disp : natural range 0 to 480 := 480;
			  V_fp	 : natural range 0 to  10 := 10;
			  V_bp   : natural range 0 to  33 := 33;
			  V_Sync : natural range 0 to   2 := 2
	);
	Port (clk      : in  std_logic;
		  rst      : in  std_logic;
		  HSync    : out std_logic;
		  VSync    : out std_logic;
		  video_on : out std_logic;
		  pixel_x  : out natural range 0 to 799;
		  pixel_y  : out natural range 0 to 524
	); 
end vga_driver;

architecture Behavioral of vga_driver is

	-- Needed constants
	----------------------------------------------------------------------------------------------------------------------------	
	constant H_max 		     : natural range 0 to (H_disp-1 + H_fp + H_Sync + H_bp) := H_disp-1 + H_fp + H_Sync + H_bp; -- 799
	constant V_max 		     : natural range 0 to (V_disp-1 + V_fp + V_Sync + V_bp) := V_disp-1 + V_fp + V_Sync + V_bp; -- 524
	constant H_retrace_start : natural range 0 to (H_disp-1 + H_fp) 				:= H_disp-1 + H_fp;					-- 655
	constant H_retrace_end   : natural range 0 to (H_disp-1 + H_fp + H_Sync) 		:= H_disp-1 + H_fp + H_Sync;		-- 751
	constant V_retrace_start : natural range 0 to (V_disp-1 + V_fp)				    := V_disp-1 + V_fp;					-- 489
	constant V_retrace_end   : natural range 0 to (V_disp-1 + V_fp + V_Sync) 		:= V_disp-1 + V_fp + V_Sync;		-- 491 
	----------------------------------------------------------------------------------------------------------------------------
	
	-- Needed signals
	----------------------------------------------------------------------------------------------------------------------------				
	signal H_pointer  : natural range 0 to H_max := 0;
	signal V_pointer  : natural range 0 to V_max := 0;
	----------------------------------------------------------------------------------------------------------------------------
	
begin

	-- Moving pixel by pixel on every actual_tic
	color_display : process(clk, H_pointer, V_pointer)
		begin
			if (rising_edge(clk)) then
				-- Checking whether the reset button is pressed, so we make every signal zero.
				if (rst = '1') then 
					H_pointer   <=  0;
					V_pointer   <=  0;
				else
					-- Checking whether we have reached the end of the total area, 
					--  so we make our pointers equal to zero.
					if (H_pointer = H_max and V_pointer = V_max) then 
						H_pointer <= 0;
						V_pointer <= 0;
					-- Else we check whether our H_pointer has reached its max value
					--  so we increment the V_pointer and reset the H_pointer.
					elsif (H_pointer = H_max) then
						V_pointer <= V_pointer + 1;
						H_pointer <= 0;
					-- Else we increment the H_pointer.	
					else
						H_pointer <= H_pointer + 1;
					end if;										
				end if;	
			end if;
	end process; 
	
	-- Updating the Hsync value accordingly 
	HSync <= '1' when H_pointer < H_retrace_start or H_pointer >= H_retrace_end else '0';
	
	-- Updating the Vsync value accordingly
	VSync <= '1' when V_pointer < V_retrace_start or V_pointer >= V_retrace_end else '0';
		
	-- Updating the Video_on only in the screen area
	video_on  <= '1' when V_pointer < V_disp and H_pointer < H_disp else '0';
	
	-- Updating the output pointers accordingly
	pixel_x	 <= H_pointer;
	pixel_y	 <= V_pointer;

end Behavioral;