library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.pkg.all;

entity Decoder is
		Port ( 
		      input : in  STD_LOGIC_VECTOR (4 downto 0);
			  output : out STD_LOGIC_VECTOR(31 downto 0)
		);
		end Decoder;

architecture Behavioral of Decoder is

begin

	process(input)
	begin
		output <= (others => '0');
		output(to_integer(unsigned(input))) <= '1';
	end process;

end Behavioral;

