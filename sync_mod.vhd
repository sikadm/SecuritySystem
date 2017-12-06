library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sync_mod is
    Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               start : in STD_LOGIC;
               y_control : out STD_LOGIC_VECTOR (9 downto 0);
               x_control : out STD_LOGIC_VECTOR (9 downto 0);
               h_s : out STD_LOGIC;
               v_s : out STD_LOGIC;
               video_on : out STD_LOGIC);
end sync_mod;

architecture Behavioral of sync_mod is
    -- Video Parameters
    constant HR:integer:=640;--Horizontal Resolution
    constant HFP:integer:=16;--Horizontal Front Porch 
    constant HBP:integer:=48;--Horizontal Back Porch
    constant HRet:integer:=96;--Horizontal retrace
    constant VR:integer:=480;--Vertical Resolution
    constant VFP:integer:=10;--Vertical Front Porch 
    constant VBP:integer:=33;--Vertical Back Porch
    constant VRet:integer:=2;--Vertical Retrace
    --sync counter
    signal counter_h,counter_h_next: integer range 0 to 799;
    signal counter_v,counter_v_next: integer range 0 to 524;
    --mod 2 counter
    signal counter_mod2,counter_mod2_next: std_logic:='0';
    --State signals
    signal h_end, v_end:std_logic:='0';
    --Output Signals(buffer)
    signal hs_buffer,hs_buffer_next:std_logic:='0';
    signal vs_buffer,vs_buffer_next:std_logic:='0';
    --pixel counter
    signal x_counter, x_counter_next:integer range 0 to 900;
    signal y_counter, y_counter_next:integer range 0 to 900;
    --video_on_off
    signal video:std_logic;
begin
    --clk register
    process(clk,reset,start)
    begin
        if reset ='1' then
           counter_h<=0;
           counter_v<=0;
           hs_buffer<='0';
           hs_buffer<='0';
           counter_mod2<='0';
        elsif clk'event and clk='1' then
           if start='1' then
                counter_h<=counter_h_next;
                counter_v<=counter_v_next;
                x_counter<=x_counter_next;
                y_counter<=y_counter_next;
                hs_buffer<=hs_buffer_next;
                vs_buffer<=vs_buffer_next;
                counter_mod2<=counter_mod2_next;
            end if;
       end if;
    end process;
     --video on/off
    video <= '1' when (counter_v >= VBP) and (counter_v < VBP + VR) and (counter_h >=HBP) and 
                                                                                  (counter_h < HBP + HR)    else 
                    '0';

   --mod 2 counter
    counter_mod2_next<=not counter_mod2;
    --end of Horizontal scanning 
    h_end<= '1' when counter_h=799 else 
                      '0'; 
    -- end of Vertical scanning
    v_end<= '1' when counter_v=524 else 
                     '0'; 
     -- Horizontal Counter
     process(counter_h,counter_mod2,h_end)
     begin
         counter_h_next<=counter_h;
         if counter_mod2= '1' then
             if h_end='1' then
                   counter_h_next<=0;
             else
                   counter_h_next<=counter_h+1;
             end if;
        end if;
     end process;

    -- Vertical Counter
    process(counter_v,counter_mod2,h_end,v_end)
    begin 
        counter_v_next <= counter_v;
        if counter_mod2= '1' and h_end='1' then
            if v_end='1' then
                   counter_v_next<=0;
             else
                    counter_v_next<=counter_v+1;
             end if;
       end if;
    end process;

   --pixel x counter
    process(x_counter,counter_mod2,h_end,video)
    begin 
         x_counter_next<=x_counter;
         if video = '1' then 
            if counter_mod2= '1' then 
                if x_counter= 639 then
                    x_counter_next<=0;
                else
                    x_counter_next<=x_counter + 1;
                end if;
            end if;
       else
            x_counter_next<=0;
       end if;
    end process;

   --pixel y counter
    process(y_counter,counter_mod2,h_end,counter_v)
    begin 
         y_counter_next<=y_counter;
         if counter_mod2= '1' and h_end='1' then 
            if counter_v >32 and counter_v <512 then
                 y_counter_next<=y_counter + 1;
            else 
                 y_counter_next<=0; 
            end if;
         end if;
    end process;

   --buffer
    hs_buffer_next<= '1' when counter_h < 704 else--(HBP+HGO+HFP) 
                                     '0';
     vs_buffer_next<='1' when counter_v < 523 else--(VBP+VGO+VFP) 
                                    '0';

    --outputs
    y_control <= conv_std_logic_vector(y_counter,10); 
    x_control <= conv_std_logic_vector(x_counter,10); 
    h_s<= hs_buffer;
    v_s<= vs_buffer;
    video_on<=video;

end Behavioral;
TEST PROGRAM

You can find a test VHDL code given below to test the vhdl code of the SYNC module.In this test program we connect the RGB signals to three switches. According to the combination of these switches we get 8 different colors on the screen.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_test is
     Port ( clk : in STD_LOGIC;
                sw : in STD_LOGIC_VECTOR (2 downto 0);
                rgb : out STD_LOGIC_VECTOR (2 downto 0);
                hsn : out STD_LOGIC;
                vsn : out STD_LOGIC );
end sync_test;

architecture Behavioral of sync_test is

     COMPONENT sync_mod
            PORT( clk : IN std_logic;
                          reset : IN std_logic;
                          start : IN std_logic; 
                          y_control : OUT std_logic_vector(9 downto 0);
                          x_control : OUT std_logic_vector(9 downto 0);
                          h_s : OUT std_logic;
                          v_s : OUT std_logic;
                          video_on : OUT std_logic );
      END COMPONENT;

     --buffer
     signal sw_next:STD_LOGIC_VECTOR (2 downto 0);
     signal video:std_logic;
begin
     process(clk)
     begin
         if clk'event and clk='1' then
              sw_next <=sw;
         end if;
     end process;

     Inst_sync_mod: sync_mod PORT MAP( clk => clk, reset => '0', start => '1', y_control => open, x_control => open,
                                                                         h_s => hsn, v_s => vsn, video_on => video );

     rgb<= "000" when video = '0' else
                  sw_next ;

end Behavioral;
