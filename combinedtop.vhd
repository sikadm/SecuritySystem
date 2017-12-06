Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Final_Security_System is 
	port (reset, clk : in std_logic;
			but_n1, but_n2, but_n3 : in std_logic;
			a1, b1, c1, d1, e1, f1, g1 : out std_logic;
			a2, b2, c2, d2, e2, f2, g2 : out std_logic;
			LED1, LED2, LED3, LED4, LED5, LED6 : out std_logic;
			door_n, armed : in std_logic
      hsync, vsync, enable, blank, sync: out std_logic;
      column1, row1: out integer;
      rgb: out std_logic_vector (2 downto 0));
    rowco      :  IN   INTEGER;    --row pixel coordinate
    columnco   :  IN   INTEGER;    --column pixel coordinate
    red      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
	end Final_Security_System;
	
architecture beh of Final_Security_System is 

type state_type is (STATE_Armed, STATE_Count, STATE_Alarm, STATE_Disarmed); 
signal state : state_type := STATE_Disarmed;
signal tens, ones : std_logic_vector(3 downto 0);
signal counter10 : std_logic_vector(28 downto 0);
signal counter1 : std_logic_vector(25 downto 0);
signal in0, in1, in2, in3 : std_logic;
signal code : std_logic;
signal lights : std_logic;

	component sevenSegDisplay 
		port (in0, in1, in2, in3 : in std_logic;
			a, b, c, d, e, f, g : out std_logic); 
	end component;
					 
	component passcode
		port (clk : in std_logic;
				but_n1, but_n2, but_n3 : in std_logic;
				code : out std_logic);
	end component;
  
  component armed
		port(clk, reset, textdisplay: in std_logic;
				pixel_x, pixel_y: in std_logic_vector(9 downto 0);
			  text_on: out std_logic;
        text_rgb: out std_logic_vector);
	end component;
	
  component vga_controller
    port(
    pixel_clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
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
	
	display10s : sevenSegDisplay port map
					(tens(3), tens(2), tens(1), tens(0),
					 a1, b1, c1, d1, e1, f1, g1);
					 
	display1s : sevenSegDisplay port map
					(ones(3), ones(2), ones(1), ones(0),
					 a2, b2, c2, d2, e2, f2, g2);
					 
	passcode1 : passcode port map(clk, but_n1, but_n2, but_n3, code);
  
  VGA1 : vga_controller port map(pixel_clk1, reset, h_sync, v_sync, enable, column1, row1, blank, sync);
  
  text1: textGen port map (clk, reset, btn1, sw, video_on, pixel_x, pixel_y, text_rgb);
  
	A1: armed port map (clk, reset, armed1_on, pixel_x, pixel_y,text_on, text_rgb);
	
	LED1 <= lights;
	LED2 <= lights;
	LED3 <= lights;
	LED4 <= lights;
	LED5 <= lights;
	LED6 <= lights;
	
	process(reset, clk, door_n)
	begin
		if reset = '1' then              
			state <= STATE_Disarmed;
		elsif rising_edge(clk) then
			case state is
			
				when STATE_Disarmed =>
          armed1_on<='0';
					lights <= '0';
					code <= null;
					if armed = '1' then
						state <= STATE_Armed;
					else 
						state <= STATE_Disarmed;
					end if;
			
				when STATE_Armed =>
          armed_on1<='1';
					if door_n = '0' then
						state <= STATE_Count;
					else
						state <= STATE_Armed;
					end if;
				
				
				when STATE_Count =>
					tens <= "0110";
						if counter10 < "11101110011010110010100000000" then
							counter10 <= counter10 + 1;
						else 
							tens <= tens - 1;
							counter10 <= (others => '0');
						end if;
					
					ones <= "0000";
						if counter1 < "10111110101111000010000000" then
							counter1 <= counter1 + 1;
						elsif ones = "0000" then
							ones <= "1001";
							counter1 <= (others => '0');
						else 
							ones <= ones - 1;
							counter1 <= (others => '0');
						end if;
					
					if code = '1' then
						state <= STATE_Disarmed;
					elsif ((tens = "0000" and ones = "0000") or code = '0') then
						state <= STATE_Alarm;
					end if;
					
				
				when STATE_Alarm =>
						if counter1 < "1011111010111100001000000" then
							counter1 <= counter1 + 1;
						else
							lights <= not lights;
							counter1 <= (others => '0');
						end if;

					lights <= '1';
					state <= STATE_Alarm;
					
			end case;
		end if;
		
	end process;
	
end beh;
