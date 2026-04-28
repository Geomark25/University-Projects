library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Pipeline_CPU is
    Port (
        CLK: in std_logic;
        Reset: in std_logic
    );
end Pipeline_CPU;

architecture Behavioral of Pipeline_CPU is

    component Controller is
       Port (
        Instr : in std_logic_vector(31 downto 0);
        output_bus: out std_logic_vector(11 downto 0)
     );
    end component;
    
    component Datapath is
      Port (
      Instr: out std_logic_vector(31 downto 0);
      input_bus: in std_logic_vector(11 downto 0);
      Reset: in std_logic;
      CLK: in std_logic
      );
    end component;    
    
    signal Instr: std_logic_vector(31 downto 0);
    signal in_out_bus: std_logic_vector(11 downto 0);
    
begin

    Controller_inst: Controller
    port map(
        Instr => Instr,
        output_bus => in_out_bus
    );
    
    Datapath_inst: Datapath
    port map(
        Instr => Instr,
        input_bus => in_out_bus,
        Reset => Reset,
        CLK => CLK
    );

end Behavioral;
