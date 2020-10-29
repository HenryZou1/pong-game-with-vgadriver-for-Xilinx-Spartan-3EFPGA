----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:41:57 11/25/2019 
-- Design Name: 
-- Module Name:    project2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project2 is
 Port ( CLK : in  STD_LOGIC;
           SW0: in STD_logic;
			  SW1: in STD_logic;
			  SW2: in std_logic;
			  SW3: in std_logic;
           HSYNC : out  STD_LOGIC;
           VSYNC : out  STD_LOGIC;
			  DAC_CLK: out STD_LOGIC;
			  
           Bout: out STD_logic_vector(7 downto 0);
			  Gout: out STD_logic_vector(7 downto 0);
			  Rout: out STD_logic_vector(7 downto 0));
end project2;

architecture Behavioral of project2 is

	signal clk25 : std_logic := '0';
	
	constant HD : integer := 639;  			--  639   Horizontal Display (640)
	constant HFP : integer := 16;          --   16   Right border (front porch)
	constant HSP : integer := 96;          --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;          --   48   Left boarder (back porch)
	
	constant VD : integer := 479;   			--  479   Vertical Display (480)
	constant VFP : integer := 10;       	--   10   Right border (front porch)
	constant VSP : integer := 2;				--    2   Sync pulse (Retrace)
	constant VBP : integer := 33;      		--   33   Left boarder (back porch)
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	signal ball_pos_h1      : integer := 320;
	signal ball_pos_v1      : integer:= 240;
	
	signal paddle1_pos_h1      : integer := 35;
	signal paddle1_pos_v1      : integer:= 300;	
	signal paddle1_pos_length_h      : integer := 10;
	signal paddle1_pos_length_v      : integer := 100;
	
	signal paddle2_pos_h1      : integer := 600;
	signal paddle2_pos_v1      : integer:= 300;	
	signal paddle2_pos_length_h      : integer := 10;
	signal paddle2_pos_length_v      : integer := 100;
	
	
	signal newframe: std_logic :='0';
	signal ballcolor: std_logic:= '0';
	signal ball_speed_h 	:  integer range -3 to 3 := 2;
	signal ball_speed_v	:  integer range -3 to 3:= 2;
	
	constant ballsize: integer:= 10;
	constant topborder: integer:= 0;
	constant topborderlength: integer:= 20;
	constant botborder:integer:= 479;
	constant botborderlength: integer:= 20;
	constant leftborder:integer:= 0;
	constant leftborderlength: integer:=20;
	constant rightborder:integer:= 639;
	constant rightborderlength: integer := 20;
	
	constant hole_left_v1: integer:= 100;
	constant hole_left_length: integer:= 300;
	
	constant hole_right_v1: integer:= 100;
	constant hole_right_length: integer:= 300;
	constant strip:integer:= 300;
	
	signal videoOn : std_logic := '0';

begin


