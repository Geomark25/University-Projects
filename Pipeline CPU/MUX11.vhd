library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity MUX11 is
    Port ( Din0 : in  STD_LOGIC_VECTOR (11 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (11 downto 0));
end MUX11;

architecture Behavioral of MUX11 is

begin
	
	process(sel, Din0)
	begin
	if sel = '1' then
		Dout <= x"000";
	else
		Dout <= Din0;
	end if;
	end process;

end Behavioral;

