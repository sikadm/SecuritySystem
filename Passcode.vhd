Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity TestSecuritySystem is 
	port (clk : in std_logic;
			but_n1, but_n2, but_n3 : in std_logic;
			code, two : out std_logic);
end TestSecuritySystem;
	
architecture beh of TestSecuritySystem is 

	type state_type is (STATE_A, STATE_B, STATE_C, STATE_D, STATE_E, STATE_F); 
	signal state : state_type := STATE_A;
	signal counter : std_logic_vector(31 downto 0);
	
begin
	
	process(clk, but_n1, but_n2, but_n3) 
	begin
	
	if(rising_edge(clk)) then

		case state is
		
		when STATE_A =>
		two <= '0';
		if (but_n2 = '0') then 	-- button2 has been pressed
			two <= '1';
			state <= STATE_B;
		elsif (but_n1 = '0' or but_n3 = '0') then
			state <= STATE_F;
		else
			if counter < "10110010110100000101111000000000" then
				counter <= counter + 1;
			else 
				state <= STATE_F;
			end if;
		end if;
		
		when STATE_B =>
		if but_n1 = '0' then
			state <= STATE_C;
		elsif (but_n2 = '0' or but_n3 = '0') then
			state <= STATE_F;
		else 
			if counter < "10110010110100000101111000000000" then
				counter <= counter+ 1;
			else 
				state <= STATE_F;
			end if;
		end if;
		
		when STATE_C =>
		if but_n3 = '0' then
			state <= STATE_D;
		elsif (but_n1 = '0' or but_n2 = '0') then
			state <= STATE_F;
		else 
			if counter < "10110010110100000101111000000000" then
				counter <= counter+ 1;
			else 
				state <= STATE_F;
			end if;
		end if;
		
		when STATE_D =>
		if but_n1 = '0' then
			state <= STATE_E;
		elsif (but_n2 = '0' or but_n3 = '0') then
			state <= STATE_F;
		else
			if counter < "10110010110100000101111000000000" then
				counter <= counter + 1;
			else 
				state <= STATE_F;
			end if;
		end if;
		
		when STATE_E => 	-- code is correct
			code <= '1';
			
		when STATE_F => 	-- code is incorrect
			code <= '0';
		end case;
		end if;
	end process;
	
end beh;
