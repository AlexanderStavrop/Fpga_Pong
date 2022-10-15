library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;               

entity winner_view is
	port ( clk       : in  std_logic;
		   p1_winner : in  std_logic;
		   p2_winner : in  std_logic;
		   x         : in  natural range 0 to 639;
		   y         : in  natural range 0 to 479;
		   RGB_out   : out std_logic_vector (7 downto 0)
	);
end winner_view;

architecture Behavioral of winner_view is
	-- Components
	-------------------------------------------------------
	-- component implementing the memory
	component memory
		port ( clka  : in  std_logic;
			   wea   : in  std_logic_vector( 0 downto 0);
			   addra : in  std_logic_vector(14 downto 0);
			   dina  : in  std_logic_vector( 0 downto 0);
			   douta : out std_logic_vector( 0 downto 0)
		);
	end component;
	-------------------------------------------------------
	
	-- Needed constants
	----------------------------------------------------------------------------
	constant p1_wins_addr : std_logic_vector(14 downto 0) := "000000000000000";
	constant p2_wins_addr : std_logic_vector(14 downto 0) := "010010011101010";
	constant zero_vector  : std_logic_vector( 0 downto 0) := (others => '0');
	----------------------------------------------------------------------------
	constant y_disp_start : natural range 0 to 206 := 206;
	constant x_disp_start : natural range 0 to 214 := 214;
	constant y_disp_end   : natural range 0 to 257 := 257;
	constant x_disp_end   : natural range 0 to 402 := 402;
	----------------------------------------------------------------------------
	
	-- Needed signals	
	----------------------------------------------------------------------------
	signal addra : std_logic_vector (14 downto 0) := (others => '0');
	signal douta : std_logic_vector ( 0 downto 0) := (others => '1');
	----------------------------------------------------------------------------
	
begin
	-------------------------------------------------------------------------------------------------------------------
	block_ram : memory
		port map ( clka  => clk,
				   wea   => zero_vector,
				   addra => addra,
				   dina  => zero_vector,
				   douta => douta
		);
	-------------------------------------------------------------------------------------------------------------------
	winner_message : process (clk, addra, x, y, p1_winner, p2_winner)
		begin
			if rising_edge(clk) then
				-- Checking whether one of the players won the game
				if (p1_winner /= '0' or p2_winner /= '0') then
					-- If the x and y pointers are inside the wanted boundries, we increment the address value by 1
					if (y >= y_disp_start and y <= y_disp_end) then
						if (x >= x_disp_start and x <= x_disp_end) then
							addra <= std_logic_vector(to_unsigned(to_integer(unsigned(addra)) + 1, 15));
						end if;
					-- Else we initialize the address value according to the player who won
					else
						if (p1_winner = '1') then
							addra <= p1_wins_addr;
						elsif (p2_winner = '1') then
							addra <= p2_wins_addr;
						else
							addra <= (others => '0');
						end if;
					end if;
				end if;
			end if;
	end process;
	
	-- Updating the output
	RGB_out <= (others => (douta(0)));

end Behavioral;
