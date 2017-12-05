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
	signal video_on, pixel_tick, armed1_on, disarmed1_on: std_logic;
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	signal text_on: std_logic_vector(3 downto 0);
	signal text_rgb: std_logic_vector(2 downto 0);
	signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
	signal sw: std_logic_vector(6 downto 0);
	signal btn1: std_logic_vector(2 downto 0);
	
	component armed
		port(clk, reset, textdisplay: in std_logic;
				pixel_x, pixel_y: in std_logic_vector(9 downto 0);
			text_on,text_rgb: out std_logic_vector);
	end component;

	component vga_sync
	 port (pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
    reset_n   :  IN   STD_LOGIC;  --active low asycnchronous reset
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    disp_ena  :  OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    column    :  OUT  INTEGER;    --horizontal pixel coordinate
    row       :  OUT  INTEGER;    --vertical pixel coordinate
    n_blank   :  OUT  STD_LOGIC;  --direct blacking output to DAC
    n_sync    :  OUT  STD_LOGIC); --sync-on-green output to DAC
	 end component;
	 
	 component textGen
		port(
		clk, reset: std_logic;
		btn: std_logic_vector(2 downto 0);
		sw: std_logic_vector(6 downto 0);
		video_on: in std_logic;
		pixel_x, pixel_y: std_logic_vector(9 downto 0);
		text_rgb: out std_logic_vector(2 downto 0));
	end component;
	

	begin
--intantiate video synchonization unit
		VGA1: vga_sync port map (clk, reset, hsync, vsync, enable, column1, row1, blank, sync);
	
 --intantiate text
		text1: textGen port map (clk, reset, btn1, sw, video_on, pixel_x, pixel_y, text_rgb);
		A1: armed port map (clk, reset, armed1_on, pixel_x, pixel_y,text_on, text_rgb);
		D1: armed port map (clk, reset, disarmed1_on, pixel_x, pixel_y, text_on, text_rgb);	

--process	
--begin
--		if video_on='0' then
--			rgb_next<="000";
--		else
--			if (correct='1') then 
--				rgb_next:=text_rgb;
--			else
--				rgb_next:=text_rgb;
--			end if;
--		end if;
--	end process;
--	rgb<=rgb_reg;
	end arch;
	
