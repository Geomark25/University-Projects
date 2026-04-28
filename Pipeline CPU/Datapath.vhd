library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Datapath is
      Port (
      Instr: out std_logic_vector(31 downto 0);
      input_bus: in std_logic_vector(11 downto 0);
      Reset: in std_logic;
      CLK: in std_logic
      );
end Datapath;

architecture Behavioral of Datapath is

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
     
     component IF_ID is
        Port ( CLK : in  STD_LOGIC;
               WE : in  STD_LOGIC;
               RST : in  STD_LOGIC;
               Data : in  STD_LOGIC_VECTOR (31 downto 0);
               Dout : out  STD_LOGIC_VECTOR (31 downto 0)
               );
        end component;
        
       
      component DEC_Stage is
         Port (
            Instr : in STD_LOGIC_VECTOR(31 downto 0);
            RF_B_sel : in STD_LOGIC;
            RF_WrEn : in std_logic;
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
     
     component ID_EX is
        Port ( CLK : in  STD_LOGIC;
               WE : in  STD_LOGIC;
               RST : in  STD_LOGIC;
               Data : in  STD_LOGIC_VECTOR (119 downto 0);
               Dout : out  STD_LOGIC_VECTOR (119 downto 0));
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
        
        component EX_MEM is
            Port ( CLK : in  STD_LOGIC;
                   WE : in  STD_LOGIC;
                   RST : in  STD_LOGIC;
                   Data : in  STD_LOGIC_VECTOR (72 downto 0);
                   Dout : out  STD_LOGIC_VECTOR (72 downto 0));
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
        
        component MEM_WB is
            Port ( CLK : in  STD_LOGIC;
                   WE : in  STD_LOGIC;
                   RST : in  STD_LOGIC;
                   Data : in  STD_LOGIC_VECTOR (70 downto 0);
                   Dout : out  STD_LOGIC_VECTOR (70 downto 0));
        end component;
        
        component ForwardingUnit is
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
        end component;
        
        component MUX2 is
            Port ( Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
                   Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
                   sel : in  STD_LOGIC;
                   Dout : out  STD_LOGIC_VECTOR (31 downto 0));
        end component;
        
        component MUX3 is
            Port (
                R: in std_logic_vector(31 downto 0);
                EX_R: in std_logic_vector(31 downto 0);
                WB_R: in std_logic_vector(31 downto 0);
                Forward: in std_logic_vector(1 downto 0);
                output: out std_logic_vector(31 downto 0)
            );
        end component;
        
        component MUX11 is
            Port ( Din0 : in  STD_LOGIC_VECTOR (11 downto 0);
                   sel : in  STD_LOGIC;
                   Dout : out  STD_LOGIC_VECTOR (11 downto 0));
        end component;
        
        component HazardUnit is
            Port (
                ID_EX_Rt: in std_logic_vector(4 downto 0);
                IF_ID_Rs: in std_logic_vector(4 downto 0);
                IF_ID_Rt: in std_logic_vector(4 downto 0);
                ID_EX_MEM_load: in std_logic;
                IF_ID_en: out std_logic;
                PC_LdEn: out std_logic;
                control_en: out std_logic
            );
        end component;

      --Controll Signals
      signal RF_B_Sel: std_logic;
      signal CTRL_in: std_logic_vector(1 downto 0);
      signal WB_bus: std_logic_vector(1 downto 0);
      signal M_bus: std_logic_vector(1 downto 0);
      signal EXEC_bus: std_logic_vector(4 downto 0);
      signal control_bus: std_logic_vector(11 downto 0);
      
      --Hazard Signals
      signal PC_LdEn: std_logic;
      signal IF_ID_en: std_logic;
      signal control_en: std_logic;
        
      --IF/ID Signals
      signal Data_IF_ID: STD_LOGIC_VECTOR(31 downto 0);
      signal Dout_IF_ID: STD_LOGIC_VECTOR(31 downto 0);
      
      --ID/EX Signals
      signal Data_ID_EX: std_logic_vector(119 downto 0);
      signal Dout_ID_EX: std_logic_vector(119 downto 0);
      
      --EX/MEM Signals
      signal Data_EX_MEM: std_logic_vector(72 downto 0);
      signal Dout_EX_MEM: std_logic_vector(72 downto 0);
      
      
      --MEM/WB Signals
      signal Data_MEM_WB: std_logic_vector(70 downto 0);
      signal Dout_MEM_WB: std_logic_Vector(70 downto 0);
      signal mux_registers: std_logic_vector(31 downto 0);
      
      --Forward Signals
      signal ForwardA: std_logic_vector(1 downto 0);
      signal ForwardB: std_logic_vector(1 downto 0);
      signal Mux_ALU_A: std_logic_vector(31 downto 0);
      signal Mux_ALU_B: std_logic_vector(31 downto 0);
      
begin

        --IF STAGE
        IF_Stage_inst: IF_Stage
        port map(
            PC_Immed => x"00000000",
            PC_Sel => '0',
            PC_LdEn => PC_LdEn,
            Reset => Reset,
            CLK => CLK,
            Instr => Data_IF_ID
        );
        
        Instr <= Dout_IF_ID;
        
        IF_ID_reg: IF_ID
            port map(
                CLK => CLK,
                Rst => Reset,
                WE => IF_ID_en,
                Data => Data_IF_ID,
                Dout => Dout_IF_ID        
            );
           
         --DEC STAGE
         DEC_Stage_inst: DEC_Stage
         port map(
            Instr => Dout_IF_ID,
            RF_B_Sel => RF_B_Sel,
            RF_WrEn => Dout_MEM_WB(69),
            RF_WrData_sel => '0', --Dout_MEM_WB(70)
            ALU_out => mux_registers,
            MEM_out => x"00000000",
            CTRL_in => CTRL_in,
            Immed => Data_ID_EX(46 downto 15),
            RF_A => Data_ID_EX(110 downto 79),
            RF_B => Data_ID_EX(78 downto 47),
            RST => Reset,
            CLK => CLK
         );
        
        ID_EX_reg: ID_EX
        port map(
               CLK => CLK,
               WE => '1',
               RST => Reset,
               Data => Data_ID_EX,               
               Dout => Dout_ID_EX
        );
        
        Data_ID_EX(119 downto 118) <= WB_bus;
        Data_ID_EX(117 downto 116) <= M_bus;
        Data_ID_EX(115 downto 111) <= EXEC_bus;
        Data_ID_EX(14 downto 10) <= Dout_IF_ID(25 downto 21);
        Data_ID_EX(9 downto 5) <= Dout_IF_ID(15 downto 11);
        Data_ID_EX(4 downto 0) <= Dout_IF_ID(20 downto 16);
        
        --EXEC STAGE
        Full_ALU_inst: Full_ALU
        port map(
            RF_A => Mux_ALU_A,
            RF_B => Mux_ALU_B,
            Immed => Dout_ID_EX(36 downto 5),
            ALU_Bin_Sel => Dout_ID_EX(101),
            ALU_Func => Dout_ID_EX(105 downto 102),
            Zero => open,
            ALU_out => Data_EX_MEM(68 downto 37)
        );
        
        EX_MEM_reg: EX_MEM
        port map(
            CLK => CLK,
            WE => '1',
            RST => Reset,
            Data => Data_EX_MEM,
            Dout => Dout_EX_MEM
        );
        
        Data_EX_MEM(72 downto 71) <= Dout_ID_EX(109 downto 108); --WB bits
        Data_EX_MEM(70 downto 69) <= Dout_ID_EX(107 downto 106); --MEM bits
        Data_EX_MEM(36 downto 5) <= Mux_ALU_B(31 downto 0);
        Data_EX_MEM(4 downto 0) <= Dout_ID_EX(4 downto 0);
        
        --MEM STAGE
        Ram_inst: RAM
        port map(
            ALU_MEM_Addr => Dout_EX_MEM(48 downto 37),
            MEM_DataIn => Dout_EX_MEM(36 downto 5),
            MEM_WrEn => Dout_EX_MEM(69),
            Byte_sel => Dout_EX_MEM(70),
            MEM_DataOut => Data_MEM_WB(68 downto 37),
            CLK => CLK
        );
        
        Data_MEM_WB(70 downto 69) <= Dout_EX_MEM(72 downto 71);
        Data_MEM_WB(36 downto 5) <= Dout_EX_MEM(68 downto 37);
        Data_MEM_WB(4 downto 0) <= Dout_EX_MEM(4 downto 0);
        
        MEM_WB_reg: MEM_WB
        port map(
            CLK => CLK,
            WE => '1',
            RST => Reset,
            Data => Data_MEM_WB,
            Dout => Dout_MEM_WB
        );
        
        ForwardingUnit_inst: ForwardingUnit
        port map(
                EX_WrEn => Dout_EX_MEM(71),
                WB_WrEn => Dout_MEM_WB(69),
                EX_Rd => Dout_EX_MEM(4 downto 0),
                WB_Rd => Dout_MEM_WB(4 downto 0),
                ID_Rs => Dout_ID_EX(14 downto 10),
                ID_Rt => Dout_ID_EX(9 downto 5),
                ForwardA => ForwardA,
                ForwardB => ForwardB
        );
         
        MUX2_inst: MUX2
        port map(
            Din0 => Dout_MEM_WB(36 downto 5),
            Din1 => Dout_MEM_WB(68 downto 37),
            sel => Dout_MEM_WB(70),
            Dout => mux_registers
        );       
        
        ForwardA_mux: MUX3
        port map(
                R => Dout_ID_EX(100 downto 69),
                EX_R => Dout_EX_MEM(68 downto 37),
                WB_R => mux_registers,
                Forward => ForwardA,
                output => Mux_ALU_A
        );
        
        ForwardB_mux: MUX3
        port map(
                R => Dout_ID_EX(68 downto 37),
                EX_R => Dout_EX_MEM(68 downto 37),
                WB_R => mux_registers,
                Forward => ForwardB,
                output => Mux_ALU_B
        );
        
        Control_MUX: MUX11
        port map(
            Din0 => input_bus,
            sel => control_en,
            Dout => control_bus
        );
        
        HazardUnit_inst: HazardUnit
        port map(
            ID_EX_Rt => Dout_ID_EX(4 downto 0),
            IF_ID_Rs => Dout_IF_ID(25 downto 21),
            IF_ID_Rt => Dout_IF_ID(15 downto 11),
            ID_EX_MEM_load => Data_ID_EX(117),
            IF_ID_en => IF_ID_en,
            PC_LdEn => PC_LdEn,
            control_en => control_en
        );
        
        WB_bus <= control_bus(11 downto 10);
        M_Bus <= control_bus(9 downto 8);
        EXEC_Bus <= control_bus(7 downto 3);
        RF_B_sel <= control_bus(2);
        CTRL_in <= control_bus(1 downto 0);
        
end Behavioral;

--Controller inputs template
--output_bus(11) <= RF_WrData_sel;
--output_bus(10) <= RF_WrEn;
--output_bus(9) <= MEM_WrEn;
--output_bus(8) <= Byte_sel;
--output_bus(7 downto 4) <= ALU_func;
--output_bus(3) <= ALU_Bin_sel;
--output_bus(2) <= RF_B_Sel;
--output_bus(1 downto 0) <= CTRL_in;
