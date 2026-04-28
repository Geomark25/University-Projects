library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DEC_Stage is
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
end DEC_Stage;

architecture Structural of DEC_Stage is
    
    component RegisterFile is
    Port ( Ard1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Ard2 : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           Dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           Din : in  STD_LOGIC_VECTOR (31 downto 0);
           WrEn : in  STD_LOGIC;
		   RST : in STD_LOGIC;
           CLK : in  STD_LOGIC);
    end component;
    
    component MUX2 is
    Port ( Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component MUX5 is
    Port ( Din0 : in  STD_LOGIC_VECTOR (4 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (4 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (4 downto 0));
    end component;
    
    component ImmedConverter is
    Port ( CTRL_in : in STD_LOGIC_VECTOR (1 downto 0);
			  input : in  STD_LOGIC_VECTOR (15 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal read_mux : std_logic_vector (4 downto 0);
    signal write_mux : std_logic_vector (31 downto 0);

begin

    RegisterFile_inst: RegisterFile
    port map(
        Ard1 => Instr(25 downto 21),
        Ard2 => read_mux,
        Awr => Instr(20 downto 16),
        Dout1 => RF_A,
        Dout2 => RF_B,
        Din => write_mux,
        WrEn => WrEn,
        RST => RST,
        CLK => CLK
    );
    
    read_mux_inst : MUX5
    port map(
        Din0 => Instr(15 downto 11),
        Din1 => Instr(20 downto 16),
        sel => RF_B_sel,
        Dout => read_mux
    );
    
    write_mux_inst : MUX2
    port map(
        Din0 => ALU_out,
        Din1 => MEM_out,
        sel => RF_WrData_sel,
        Dout => write_mux
    );
    
    ImmedConverter_inst : ImmedConverter
    port map(
        CTRL_in => CTRL_in,
        input => Instr(15 downto 0),
        output => Immed
    );

end Structural;
