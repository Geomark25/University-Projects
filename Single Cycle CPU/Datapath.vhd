library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Datapath is
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
end Datapath;

architecture Behavioral of Datapath is

     component DEC_Stage is
     Port (
        Instr : in STD_LOGIC_VECTOR(31 downto 0);
        RF_B_sel : in STD_LOGIC;
        WrEn : in std_logic;
        RF_WrData_sel : in std_logic;
        ALU_out : in std_logic_vector(31 downto 0);
        MEM_out : in std_logic_vector(31 downto 0);
        CTRL_in : in std_logic_vector(1 downto 0);
        Immed : out std_logic_vector(31 downto 0);
        RF_A : out std_logic_vector(31 downto 0);
        RF_B : out std_logic_vector(31 downto 0);
        RST : in std_logic;
        CLK : in std_logic
      );
    end component;
    
    component IF_Stage is
     Port ( 
        PC_Immed : in std_logic_vector (31 downto 0);
        PC_Sel : in std_logic ;
        PC_LdEn : in std_logic ;
        Reset : in std_logic ;
        CLK : in std_logic ;
        Instr : out std_logic_vector (31 downto 0)
     );
    end component;
    
    component Full_ALU is
    Port ( RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_Bin_Sel : in  STD_LOGIC;
           ALU_Func : in  STD_LOGIC_VECTOR(3 downto 0);
           Zero : out std_logic;
           ALU_out : out  STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component RAM is
      Port (
        ALU_MEM_Addr : in std_logic_vector(11 downto 0);
        MEM_DataIn : in std_logic_vector(31 downto 0);
        MEM_WrEn : in std_logic;
        Byte_sel : in std_logic;
        MEM_DataOut : out std_logic_vector(31 downto 0);
        CLK : in std_logic  
       );
    end component;
    
    component PC_selector is
    Port (
        PC_sel : in std_logic_vector(1 downto 0);
        zero : in std_logic;
        PC_sel_out : out std_logic
    );
    end component;
    
    signal RF_A : std_logic_vector(31 downto 0);
    signal RF_B : std_logic_vector(31 downto 0);
    signal Immed : std_logic_Vector(31 downto 0);
    signal ALU_out : std_logic_Vector(31 downto 0);
    signal Instruction : std_logic_Vector(31 downto 0);
    signal MEM_out : std_logic_vector(31 downto 0);
    signal PC_sel_sig : std_logic;
    signal zero_sig : std_logic;
    
begin

    DEC_Stage_inst: DEC_Stage
        port map (
            Instr         => Instruction,
            RF_B_sel      => RF_B_sel,
            WrEn          => RF_WrEn,
            RF_WrData_sel => RF_WrData_sel,
            ALU_out       => ALU_out,
            MEM_out       => MEM_out,
            CTRL_in       => CTRL_in,
            Immed         => Immed,
            RF_A          => RF_A,
            RF_B          => RF_B,
            RST           => RST,
            CLK           => CLK
        );

    IF_stage_inst : IF_Stage
        port map (
            PC_Immed => Immed,
            PC_Sel   => PC_sel_sig,
            PC_LdEn  => PC_LdEn,
            Reset    => RST,
            CLK      => CLK,
            Instr    => Instruction
        );
    
    Full_ALU_inst : Full_ALU
        port map (
            RF_A        => RF_A,
            RF_B        => RF_B,
            Immed       => Immed,
            ALU_Bin_Sel => ALU_Bin_sel,
            ALU_Func    => ALU_Func,
            ALU_out     => ALU_out,
            Zero => zero_sig
        );
    
    RAM_Inst : RAM
        port map (
            ALU_MEM_Addr => ALU_out(11 downto 0),
            MEM_DataIn   => RF_B,
            MEM_WrEn     => MEM_WrEn,
            Byte_sel     => Byte_sel,
            MEM_DataOut  => MEM_out,
            CLK          => CLK
        );
        
    PC_selector_inst : PC_selector
        Port map(
           PC_sel => PC_sel,
           zero => zero_sig,
           PC_sel_out => PC_sel_sig
        );
        
    Instr <= Instruction;
    
end Behavioral;
