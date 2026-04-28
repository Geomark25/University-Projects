library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ForwardingUnit is
    port (
        EX_WrEn: in std_logic;
        WB_WrEn: in std_logic;
        EX_Rd: in std_logic_vector(4 downto 0);
        WB_Rd: in std_logic_vector(4 downto 0);
        ID_Rs: in std_logic_vector(4 downto 0);
        ID_Rt: in std_logic_vector(4 downto 0);
        ForwardA: out std_logic_vector(1 downto 0);
        ForwardB: out std_logic_vector(1 downto 0)
     );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is

begin

    process(EX_WrEn, WB_WrEn, EX_Rd, WB_Rd, ID_Rs, ID_Rt)
    begin
    
        if((EX_WrEn = '1' and EX_Rd /= "00000") and (EX_Rd = ID_Rs)) then
            ForwardA <= "10";
        elsif ((WB_WrEn = '1' and WB_Rd /= "00000") and (WB_Rd = ID_Rs)) then
            ForwardA <= "01";
        else
            ForwardA <= "00";
        end if;
        
        if((EX_WrEn = '1' and EX_Rd /= "00000") and (EX_Rd = ID_Rt)) then
            ForwardB <= "10";
        elsif ((WB_WrEn = '1' and WB_Rd /= "00000") and (WB_Rd = ID_Rt)) then
            ForwardB <= "01";
        else
            ForwardB <= "00";
        end if;
        
    end process;

end Behavioral;
