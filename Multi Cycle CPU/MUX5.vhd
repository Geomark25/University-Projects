library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity MUX5 is
    Port ( Din0 : in  STD_LOGIC_VECTOR (4 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (4 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (4 downto 0));
end MUX5;

architecture Behavioral of MUX5 is

begin
	
	process(sel, Din0, Din1)
	begin
	if sel = '1' then
		Dout <= Din1;
	else
		Dout <= Din0;
	end if;
	end process;

end Behavioral;
