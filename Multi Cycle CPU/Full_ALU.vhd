library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_ALU is
    Port ( RF_A : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : in  STD_LOGIC_VECTOR (31 downto 0);
           Immed : in  STD_LOGIC_VECTOR (31 downto 0);
           ALU_Bin_Sel : in  STD_LOGIC;
           ALU_Func : in  STD_LOGIC_VECTOR(3 downto 0);
           Zero : out std_logic;
           ALU_out : out  STD_LOGIC_VECTOR (31 downto 0));
end Full_ALU;

architecture Structural of Full_ALU is
	
	component ALU is
		port(
			A : in  STD_LOGIC_VECTOR (31 downto 0);
         B : in  STD_LOGIC_VECTOR (31 downto 0);
         Op : in  STD_LOGIC_VECTOR (3 downto 0);
         Output : out  STD_LOGIC_VECTOR (31 downto 0);
         Zero : out  STD_LOGIC;
         Cout : out  STD_LOGIC;
         Ovf : out  STD_LOGIC
		);
	end component;
	
	component MUX2 is
		port(
			Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
         Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
         sel : in  STD_LOGIC;
         Dout : out  STD_LOGIC_VECTOR (31 downto 0)
		);
	end component;
	
	signal mux2alu : STD_LOGIC_VECTOR(31 downto 0);
	
begin

	ALU_comp : ALU
		port map(
			A => RF_A,
			B => mux2alu,
			Op => ALU_Func,
			Output => ALU_out,
			Zero => Zero
		);
		
	Mux2_comp : MUX2
		port map(
			Din0 => RF_B,
			Din1 => Immed,
			sel => ALU_Bin_sel,
			Dout => mux2alu
		);
		
end Structural;