clk_div:process(CLK)
begin
	if(CLK'event and CLK = '1')then
		clk25 <= not clk25;
	end if;
end process;

Horizontal_position_counter:process(clk25)
begin

	if(clk25'event and clk25 = '1')then
		if (hPos = (HD + HFP + HSP + HBP)) then
			newframe <= '0' ;
			hPos <= 0;
			if (vPos = (VD + VFP + VSP + VBP)) then
				newframe <= '1';
		
			end if;
		else
			newframe <= '0' ;
			hPos <= hPos + 1;
			
		end if;
	end if;
end process;

Vertical_position_counter:process(clk25, hPos)
begin

	if(clk25'event and clk25 = '1')then
		if(hPos = (HD + HFP + HSP + HBP))then
			if (vPos = (VD + VFP + VSP + VBP)) then
				vPos <= 0;
			else
				vPos <= vPos + 1;
				
			end if;
		end if;
	end if;
end process;

Horizontal_Synchronisation:process(clk25, hPos)
begin

	if(clk25'event and clk25 = '1')then
		if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
			HSYNC <= '1';
		else
			HSYNC <= '0';
		end if;
	end if;
end process;

Vertical_Synchronisation:process(clk25, vPos)
begin
	
	if(clk25'event and clk25 = '1')then
		if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
			VSYNC <= '1';
		else
			VSYNC <= '0';
		end if;
	end if;
end process;

video_on:process(clk25, hPos, vPos)
begin

	if(clk25'event and clk25 = '1')then
		if(hPos <= HD and vPos <= VD)then
			videoOn <= '1';
		else
			videoOn <= '0';
		end if;
	end if;
end process;

ball_move:process(clk25, newframe)
begin

	if(clk25'event and clk25 = '1' and newframe = '1')then
		
		ballcolor <= '0';
		if (ball_pos_v1< topborder+topborderlength) then
			ball_speed_v<= abs (ball_speed_v);
		end if;		
		if (ball_pos_v1+ballsize> botborder-botborderlength) then
			ball_speed_v<= (-1)* abs(ball_speed_v);
		end if;
		
		if (ball_pos_h1< leftborder+leftborderlength) then
			ball_speed_h<= abs (ball_speed_h);
		end if;		
		if (ball_pos_h1+ballsize> rightborder-rightborderlength) then
			ball_speed_h<= (-1)* abs(ball_speed_h);
		end if;
		
		if (ball_pos_h1 > paddle1_pos_h1 and ball_pos_h1 < paddle1_pos_h1+ paddle1_pos_length_h) and (ball_pos_v1 > paddle1_pos_v1 and ball_pos_v1 < paddle1_pos_v1+ paddle1_pos_length_v) then
			ball_speed_h<=  abs(ball_speed_h);	
		end if;
		
		if (ball_pos_h1+ballsize > paddle2_pos_h1 and ball_pos_h1+ballsize < paddle2_pos_h1+ paddle2_pos_length_h) and (ball_pos_v1 +ballsize> paddle2_pos_v1 and ball_pos_v1 < paddle2_pos_v1+ paddle2_pos_length_v) then
			ball_speed_h<= (-1)* abs(ball_speed_h);				
		end if;
		
		ball_pos_h1 <=ball_pos_h1 +ball_speed_h;
		ball_pos_v1 <= ball_pos_v1+ball_speed_v;
		
		if(ball_pos_h1 <leftborder+leftborderlength and (ball_pos_v1>hole_left_v1 and ball_pos_v1 <hole_left_v1+hole_left_length)) then
			ball_pos_h1<=320;
			ball_pos_v1<=240;
			
		end if;
		if(ball_pos_h1+ballsize> rightborder-rightborderlength and (ball_pos_v1>hole_right_v1 and ball_pos_v1 <hole_right_v1+hole_right_length)) then
			ball_pos_h1<=320;
			ball_pos_v1<=240;			
		end if;
		
		if(ball_pos_h1 <leftborder+leftborderlength+1 and (ball_pos_v1>hole_left_v1 and ball_pos_v1 <hole_left_v1+hole_left_length)) then
			ballcolor <= '1';	
		end if;
		if(ball_pos_h1+ballsize> rightborder-rightborderlength-1 and (ball_pos_v1>hole_right_v1 and ball_pos_v1 <hole_right_v1+hole_right_length)) then
			ballcolor <= '1';		
		end if;
		
	end if;
end process;

paddle_move:process(clk25, newframe)
begin

	if(clk25'event and clk25 = '1' and newframe = '1')then
		if (SW0 = '1' and  paddle1_pos_v1 > topborder+topborderlength) then
			paddle1_pos_v1 <= paddle1_pos_v1 - 1;
		end if;
		if (SW1 = '1' and  paddle1_pos_v1 +paddle1_pos_length_v< botborder-botborderlength) then
			paddle1_pos_v1 <= paddle1_pos_v1 + 1;
		end if;
		if (SW2 = '1' and  paddle2_pos_v1 > topborder+topborderlength) then
			paddle2_pos_v1 <= paddle2_pos_v1 - 1;
		end if;
		if (SW3 = '1' and  paddle2_pos_v1 +paddle2_pos_length_v< botborder-botborderlength) then
			paddle2_pos_v1 <= paddle2_pos_v1 + 1;
		end if;
		
	end if;
end process;

draw:process(clk25, hPos, vPos, videoOn)
begin

	if(clk25'event and clk25 = '1') then
		if(videoOn = '1') then
			if(vpos < topborder+topborderlength or vpos> botborder-botborderlength) then
				Rout <= "11111111";
				Gout <= "11111111";
				Bout <= "11111111";
			elsif(hpos <leftborder+leftborderlength and (vpos>hole_left_v1 and vpos <hole_left_v1+hole_left_length)) then 
				Rout <= "00000000";
				Gout <= "11111111";
				Bout <= "00000000";
			elsif(hpos > rightborder-rightborderlength and (vpos>hole_right_v1 and vpos <hole_right_v1+hole_right_length)) then 
				Rout <= "00000000";
				Gout <= "11111111";
				Bout <= "00000000";
			elsif (hpos <leftborder+leftborderlength or hpos> rightborder-rightborderlength) then
				Rout <= "11111111";
				Gout <= "11111111";
				Bout <= "11111111";
			elsif ( (hpos > paddle1_pos_h1 and hpos < paddle1_pos_h1+ paddle1_pos_length_h) and (vpos > paddle1_pos_v1 and vpos < paddle1_pos_v1+ paddle1_pos_length_v)) then
				Rout <= "11111111";
				Gout <= "00000000";
				Bout <= "00000000";
			elsif ( (hpos > paddle2_pos_h1 and hpos < paddle2_pos_h1+ paddle2_pos_length_h) and (vpos > paddle2_pos_v1 and vpos < paddle2_pos_v1+ paddle2_pos_length_v)) then
				Rout <= "00000000";
				Gout <= "00000000";
				Bout <= "11111111";
			elsif ( (hpos >= ball_pos_h1 and hpos < ball_pos_h1 + ballsize) and (vpos >= ball_pos_v1 and vpos < ball_pos_v1 + ballsize) ) then
				if (ballcolor = '0') then
					Rout <= "11111111";
					Gout <= "11111111";
					Bout <= "11111111";
				else
					Rout <= "11111111";
					Gout <= "00000000";
					Bout <= "00000000";
				end if;
			elsif( hpos > strip and hpos <strip +3) then
				Rout <= "11111111";
				Gout <= "11111111";
				Bout <= "00000000";
			else
				Rout <= "00000000";
				Gout <= "11111111";
				Bout <= "00000000";
			end if;
		else
				Rout <= "00000000";
				Gout <= "00000000";
				Bout <= "00000000";
		end if;
	end if;
end process;

DAC_CLK<=clk25;

end Behavioral;

