library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           Op : in  STD_LOGIC_VECTOR (3 downto 0);
           Output : out  STD_LOGIC_VECTOR (31 downto 0);
           Zero : out  STD_LOGIC;
           Cout : out  STD_LOGIC;
           Ovf : out  STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

begin

Process(A,B,Op)
	variable temp_out: std_logic_vector (32 downto 0);
	variable oof: std_logic_vector (31 downto 0);
begin

	case op is
		
		when "0000" =>
			temp_out := std_logic_vector(unsigned('0' & A) + unsigned('0' & B));
			if ((A(31) = '1' and B(31) = '1' and temp_out(31) = '0') or (A(31) = '0' and B(31) = '0' and temp_out(31) = '1')) then
			ovf <= '1';
			else
			ovf <= '0';
			end if;
			cout <= temp_out(32);
		when "0001" =>
			oof := std_logic_vector(unsigned(not B) + 1);
			temp_out := std_logic_vector(unsigned('0' & A) + unsigned('0' & oof));
			if ((A(31) = '1' and oof(31) = '1' and temp_out(31) = '0') or (A(31) = '0' and oof(31) = '0' and temp_out(31) = '1')) then
			ovf <= '1';
			else
			ovf <= '0';
			end if;
			cout <= temp_out(32);
		when "0010" =>
			temp_out(31 downto 0) := A and B;
		when "0011" =>
			temp_out(31 downto 0) := A or B;
		when "0100" =>
			temp_out(31 downto 0) := NOT A;
		when "1000" =>
			temp_out(31 downto 0) := A(31) & A(31 downto 1);
		when "1001" =>
			temp_out(31 downto 0) := '0' & A(31 downto 1);
		when "1010" =>
			temp_out(31 downto 0) := A(30 downto 0) & '0';
		when "1100" =>
			temp_out(31 downto 0) := A(30 downto 0) & A(31);
		when "1101" =>
			temp_out(31 downto 0) := A(0) & A(31 downto 1);
		when others =>
			temp_out := (others => '0');
		end case;
		
	if temp_out = (32 downto 0 => '0') then
		zero <= '1';
	else
		zero <= '0';
	end if;
	
	output <= temp_out(31 downto 0);
		
end process;

end Behavioral;

