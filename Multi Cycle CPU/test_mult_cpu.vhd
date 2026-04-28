library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity CPU_tb is
end;

architecture bench of CPU_tb is

  component CPU
      Port ( RST : in STD_LOGIC;
             CLK : in STD_LOGIC);
  end component;

  signal RST: STD_LOGIC;
  signal CLK: STD_LOGIC;

begin

  uut: CPU port map ( RST => RST,
                      CLK => CLK );

  clock: process
  begin
  CLK <= '0';
  wait for 10 ns;
  CLK <= '1';
  wait for 10 ns;
  end process;
  
  stimulus: process
  begin

    RST <= '1';
    wait for 40 ns;
    RST <= '0';

    wait;
  end process;


end;