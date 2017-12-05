--currently called SecuritySystem to test just VGA
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity SecuritySystem is 
   port(
 clk, reset: in std_logic;
 btn: in std_logic_vector (1 downto 0);
 hsync, vsync, enable, blank, sync: out std_logic;
 column1, row1: out integer;
 rgb: out std_logic_vector (2 downto 0)
 ); 
 end SecuritySystem;
 
 architecture arch of SecuritySystem is
	type state_type is (sysArmed, sysDisarmed);
	signal video_on, pixel_tick, armed1_on: std_logic;
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	signal text_on: std_logic_vector(3 downto 0);
	signal text_rgb: std_logic_vector(2 downto 0);
	signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
	signal state_reg, state_next: state_type;
	

	begin
--intantiate video synchonization unit
		VGA1: vga_sync port map (clk, reset, hsync, vsync, enable, column1, row1, blank, sync);
	
 --intantiate text
		text1: textGen port map (clk, reset, btn, sw, video_on, pixel_x, pixel_y, text_rgb);

		
	process (state_reg, video_on,text_on,text_rgb)
	begin

	case state_reg is
	when sysArmed =>
		armed1_on<='1';
		textArmed: armed port map (clk, reset, armed1_on, pixel_x, pixel_y, text_on, text_rgb);

	when sysDisarmed =>
		armed1_on<='0';
		textDisarmed: armed port map (clk, reset, disarmed1_on, pixel_x, pixel_y, text_on, text_rgb);	
	end case;
	
		if video_on='0' then
			rgb_next<="000";
		else
			if (correct='1')
				(state_reg=sysArmed)
				rgb_next <= text_rgb;
			elsif (correct='0')
				(state_reg <= sysDisarmed)
				rgb_next <= text_rgb;
			end if;
		end if;
	end process;
	rgb<=rgb_reg;
	end arch;
	
