library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pkg.all;


entity MUX32 is
	port(
		input : in vector_array(0 to 31);
		output : out STD_LOGIC_VECTOR(31 downto 0);
		sel : in STD_LOGIC_VECTOR(4 downto 0)
	);
end MUX32;

architecture Behavioral of MUX32 is

begin
	
	output <= input(to_integer(unsigned(sel)));

end Behavioral;
