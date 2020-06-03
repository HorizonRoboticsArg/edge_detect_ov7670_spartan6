
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.paquete_multiplexor.all;

entity multiplexor_16x16bits is
    Port (	selector : in  STD_LOGIC_VECTOR(3 downto 0);
				entrada_multiplex : in vector16x16bits;
				salida : out  STD_LOGIC_VECTOR(15 downto 0));
end multiplexor_16x16bits;

architecture Behavioral of multiplexor_16x16bits is

begin

	salida <= 	entrada_multiplex(0) when selector = X"0" else
					entrada_multiplex(1) when selector = X"1" else
					entrada_multiplex(2) when selector = X"2"	else
					entrada_multiplex(3) when selector = X"3"	else
					entrada_multiplex(4) when selector = X"4"	else
					entrada_multiplex(5) when selector = X"5"	else
					entrada_multiplex(6) when selector = X"6"	else
					entrada_multiplex(7) when selector = X"7"	else
					entrada_multiplex(8) when selector = X"8" else
					entrada_multiplex(9) when selector = X"9" else
					entrada_multiplex(10) when selector = X"A" else
					entrada_multiplex(11) when selector = X"B" else
					entrada_multiplex(12) when selector = X"C" else
					entrada_multiplex(13) when selector = X"D" else
					entrada_multiplex(14) when selector = X"E" else
					entrada_multiplex(15) when selector = X"F" else
					X"0000";

end Behavioral;

