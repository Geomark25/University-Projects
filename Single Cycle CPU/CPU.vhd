library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU is
    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC);
end CPU;

architecture Behavioral of CPU is

component Datapath is
     Port (
        Instr : out std_logic_vector(31 downto 0);
        ALU_func : in std_logic_vector(3 downto 0);
        ALU_Bin_sel : in std_logic;
        MEM_WrEn : in std_logic;
        Byte_sel : in std_logic;
        RF_B_sel : in std_logic;
        RF_WrData_sel : in std_logic;
        RF_WrEn: in std_logic;
        PC_sel : in std_logic_vector(1 downto 0);
        PC_LdEn : in std_logic;
        CTRL_in : in std_logic_vector(1 downto 0);
        RST : in std_logic;
        CLK : in std_logic
     );
end component;

component Controller is
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
end component;

        signal Instr :  std_logic_vector(31 downto 0);
        signal ALU_func :  std_logic_vector(3 downto 0);
        signal ALU_Bin_sel : std_logic;
        signal MEM_WrEn : std_logic;
        signal Byte_sel : std_logic;
        signal RF_B_sel : std_logic;
        signal RF_WrData_sel : std_logic;
        signal RF_WrEn: std_logic;
        signal PC_sel : std_logic_vector(1 downto 0);
        signal PC_LdEn : std_logic;
        signal CTRL_in : std_logic_vector(1 downto 0);
        
begin

    Controller_inst : Controller
    port map(
        Instr => Instr,
        ALU_func => ALU_func,
        ALU_Bin_sel => ALU_Bin_sel,
        MEM_WrEn => MEM_WrEn,
        Byte_sel => Byte_sel,
        RF_B_sel => RF_B_sel,
        RF_WrData_sel => RF_WrData_sel,
        RF_WrEn => RF_WrEn,
        PC_sel => PC_sel,
        PC_LdEn => PC_LdEn,
        CTRL_in => CTRL_in
    );
    
    Datapath_inst : Datapath
    port map(
        Instr => Instr,
        ALU_func => ALU_func,
        ALU_Bin_sel => ALU_Bin_sel,
        MEM_WrEn => MEM_WrEn,
        Byte_sel => Byte_sel,
        RF_B_sel => RF_B_sel,
        RF_WrData_sel => RF_WrData_sel,
        RF_WrEn => RF_WrEn,
        PC_sel => PC_sel,
        PC_LdEn => PC_LdEn,
        CTRL_in => CTRL_in,
        RST => RST,
        CLK => CLK
    );

end Behavioral;
