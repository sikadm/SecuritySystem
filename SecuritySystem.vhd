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
			door_n, armed : in std_logic);
	end Final_Security_System;
	
architecture beh of Final_Security_System is 

type state_type is (STATE_Armed, STATE_Count, STATE_Alarm, STATE_Disarmed); 
signal state : state_type := STATE_Disarmed;
signal tens, ones : std_logic_vector(3 downto 0);	-- tens and ones are BCD that will map to countdown display's inputs
signal counter10 : std_logic_vector(28 downto 0);
signal counter1, counter : std_logic_vector(25 downto 0);
signal in0, in1, in2, in3 : std_logic; 				-- inputs for countdown display
signal code : std_logic_vector(1 downto 0);
signal lights : std_logic;

	component sevenSegDisplay 			-- declare countdown display component
		port (in0, in1, in2, in3 : in std_logic;
			a, b, c, d, e, f, g : out std_logic); 
	end component;
					 
	component passcode				-- declare component for detecting correct passcode
		port (clk, reset : in std_logic;
				but_n1, but_n2, but_n3 : in std_logic;
				code : out std_logic_vector(1 downto 0));
	end component;
	
begin
	
	display10s : sevenSegDisplay port map				-- instantiate display component for tens place
					(tens(3), tens(2), tens(1), tens(0),
					 a1, b1, c1, d1, e1, f1, g1);
					 
	display1s : sevenSegDisplay port map				-- instantiate display component for ones place
					(ones(3), ones(2), ones(1), ones(0),
					 a2, b2, c2, d2, e2, f2, g2);
					 
	passcode1 : passcode port map 						-- instantiate passcode detector component
					(clk, reset, but_n1, but_n2, but_n3, code);
	
	LED1 <= lights;		-- all LEDs for the alarm flash in unison
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
			
				when STATE_Disarmed => 			-- When disarmed, most signals are set to 0 so they can restart when armed
					tens <= "0000";
					ones <= "0000";
					counter10 <= (others => '0');
					counter1 <= (others => '0');
					counter <= (others => '0');
					lights <= '0';
					if armed = '1' then
						state <= STATE_Armed;
					else 
						state <= STATE_Disarmed; 		-- stay disarmed until "armed" switch is flipped
					end if;
			
				when STATE_Armed => 			
					if door_n = '0' then		-- stay armed until door is opened
						tens <= "0101";		-- set tens to 5 and ones to 9 (start at 59)
						ones <= "1001";
						state <= STATE_Count;
					else
						state <= STATE_Armed;
					end if;
				
				when STATE_Count =>
						
					if counter1 < "10111110101111000010000000" then 	-- counts 1 second
						counter1 <= counter1 + 1;
					elsif ones = "0000" then				-- loops back to 9 seconds after 0
						ones <= "1001";
						counter1 <= (others => '0');
					else 
						ones <= ones - 1;						-- otherwise, decrements
						counter1 <= (others => '0');
					end if;
						
					if counter10 < "11101110011010110010100000000" then 	-- counts up to 10 seconds
						counter10 <= counter10 + 1;
					else 
						tens <= tens - 1;												-- decrements every 10 seconds
						counter10 <= (others => '0');
					end if;
					
					if code = "11" then				-- passcode was entered correctly
						state <= STATE_Disarmed;
					elsif ((tens = "0000" and ones = "0000") or code = "00") then	-- countdown ends or code was entered incorrectly
						state <= STATE_Alarm;
					end if;
				
				when STATE_Alarm =>
						if counter < "1011111010111100001000000" then 	-- counter to make LEDs blink every second
							counter <= counter + 1;
						else
							lights <= not lights;
							counter <= (others => '0');
						end if;

					state <= STATE_Alarm; 	-- stays in alarm state unless reset
					
			end case;
		end if;
		
	end process;
	
end beh;
