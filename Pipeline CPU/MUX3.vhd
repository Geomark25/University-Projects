library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX3 is
    Port (
        R: in std_logic_vector(31 downto 0);
        EX_R: in std_logic_vector(31 downto 0);
        WB_R: in std_logic_vector(31 downto 0);
        Forward: in std_logic_vector(1 downto 0);
        output: out std_logic_vector(31 downto 0)
    );
end MUX3;

architecture Behavioral of MUX3 is

begin

    process(R, EX_R, WB_R, Forward)
    begin
        case Forward is
            when "10" =>
                output <= EX_R;
            when "01" =>
                output <= WB_R;
            when others =>
                output <= R;
         end case;
    end process;

end Behavioral;
