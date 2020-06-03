----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Convert the push button to a 1PPS that can be used to restart
--              camera initialisation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce_corto_ns is
    Port ( clk : in  STD_LOGIC;
				valor : in STD_LOGIC_VECTOR(3 downto 0);
           i : in  STD_LOGIC;
           o : out  STD_LOGIC);
end debounce_corto_ns;

architecture Behavioral of debounce_corto_ns is
	signal c : unsigned(3 downto 0);
	signal valor_cast : unsigned(3 downto 0);
	

begin

valor_cast <= unsigned(valor);

	process(clk)
	begin
		if rising_edge(clk) then
		   if i = '1' then
		      --if c = x"F" then
		      if c = valor_cast then
					o <= '1';
				else
					o <= '0';
					c <= c+1;
				end if;

			else
				c <= (others => '0');
				o <= '0';
			end if;
		end if;
	end process;

end Behavioral;

