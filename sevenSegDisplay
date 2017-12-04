Library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sevenSegDisplay is 
	port (in0, in1, in2, in3 : in std_logic;
			a, b, c, d, e, f, g : out std_logic);
end sevenSegDisplay;
	
architecture beh of sevenSegDisplay is 
begin
	process(in0, in1, in2, in3) begin
			a <= (in0 AND NOT in1 AND NOT in2) OR (NOT in0 AND in2) OR (in1 AND in2) OR (in0 AND NOT in3) OR (NOT in1 AND NOT in2 AND NOT in3) OR (NOT in0 AND in1 AND in3);
			b <= (NOT in0 AND NOT in1) OR (NOT in0 AND NOT in2 AND NOT in3) OR (NOT in0 AND in2 AND in3) OR (in0 AND NOT in2 AND in3) OR (in0 AND NOT in1 AND NOT in3);
			c <= (NOT in0 AND NOT in2) OR (NOT in2 AND in3) OR (NOT in0 AND in3) OR (NOT in0 AND in1) OR (in0 AND NOT in1);
			d <= (NOT in1 AND in2 AND in3) OR (NOT in0 AND NOT in1 AND NOT in3) OR (in1 AND in2 AND NOT in3) OR (in1 AND NOT in2 AND in3) OR (in0 AND NOT in2 AND NOT in3);
			e <= (in0 AND in1) OR (in2 AND NOT in3) OR (in0 AND in2) OR (NOT in1 AND NOT in2 AND in3);
			f <= (NOT in2 AND NOT in3) OR (NOT in0 AND in1 AND NOT in2) OR (in0 AND NOT in1) OR (in0 AND in2) OR (in1 AND in2 AND NOT in3);
			g <= (NOT in1 AND in2) OR (in2 AND NOT in3) OR (in0 AND NOT in1) OR (in0 AND in3) OR (NOT in0 AND in1 AND NOT in2);
	end process;
end beh;
