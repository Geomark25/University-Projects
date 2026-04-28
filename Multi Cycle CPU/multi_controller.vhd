library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multi_Controller is
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
        CTRL_in : out std_logic_vector(1 downto 0);
        RST : in std_logic;
        CLK : in std_logic
     );
end multi_Controller;

architecture Behavioral of multi_Controller is

    type controller_state is (Fetch, Decode, Execute, Mem, WB);
    signal state : controller_state;
    
    type exec_state is (ALU_exec, load_exec, immed_exec, cmp_exec, mem_exec);
    signal sub_state: exec_state;
    
begin

    process
    begin
    
    wait until CLK'EVENT and CLK = '1';
    
    if RST = '1' then
        state <= Fetch;
        ALU_func <= (others => '0');
        ALU_Bin_sel <= '0';
        MEM_WrEn <= '0';
        Byte_sel <= '0';
        RF_B_sel <= '0';
        RF_WrData_sel <= '0';
        RF_WrEn <= '0';
        PC_sel <= "00";
        PC_LdEn <= '0';
        CTRL_in <= "00";
    else
    
        case state is
            when Fetch => --Fetch the instruction
            if Instr = x"00000000" then -- IF Nop -> return to Fetch
                    state <= Fetch;
                    PC_LdEn <= '1';
                else
                ALU_func <= (others => '0');
                ALU_Bin_sel <= '0';
                MEM_WrEn <= '0';
                Byte_sel <= '0';
                RF_B_sel <= '0';
                RF_WrData_sel <= '0';
                RF_WrEn <= '0';
                PC_sel <= "00";
                PC_LdEn <= '0';
                CTRL_in <= "00";
                state <= Decode;
                end if;
            when Decode => --Decode instruction
                    ALU_func <= (others => '0');
                    RF_WrEn <= '0';
                    RF_WrData_sel <= '0';
                    RF_B_sel <= '0';
                    Mem_WrEn <= '0';
                    
                    --immed signal
					case Instr(31 downto 26) is
						when "111000" => --zero fill lsb
							CTRL_in <= "01";
						when "110010" | "110011" => --zero fill msb
							CTRL_in <= "10";
						when "111111" | "010000" | "010001" => --sign extend shift
							CTRL_in <= "11";
						when others => --sign extend
							CTRL_in <= "00";
					end case;
					
					case Instr(31 downto 26) is --Change sub execute state
						when "100000" =>
							sub_state <= alu_exec;
							RF_B_sel <= '0';
							ALU_Bin_sel <= '0';
						when "111000" | "111001" =>
							sub_state <= load_exec;
							RF_B_sel <= '0';
							ALU_Bin_sel <= '1';
						when "110000" | "110010" | "110011" =>
							sub_state <= immed_exec;
							RF_B_sel <= '0';
							ALU_Bin_sel <= '1';
						when "010000" | "010001" =>
							sub_state <= cmp_exec;
							RF_B_sel <= '1';
							ALU_Bin_sel <= '0';
						when "000011" | "000111" | "001111" | "011111" =>
							sub_state <= mem_exec;
							RF_B_sel <= '0';
							ALU_Bin_sel <= '1';
						when others =>
						    RF_B_sel <= '0';
						    ALU_Bin_sel <= '0';
					end case;
					
				    if Instr(31 downto 26) = "111111" then
				        state <= Fetch;
				        PC_sel <= "11";
				        PC_LdEn <= '1';
				    else
				        state <= Execute;
				        PC_sel <= "00";
				        PC_LdEn <= '0';
				    end if;
		      when Execute =>
		      
		      RF_WrEn <= '0';
		      RF_WrData_sel <= '0';
			  Mem_WrEn <= '0';

		      
		      	case sub_state is
		          	when alu_exec =>
		              	ALU_func <= Instr(3 downto 0);
		              	PC_LdEn <= '0';
			             PC_sel <= "00";
					  	state <= WB;
					when load_exec =>
						ALU_func <= (others => '0');
						PC_LdEn <= '0';
                         PC_sel <= "00";
                         sub_state <= Alu_exec;
						state <= WB;
					when immed_exec =>
						ALU_func <= Instr(29 downto 26);
						PC_LdEn <= '0';
			             PC_sel <= "00";
			             sub_state <= Alu_exec;
						state <= WB;
					when cmp_exec =>
						ALU_func <= "0001";
						if Instr(26) = '0' then
							PC_sel <= "01";
						else
							PC_sel <= "10";
						end if;
						sub_state <= Alu_exec;
						state <= Fetch;
						PC_LdEn <= '1';
					when mem_exec =>
						ALU_func <= (others => '0');
						PC_LdEn <= '0';
			             PC_sel <= "00";
						state <= Mem;
					when others =>
				end case;
		     when Mem =>
		        ALU_Bin_sel <= '1';
				RF_B_sel <= '1';
                if Instr(31 downto 26) = "000011" or Instr(31 downto 26) = "001111" then
                    state <= WB;
                    Mem_WrEn <= '0';
                    if Instr(28) = '1' then
                        Byte_sel <= '1';
                    else
                        Byte_sel <= '0';
                    end if;
                else
                    state <= Fetch;
                    PC_LdEn <= '1';
                    Mem_WrEn <= '1';
                end if;
		when WB =>
			RF_WrEn <= '1';
			if sub_state = mem_exec then
				RF_WrData_sel <= '1';
				sub_state <= alu_exec;
			else
				RF_WrData_sel <= '0';
				sub_state <= alu_exec;
			end if;
		    state <= Fetch;
		    PC_LdEn <= '1';
		when others =>
	end case;
end if;

end process;
end Behavioral;
