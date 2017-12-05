Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity passcode is 
	port (clk : in std_logic;
			but_n1, but_n2, but_n3 : in std_logic;
			code : out std_logic);
end passcode;
	
architecture beh of passcode is 

	type state_type is (STATE_A, STATE_B, STATE_C, STATE_D, STATE_E, STATE_F); 
	signal state : state_type := STATE_A;
	
begin
	
	process(clk, but_n1, but_n2, but_n3) 
	begin
	if(rising_edge(clk)) then
		case state is
		
		when STATE_A =>
		if (but_n2'last_value = '1' and but_n2 = '0') then
			state <= STATE_B;
		else
			state <= STATE_F;
		end if;
		
		when STATE_B =>
		if (but_n1'last_value = '1' and but_n1 = '0') then
			state <= STATE_C;
		else 
			state <= STATE_F;
		end if;
		
		when STATE_C =>
		if (but_n3'last_value = '1' and but_n3 = '0') then
			state <= STATE_D;
		else 
			state <= STATE_F;
		end if;
		
		when STATE_D =>
		if (but_n1'last_value = '1' and but_n1 = '0') then
			state <= STATE_E;
		else
			state <= STATE_E;
		end if;
		
		when STATE_E => 
			code <= '1';
			
		when STATE_F =>
			code <= '0';
		end case;
		end if;
	end process;
end beh;
