library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
       Port (
        Instr : in std_logic_vector(31 downto 0);
        output_bus: out std_logic_vector(11 downto 0)
     );
    end Controller;

architecture Behavioral of Controller is

        signal ALU_func : std_logic_vector(3 downto 0);
        signal ALU_Bin_sel : std_logic;
        signal MEM_WrEn : std_logic;
        signal Byte_sel : std_logic;
        signal RF_B_sel : std_logic;
        signal RF_WrData_sel : std_logic;
        signal RF_WrEn: std_logic;
        signal CTRL_in : std_logic_vector(1 downto 0);
        
begin
    
    process(Instr)
    begin
        case Instr(31 downto 26) is
            when "100000" =>
                ALU_func <= Instr(3 downto 0);
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '1';
                CTRL_in <= "00";
                
            when "111000" | "111001" =>
                ALU_func <= "0000";
                ALU_Bin_sel <= '1';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '1';
                if Instr(26) = '1' then
                    CTRL_in <= "00";
                else
                    CTRL_in <= "01";
                end if;
                
           when  "110000" | "110010" | "110011" =>
                ALU_func <= Instr(29 downto 26);
                ALU_Bin_sel <= '1';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '1';
                if Instr(27) = '1' then
                    CTRL_in <= "00";
                else
                    CTRL_in <= "10";
                end if;
                                
            when "000011" | "001111" | "011111" =>
                ALU_func <= "0000";
                ALU_Bin_sel <= '1';
                if Instr(30) = '1' then
                    MEM_WrEn <= '1';
                    RF_WrEn <= '0';
                else
                    MEM_WrEn <= '0';
                    RF_WrEn <= '1';
                end if;
                if Instr(29) = '1' then
                    Byte_sel <= '0';
                else
                    Byte_sel <= '1';
                end if;
                RF_B_sel <= '1';
                RF_WrData_sel <= '1';
                CTRL_in <= "00";
                
            when others =>
                ALU_func <= "0000";
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '0';
                CTRL_in <= "00";
        end case;
    end process;
    
    --WB bus
    output_bus(11) <= RF_WrData_sel;
    output_bus(10) <= RF_WrEn;
    output_bus(9) <= MEM_WrEn;
    output_bus(8) <= Byte_sel;
    output_bus(7 downto 4) <= ALU_func;
    output_bus(3) <= ALU_Bin_sel;
    output_bus(2) <= RF_B_Sel;
    output_bus(1 downto 0) <= CTRL_in;

end Behavioral;
