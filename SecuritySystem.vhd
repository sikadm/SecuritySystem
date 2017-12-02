Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity passcode is 
	port (but_n1, but_n2, but_n3 : in : std_logic;
			rightCode : out : std_logic);
end passcode;
	
architecture beh of passcode is 
begin
	type state_type is (STATE_A, STATE_B, STATE_C, STATE_D, STATE_E, STATE_F); 
	signal state : state_type := STATE_A;
	process(but_n1, but_n2, but_n3) 
	begin
		if but_n1'event and but_n1 = '0' or but_n2'event and but_n2 = '0' or but_n3'event and but_n3 = '0' then 	-- state changes when a button is pressed
		case state is
		
		when STATE_A =>
		if but_n2 = '0' then
			state <= STATE_B;
		else
			state <= STATE_F;
		end if;
		
		when STATE_B =>
		if but_n1 = '0' then
			state <= STATE_C;
		else 
			state <= STATE_F;
		end if;
		
		when STATE_C =>
		if but_n3 = '0' then
			state <= STATE_D;
		else 
			state <= STATE_F;
		end if;
		
		when STATE_D =>
		if but_n1 = '0' then
			state <= STATE_E;
		else
			state <= STATE_E;
		end if;
		
		when STATE_E => 
			rightCode = '1';
			
		when STATE_F =>
			rightCode = '0';
			
			
	end process;
end beh;