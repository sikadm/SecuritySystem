Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity passcode is 
	port (clk, reset : in std_logic;
			but_n1, but_n2, but_n3 : in std_logic;
			code : out std_logic_vector(1 downto 0)); -- vector so it can hold an indeterminate state (Kevin's suggestion)
end passcode;
	
architecture beh of passcode is 

	type state_type is (STATE_A, STATE_B, STATE_C, STATE_D, STATE_E, STATE_F); 
	signal state : state_type := STATE_A;
	
begin
	
	process(clk, but_n1, but_n2, but_n3, reset) 
	begin
	
	if(rising_edge(clk)) then

		case state is
		
		when STATE_A =>
		code <= "01";		-- set code to an indeterminate combination until code has been entered
		if (but_n2 = '0') then 		-- button2 has been pressed
			state <= STATE_B;
		elsif (but_n1 = '0' or but_n3 = '0') then	-- code entered incorrectly
			state <= STATE_F;
		else
			state <= STATE_A;		-- stay in state until a button is pressed
		end if;
		
		when STATE_B =>
		code <= "01";
		if (but_n1 = '0') then
			state <= STATE_C;
		elsif (but_n3 = '0') then -- removed but_n2 = '0' because it was detecting button press from state A and going straight to state F (Kevin's suggestion)
			state <= STATE_F;
		else 
			state <= STATE_B;
		end if;
		
		when STATE_C =>
			code <= "01";
		if (but_n3 = '0') then
			state <= STATE_D;
		elsif (but_n2 = '0') then
			state <= STATE_F;
		else 
			state <= STATE_C;
		end if;
		
		when STATE_D =>
			code <= "01";
		if (but_n1 = '0') then
			state <= STATE_E;
		elsif (but_n2 = '0') then
			state <= STATE_F;
		else
			state <= STATE_D;
		end if;
		
		when STATE_E => 	-- code is correct
			code <= "11";
			if reset = '1' then		-- code returns to indederminate state when system reset
				state <= STATE_A;
			else 
				state <= STATE_E;
			end if;
			
		when STATE_F => 	-- code is incorrect
			code <= "00";
			if reset = '1' then
				state <= STATE_A;
			else 
				state <= STATE_F;
			end if;
		
		
		when others => 		-- account for other possibilities
		state <= STATE_A;
		
		end case;
		end if;
	end process;
	
end beh;
