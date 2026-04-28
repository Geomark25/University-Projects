library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IF_Stage is
     Port ( 
        PC_Immed : in std_logic_vector (31 downto 0);
        PC_Sel : in std_logic ;
        PC_LdEn : in std_logic ;
        Reset : in std_logic ;
        CLK : in std_logic ;
        Instr : out std_logic_vector (31 downto 0)
     );
end IF_Stage;

architecture Structural of IF_Stage is
    
    Component MUX2 is
    Port ( Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    Component RegisterBlock is
    Port ( CLK : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
    end Component;
    
    COMPONENT IMEM
    PORT (a : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
          spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;
    
    Component Incrementor is
    Port ( PC_in : in STD_LOGIC_VECTOR (31 downto 0);
           PC_immed : in STD_LOGIC_VECTOR (31 downto 0);
           Incr : out STD_LOGIC_VECTOR (31 downto 0);
           Incr_immed : out STD_LOGIC_VECTOR (31 downto 0));
    end Component;
    
    signal MUX2_to_PC : STD_LOGIC_VECTOR(31 downto 0);
    signal PC_out : STD_LOGIC_VECTOR(31 downto 0);
    signal Incr_to_MUX2 : STD_LOGIC_VECTOR(31 downto 0);
    signal Incr_to_MUX2_Immed : STD_LOGIC_VECTOR(31 downto 0); 
    
begin
    
	mux : MUX2
		port map(
		    Din0 => Incr_to_MUX2,
		    Din1 => Incr_to_MUX2_Immed,
		    sel => PC_sel,
			Dout => MUX2_to_PC
		);
	
	PC : RegisterBlock
		port map (
            CLK => CLK,
            WE => PC_LdEn,
            RST => Reset,
            Data => MUX2_to_PC,
            Dout => PC_out
            );
    
	ROM : IMEM
        port map(
            a => PC_out(11 downto 2),
            spo => Instr
            );
    
    Incr : Incrementor
        Port map( 
            PC_in => PC_out,
            PC_immed => PC_Immed,
            Incr => Incr_to_MUX2,
            Incr_immed => Incr_to_MUX2_Immed
            );

end Structural;
