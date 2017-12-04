Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity SecuritySystem is 
	port (reset, clk : in std_logic;
			door_n : in std_logic;
			a1, b1, c1, d1, e1, f1, g1 : out std_logic;
			a2, b2, c2, d2, e2, f2, g2 : out std_logic);
	end SecuritySystem;
	
architecture beh of SecuritySystem is 

type state_type is (STATE_Idle, STATE_Count, STATE_Alarm); 
signal state : state_type := STATE_Idle;
signal tens, ones : std_logic_vector(3 downto 0);
signal counter10 : std_logic_vector(28 downto 0);
signal counter1 : std_logic_vector(25 downto 0);
signal in0, in1, in2, in3 : std_logic;
signal code : std_logic;

begin
	
	process(reset, clk, door_n)
	begin
		if reset = '1' then              
			state <= STATE_Idle;
		elsif clk'event and clk = '1' then
			case state is
			
				when STATE_Idle =>
					if door_n = '0' then
						state <= STATE_Count;
					else
						state <= STATE_Idle;
					end if;
				
				
				when STATE_Count =>
					tens <= "0110";
					if counter10 < "11101110011010110010100000000" then
						counter10 <= counter10 + 1;
					else 
						tens <= tens - 1;
					end if;
					
					ones <= "0000";
					if counter1 < "10111110101111000010000000" then
						counter1 <= counter1 + 1;
					elsif ones = "0000" then
						ones <= "1001";
					else 
						ones <= ones - 1;
					end if;
					
					if code = '1' then
						state <= STATE_Idle;
					elsif tens = "0000" and ones = "0000" or code = '0' then
						state <= STATE_Alarm;
					end if;
					
				
				when STATE_Alarm =>
					state <= STATE_Idle;
					
			end case;
		end if;
	end process;
	
	component sevenSegDisplay 
		port (in0, in1, in2, in3 : in std_logic;
			a, b, c, d, e, f, g : out std_logic); 
	end component;
	
	display10s : sevenSegDisplay port map
					(tens(3), tens(2), tens(1), tens(0),
					 a1, b1, c1, d1, e1, f1, g1);
					 
	display1s : sevenSegDisplay port map
					(ones(3), ones(2), ones(1), ones(0),
					 a2, b2, c2, d2, e2, f2, g2);
					 
	component passcode
		port (rightCode : out std_logic)
	end component;
	
	passcode1 : passcode port map
					(code);
	
end beh;
