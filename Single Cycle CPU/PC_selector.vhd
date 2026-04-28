library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC_selector is
    Port (
        PC_sel : in std_logic_vector(1 downto 0);
        zero : in std_logic;
        PC_sel_out : out std_logic
    );
end PC_selector;

architecture Behavioral of PC_selector is

begin
    
    process(PC_sel, zero)
    begin
        case PC_sel is
            when "01" =>
                PC_sel_out <= zero;
            when "10" =>
                PC_sel_out <= not zero;
            when "11" =>
                PC_sel_out <= '1';
            when others =>
                PC_sel_out <= '0';
        end case;
    
    end process;

end Behavioral;
