library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Controller is
       Port (
        Instr : in std_logic_vector(31 downto 0);
        ALU_func : out std_logic_vector(3 downto 0);
        ALU_Bin_sel : out std_logic;
        MEM_WrEn : out std_logic;
        Byte_sel : out std_logic;
        RF_B_sel : out std_logic;
        RF_WrData_sel : out std_logic;
        RF_WrEn: out std_logic;
        PC_sel : out std_logic_vector(1 downto 0);
        PC_LdEn : out std_logic;
        CTRL_in : out std_logic_vector(1 downto 0)
     );
    end Controller;

architecture Behavioral of Controller is

    signal branch : std_logic;

begin
    
    process(Instr)
    begin
        PC_LdEn <= '1';
        case Instr(31 downto 26) is
            when "100000" =>
                ALU_func <= Instr(3 downto 0);
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '1';
                PC_sel <= "00";
                CTRL_in <= "00";
            when "111000" | "111001" =>
                ALU_func <= "0000";
                ALU_Bin_sel <= '1';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '1';
                PC_sel <= "00";
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
                PC_sel <= "00";
                if Instr(27) = '1' then
                    CTRL_in <= "00";
                else
                    CTRL_in <= "10";
                end if;
                
           when  "111111" =>
                ALU_func <= "0000";
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '0';
                PC_sel <= "11";
                CTRL_in <= "11";
                
           when "010000" | "010001" =>
                ALU_func <= "0001";
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '1';
                RF_WrData_sel <= '0';
                RF_WrEn <= '0';
                if Instr(26) = '1' then
                    PC_sel <= "10";
                else
                    PC_sel <= "01";
                end if;
                CTRL_in <= "00";
                
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
                PC_sel <= "00";
                CTRL_in <= "00";
                
            when others =>
                ALU_func <= "0000";
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '0';
                PC_sel <= "00";
                CTRL_in <= "00";
        end case;
    end process;    

end Behavioral;
