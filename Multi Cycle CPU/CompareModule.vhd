library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CompareModule is
    Port ( Ard : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
		   WrEn : in STD_LOGIC;
           output : out  STD_LOGIC);
end CompareModule;

architecture Behavioral of CompareModule is

begin
	
	process(Ard, Awr, WrEn)
	begin
		if WrEn = '1' then
			if Ard = Awr then
				output <= '1';
			else
				output <= '0';
			end if;
		else
			output <= '0';
		end if;
	end process;

end Behavioral;

