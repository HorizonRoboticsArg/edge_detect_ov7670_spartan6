----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Captures the pixels coming from the OV7670 camera and 
--              Stores them in block RAM
--
-- The length of href last controls how often pixels are captive - (2 downto 0) stores
-- one pixel every 4 cycles.
--
-- "line" is used to control how often data is captured. In this case every forth 
-- line
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ov7670_capture is
    Port ( pclk  : in   STD_LOGIC;
           vsync : in   STD_LOGIC;
           href  : in   STD_LOGIC;
           d     : in   STD_LOGIC_VECTOR (7 downto 0);
           addr  : out  STD_LOGIC_VECTOR (12 downto 0);
           dout  : out  STD_LOGIC_VECTOR (15 downto 0);
           we    : out  STD_LOGIC);
end ov7670_capture;

architecture Behavioral of ov7670_capture is

	constant delta_x : integer := 5;
	constant delta_y : integer := 4;
	constant maximo_x : integer := 90;
	constant maximo_y : integer := 90;

   signal d_latch      : std_logic_vector(15 downto 0) := (others => '0');
   signal address      : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
   signal line         : std_logic_vector(1 downto 0)  := (others => '0');
   signal href_last    : std_logic_vector(6 downto 0)  := (others => '0');
   signal we_reg       : std_logic := '0';
   signal href_hold    : std_logic := '0';
   signal latched_vsync : STD_LOGIC := '0';
   signal latched_href  : STD_LOGIC := '0';
   signal latched_d     : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	--agregado por guillote
	signal select_byte : std_logic := '0';
	signal habilita_0 : std_logic := '0';
	signal habilita_1 : std_logic := '0';
	signal habilita_2 : std_logic := '0';
	signal habilita_we : std_logic := '0';
	signal cuenta_en_horiz : integer range 0 to 7 := delta_x;--para tener 90px
	signal cuenta_en_vert : integer range 0 to 7 := delta_y;--para tener 90px
	signal pixel_horiz : integer range 0 to 100 := 0;--para contar 90px
	signal pixel_vert : integer range 0 to 100 := 0;--para contar 90px
	signal d_buffer      : std_logic_vector(15 downto 0) := (others => '0');
	
	

	
begin
   addr <= address;
   we <= we_reg AND habilita_we;
   --dout    <= d_latch; 

	
	
	habilita_1 <= '1' when cuenta_en_horiz = 0 else '0';
	habilita_2 <= '1' when cuenta_en_vert = 0 else '0';
				
capture_process: process(pclk)
   begin
      if rising_edge(pclk) then
			
			
			
			if(select_byte = '1') then
			
				if(cuenta_en_horiz = delta_x) then
					cuenta_en_horiz <= 0;
				else
					cuenta_en_horiz <= cuenta_en_horiz + 1;
				end if;
				
			end if;
		
		
		
         if (pixel_horiz<maximo_x AND pixel_vert <maximo_y) then
				
				if (we_reg = '1') then
					address <= address + 1 ;
					pixel_horiz <= pixel_horiz + 1;
				end if;
				
				habilita_we <= '1';
				
			else
				habilita_we <= '0';
				
         end if;


			--ESTO LO HACIA ANTES!!
         -- This is a bit tricky href starts a pixel transfer that takes 3 cycles
         --        Input   | state after clock tick   
         --         href   | wr_hold    d_latch           dout          we address  address_next
         -- cycle -1  x    |    xx      xxxxxxxxxxxxxxxx  xxxxxxxxxxxx  x   xxxx     xxxx
         -- cycle 0   1    |    x1      xxxxxxxxRRRRRGGG  xxxxxxxxxxxx  x   xxxx     addr
         -- cycle 1   0    |    10      RRRRRGGGGGGBBBBB  xxxxxxxxxxxx  x   addr     addr
         -- cycle 2   x    |    0x      GGGBBBBBxxxxxxxx  RRRRGGGGBBBB  1   addr     addr+1
			--NO MAS
			
			
			--AHORA HACE ESTO
			--        Input   | state after clock tick   
         --         href   | wr_hold    d_buffer          dout              we address  address_next
         -- cycle -1  x    |    xx      xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxx  x   xxxx     xxxx
         -- cycle 0   1    |    x1      RRRRRGGGxxxxxxxx  xxxxxxxxxxxxxxxx  x   xxxx     addr
         -- cycle 1   0    |    10      RRRRRGGGGGGBBBBB  RRRRRGGGGGGBBBBB  1   addr     addr
         -- cycle 2   x    |    0x      RRRRRGGGxxxxxxxx  RRRRRGGGGGGBBBBB  0   addr     addr+1
			
			
			--debe ser leido en flanco descendente de pclock




			--detecta flanco ascendente en href, el comienzo de una nueva linea
         -- detect the rising edge on href - the start of the scan line
         if href_hold = '0' and latched_href = '1' then
			
				cuenta_en_horiz <= 0;
				pixel_horiz <= 0;
				
				if( (pixel_vert < maximo_y) and (habilita_2 = '1')) then -- para que no se pase de rosca jeje
					pixel_vert <= pixel_vert + 1;
				end if;
				
				if(cuenta_en_vert = delta_y) then
					cuenta_en_vert <= 0;
				else
					cuenta_en_vert <= cuenta_en_vert + 1;
				end if;
				
				
         end if;
			
			--guarda el nuevo href_hold (capturado en flanco desc)
         href_hold <= latched_href;
         
         --captura data de la camara, guarda en el byte correspondiente del bus
         if latched_href = '1' then
			
				if select_byte = '0' then
					d_buffer(7 downto 0) <= latched_d;
				else
					d_buffer(15 downto 8) <= latched_d;
				end if;
				
         end if;
			
         we_reg  <= '0';

         -- Is a new screen about to start (i.e. we have to restart capturing
         if latched_vsync = '1' then 
            address      <= (others => '0');
            href_last    <= (others => '0');
            line         <= (others => '0');
				
				pixel_horiz <= 0;
				pixel_vert <= 0;
				cuenta_en_horiz <= delta_x;
				cuenta_en_vert <= delta_y;
				
				


				we_reg <= '0';
				href_hold <= '0';

				--agregado por guillote
				select_byte <= '0';
				habilita_0 <= '0';
				habilita_we <= '0';
				d_buffer <= (others => '0');
				
         else

				select_byte <= not select_byte;
				

				
				habilita_0 <= habilita_1  AND habilita_2  AND NOT select_byte ;
				
				if(habilita_0 = '1') then
				
					we_reg  <= '1';
					
				end if;
				

         end if;
      end if;
      if falling_edge(pclk) then
         latched_d     <= d;
         latched_href  <= href;
         latched_vsync <= vsync;
			
			if (habilita_0 = '1') then 
				dout <= d_buffer;
			end if;	
      end if;
   end process;
end Behavioral;
