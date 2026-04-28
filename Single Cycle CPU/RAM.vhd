library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RAM is
      Port (
        ALU_MEM_Addr : in std_logic_vector(11 downto 0);
        MEM_DataIn : in std_logic_vector(31 downto 0);
        MEM_WrEn : in std_logic;
        Byte_sel : in std_logic;
        MEM_DataOut : out std_logic_vector(31 downto 0);
        CLK : in std_logic  
       );
end RAM; 

architecture Behavioral of RAM is

    component MEM IS
      PORT (
        a : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        clk : IN STD_LOGIC;
        we : IN STD_LOGIC;
        spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END component;
    
    component MUX4 is
     Port (
        Din0 : in std_logic_vector(7 downto 0);
        Din1 : in std_logic_vector(7 downto 0);      
        Din2 : in std_logic_vector(7 downto 0);
        Din3 : in std_logic_vector(7 downto 0);
        sel : in std_logic_vector(1 downto 0);
        output : out std_logic_vector(31 downto 0)
        );
    end component;
    
    component MUX2 is 
        Port ( Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal mem2mux : std_logic_vector(31 downto 0);
    signal mux4mux : std_logic_vector(31 downto 0);
    
begin

    MEM_inst : MEM
    port map(
        clk => CLK,
        we => MEM_WrEn,
        a => ALU_MEM_Addr(11 downto 2),
        d => MEM_DataIn,
        spo => mem2mux
    );
  
    mux_inst : MUX2
    port map(
        Din0 => mem2mux,
        Din1 => mux4mux,
        sel => Byte_sel,
        Dout => MEM_DataOut
    ); 
    
    mux4_inst : MUX4
    port map(
        Din0 => mem2mux(7 downto 0),
        Din1 => mem2mux(15 downto 8),
        Din2 => mem2mux(23 downto 16),
        Din3 => mem2mux(31 downto 24),
        sel => ALU_MEM_Addr(1 downto 0),
        output => mux4mux
    ); 

end Behavioral;
