library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity EX_MEM is
    Port ( CLK : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (72 downto 0);
           Dout : out  STD_LOGIC_VECTOR (72 downto 0));
end EX_MEM;

architecture Behavioral of EX_MEM is

begin

	process
	begin
		wait until CLK'EVENT and CLK = '1';
		if(RST = '1') then
			Dout <= (others => '0');
		else
			if WE = '1' then
				Dout <= Data;
			end if;
		end if;
	end process;

end Behavioral;