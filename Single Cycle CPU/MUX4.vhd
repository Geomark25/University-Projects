library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX4 is
     Port (
        Din0 : in std_logic_vector(7 downto 0);
        Din1 : in std_logic_vector(7 downto 0);      
        Din2 : in std_logic_vector(7 downto 0);
        Din3 : in std_logic_vector(7 downto 0);
        sel : in std_logic_vector(1 downto 0);
        output : out std_logic_vector(31 downto 0)
        );
end MUX4;

architecture Behavioral of MUX4 is

begin

    process(Din0, Din1, Din2, Din3, sel)
    begin
        case sel is
            when "00" =>
                output <= x"000000" & Din0;
            when "01" =>
                output <= x"000000" & Din1;
            when "10" =>
                output <= x"000000" & Din2;
            when "11" =>
                output <= x"000000" & Din3;
            when others =>
       end case;
    
    end process;

end Behavioral;
