library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ImmedConverter is
    Port ( CTRL_in : in STD_LOGIC_VECTOR (1 downto 0);
			  input : in  STD_LOGIC_VECTOR (15 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end ImmedConverter;

architecture Behavioral of ImmedConverter is

begin

	process(CTRL_in ,input)
	begin
		
		case CTRL_in is
			
			--sign extension
			when "00" =>
				if input(15) = '1' then
					output <= x"FFFF" & input;
				else
					output <= x"0000" & input;
				end if;
				
			--zero fill (lsb)
			when "01" =>
				output <= input & x"0000";
			
			--zero fill (msb)
			when "10" =>
				output <= x"0000" & input;
				
			--sign extension && << 2
			when "11" =>
				if input(15) = '1' then
					output <= "11111111111111" & input & "00";
				else
					output <= "00000000000000" & input & "00";
				end if;
	
			when others =>
					output <= (others => '0');
			
		end case;
	end process;
end Behavioral;
