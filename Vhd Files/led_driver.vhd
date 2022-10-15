library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_driver is
	port ( i_clk 	  : in  std_logic;
		   i_rst 	  : in  std_logic;
		   i_led_1_en : in  std_logic;
		   i_led_2_en : in  std_logic;
		   o_led_1    : out std_logic;
		   o_led_2    : out std_logic
	);
end led_driver;

architecture Behavioral of led_driver is
	
	-- Needed signals
	----------------------------------------------------------------------
	signal interrupt  : std_logic := '0';
	signal enable     : std_logic := '0';
	----------------------------------------------------------------------

	-- Components
	-----------------------------------------
	-- Component implementing the led driver
	component timer is
		port ( clk 		 : in  std_logic;
			   rst 		 : in  std_logic;
			   enable	 : in  std_logic;
			   interrupt : out std_logic
		);
	end component;
	-----------------------------------------
	
begin
	----------------------------------------------------------------	
	-- Timer enable flag is high when a point is scored	
	enable_proc : process(i_clk, i_led_1_en, i_led_2_en, enable, interrupt)
		begin
			if (rising_edge(i_clk)) then
				if ((i_led_1_en or i_led_2_en) = '1') then
					enable <= '1';
				elsif (interrupt = '1') then
					enable <= '0';
				end if;
			end if;
	end process;
  	----------------------------------------------------------------
	-- Timer component
	led_timer : timer
		port map ( clk       => i_clk,
				   rst       => i_rst,
				   enable    => enable,
			       interrupt => interrupt
		);
	----------------------------------------------------------------
	-- When a goal is scored, the correspondigng led is turns on
	led_switcher : process(i_clk, interrupt, i_led_1_en, i_led_2_en)
		begin
			if (rising_edge(i_clk)) then
				if (interrupt = '1') then
					o_led_1 <= '0';
					o_led_2 <= '0';
				else
					if (i_led_1_en = '1') then
						o_led_1 <= '1';
					elsif (i_led_2_en = '1') then
						o_led_2 <= '1';
					end if;
				end if;
			end if;
	end process;
	----------------------------------------------------------------  
	
end Behavioral;
