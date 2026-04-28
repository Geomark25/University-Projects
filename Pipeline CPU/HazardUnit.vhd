library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardUnit is
    Port (
        ID_EX_Rt: in std_logic_vector(4 downto 0);
        IF_ID_Rs: in std_logic_vector(4 downto 0);
        IF_ID_Rt: in std_logic_vector(4 downto 0);
        ID_EX_MEM_load: in std_logic;
        IF_ID_en: out std_logic;
        PC_LdEn: out std_logic;
        control_en: out std_logic
    );
end HazardUnit;

architecture Behavioral of HazardUnit is

begin

    process(ID_EX_Rt, IF_ID_Rs, IF_ID_Rt, ID_EX_MEM_load)
    begin
        
        if((ID_EX_MEM_load = '0') and ((ID_EX_Rt = IF_ID_Rs) or (ID_EX_Rt = IF_ID_Rt))) then
            PC_LdEn <= '0';
            control_en <= '1';
            IF_ID_en <= '0';
        else
            PC_LdEn <= '1';
            control_en <= '0';
            IF_ID_en <= '1';
        end if;
            
    end process;

end Behavioral;
