--based off lecture 8 resource
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity armed is
	port(
		clk, reset, textdisplay: in std_logic;
		pixel_x, pixel_y: in std_logic_vector(9 downto 0);
		text_on: out std_logic_vector(1 downto 0);
		text_rgb: out std_logic_vector(2 downto 0)
	);
end armed;

architecture arch of armed is
	signal pix_x, pix_y: unsigned(9 downto 0);
	signal rom_addr: std_logic_vector(10 downto 0);
	signal char_addr, char_addr_a, char_addr_d: std_logic_vector(6 downto 0);
	signal row_addr,row_addr_a, row_addr_d: std_logic_vector(3 downto 0);
	signal bit_addr,bit_addr_a, bit_addr_d: std_logic_vector(2 downto 0);
	signal font_word: std_logic_vector(7 downto 0);
	signal font_bit: std_logic;
	signal armed_on: std_logic;
	signal disarmed_on: std_logic;
	signal counterA: std_logic_vector(14 downto 0);
	signal counterB: std_logic_vector(12 downto 0);

	component font_rom
	   port(
      	clk: in std_logic;
      	addr: in std_logic_vector(10 downto 0);
      	data: out std_logic_vector(7 downto 0)
   		);
	end component;
	
begin
	pix_x <= unsigned(pixel_x);
	pix_y <= unsigned(pixel_y);

-- instantiate font rom
	font1: font_rom port map(clk, rom_addr, font_word);

--Display System Armed
if pix_y(9 downto 5)='0' and pix_x(9 downto 4)<16 then
	armed_on<='1';
	armed_off<='0';
else
	armed_on<='0';
	disarmed_on<=1;
end if; 
	
row_addr_a <= std_logic_vector(pix_y(5 downto 2));
bit_addr_a <= std_logic_vector(pix_x(4 downto 2));
row_addr_d <= std_logic_vector(pix_y(5 downto 2));
bit_addr_d <= std_logic_vector(pix_x(4 downto 2));


	with pix_x(8 downto 5) select char_addr_a <=
		"1010011" when "0100", -- S
		"1111001" when "0101", -- y
		"1110011" when "0110", -- s
		"1110100" when "0111", -- t
		"1100101" when "1000", -- e
		"1101101" when "1001", -- m
		"0000000" when "1010", -- 
		"1000001" when "1011", -- A
		"1110010" when "1100", -- r
		"1101101" when "1101", -- m
		"1100101" when "1110", -- e
		"1100100" when "1111", -- d
		"XXXXXXX" when others; --


--Display System Disarmed
	with pix_x(8 downto 5) select char_addr_d <=
		"1010011" when "0001", -- S
		"1111001" when "0010", -- y
		"1110011" when "0011", -- s
		"1110100" when "0100", -- t
		"1100101" when "0101", -- e
		"1101101" when "0110", -- m
		"0000000" when "0111", --
		"1000100" when "1000", --D
		"1101001" when "1001", --i
		"1110011" when "1010", --s
		"1100001" when "1011", -- a
		"1110010" when "1100", -- r
		"1101101" when "1101", -- m
		"1100101" when "1110", -- e
		"1100100" when "1111", -- d
		"0000000" when others; --

		

-- mux for font ROM addresses and rgb
process(pix_x, pix_y, font_bit,char_addr_a,row_addr_a,bit_addr_a, char_addr_d, row_addr_d, bit_addr_d)
begin
	text_rgb <= "000"; -- background, black
	if armed_on='1' then
		char_addr <= char_addr_a;
		row_addr <= row_addr_a;
		bit_addr <= bit_addr_a;
		if font_bit='1' then
			text_rgb <= "010";
		end if;

	else
		char_addr <= char_addr_d;
		row_addr <= row_addr_d;
		bit_addr <= bit_addr_d;
		if font_bit='1' then
			text_rgb <= "100";
		end if;
		

end if;
end process;
text_on<=armed_on & disarmed_on;

-- font rom interface
	rom_addr <= (char_addr & row_addr);
	font_bit <= font_word(to_integer(unsigned(not bit_addr)));
	
end arch;
