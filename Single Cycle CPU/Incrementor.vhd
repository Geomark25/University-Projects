library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Incrementor is
    Port ( PC_in : in STD_LOGIC_VECTOR (31 downto 0);
           PC_immed : in STD_LOGIC_VECTOR (31 downto 0);
           Incr : out STD_LOGIC_VECTOR (31 downto 0);
           Incr_immed : out STD_LOGIC_VECTOR (31 downto 0));
end Incrementor;

architecture Behavioral of Incrementor is

begin

    Incr <= std_logic_vector(unsigned(PC_in) + to_unsigned(4,32));
    Incr_immed <= std_logic_vector(unsigned(PC_in) + unsigned(PC_immed) + to_unsigned(4,32));
    
end Behavioral;
