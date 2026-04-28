library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.pkg.all;

entity Registerfile is
    Port ( Ard1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Ard2 : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
           Dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           Dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           Din : in  STD_LOGIC_VECTOR (31 downto 0);
           WrEn : in  STD_LOGIC;
		   RST : in STD_LOGIC;
           CLK : in  STD_LOGIC);
end Registerfile;

architecture Structural of Registerfile is
	
	component RegisterBlock is
		Port(
		   CLK : in  STD_LOGIC;
           WE : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (31 downto 0);
           Dout : out  STD_LOGIC_VECTOR (31 downto 0)
		);
		end component;
		
	component And_gate is
		Port(
			A : in STD_LOGIC;
			B : in STD_LOGIC;
			C : out STD_LOGIC
		);
		end component;
	
	component MUX32 is
		Port(
			input : in vector_array(0 to 31);
			output : out STD_LOGIC_VECTOR(31 downto 0);
			sel : in STD_LOGIC_VECTOR(4 downto 0)
		);
		end component; 
		
	component MUX2 is
		Port ( 
		   Din0 : in  STD_LOGIC_VECTOR (31 downto 0);
           Din1 : in  STD_LOGIC_VECTOR (31 downto 0);
           sel : in  STD_LOGIC;
           Dout : out  STD_LOGIC_VECTOR (31 downto 0)
		);
		end component;
		
	component Decoder is
		Port ( 
		      input : in  STD_LOGIC_VECTOR (4 downto 0);
			  output : out STD_LOGIC_VECTOR(31 downto 0)
		);
		end component;
	
	component CompareModule is
		Port ( 
		   Ard : in  STD_LOGIC_VECTOR (4 downto 0);
           Awr : in  STD_LOGIC_VECTOR (4 downto 0);
		   WrEn : in STD_LOGIC;
           output : out  STD_LOGIC
		);
		end component;
		
	signal and_to_register : STD_LOGIC_VECTOR(31 downto 0);
	signal dec_to_and : STD_LOGIC_VECTOR(31 downto 0);
	signal comp_to_mux : STD_LOGIC_VECTOR(1 downto 0);
	
	signal arrayBus : vector_array(0 to 31);
	
	type t_mux2mux is array(0 to 1) of STD_LOGIC_VECTOR(31 downto 0);
	signal mux32_to_mux2 : t_mux2mux;
	
	begin
	
	R0 : RegisterBlock
		port map(
			CLK => CLK,
			WE => and_to_register(0),
			RST => RST,
			Data => x"00000000",
			Dout => arrayBus(0)
		);
	
	register_instantiation : for i in 1 to 31 generate
	registers : RegisterBlock
		port map(
			CLK => CLK,
			WE => and_to_register(i),
			RST => RST,
			Data => Din,
			Dout => arrayBus(i)
		);
	end generate register_instantiation;
		
	andGate_Instantiation : for i in 0 to 31 generate
	and_gates : And_gate
		port map(
			A => WrEn,
			B => dec_to_and(i),
			C => and_to_register(i)
		);
	end generate andGate_Instantiation;
	
	MUX32_1 : MUX32
		port map(
			input => arrayBus,
			output => mux32_to_mux2(0),
			sel => Ard1
		);
		
	MUX32_2 : MUX32
		port map(
			input => arrayBus,
			output => mux32_to_mux2(1),
			sel => Ard2
		);
		
	MUX2_1 : MUX2
		port map(
		 Din0 => mux32_to_mux2(0),
         Din1 => Din,
         sel => comp_to_mux(0),
         Dout => Dout1
		);
		
	MUX2_2 : MUX2
		port map(
		 Din0 => mux32_to_mux2(1),
         Din1 => Din,
         sel => comp_to_mux(1),
         Dout => Dout2
		);
		
	Compare_1 : CompareModule
		port map(
			Ard => Ard1,
			Awr => Awr,
			WrEn => WrEn,
			output => comp_to_mux(0)
		);
	
	Compare_2 : CompareModule
		port map(
			Ard => Ard2,
			Awr => Awr,
			WrEn => WrEn,
			output => comp_to_mux(1)
		);
		
	Decoder_instantiation : Decoder
		port map(
			input => Awr,
			output => dec_to_and
		);
end Structural;
