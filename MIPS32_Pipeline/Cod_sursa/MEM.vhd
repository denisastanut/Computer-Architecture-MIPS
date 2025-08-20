library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALURes_in : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALURes_out : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is
    type mem_array is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    signal MEM : mem_array := (
        0 => X"00000005", --X = 5
        1 => X"00000003", --Y = 3
        2 => X"00000000", --aici se va stoca rezultatul
        others => X"00000000");
    
begin

    process(clk) 			
    begin
        if rising_edge(clk) then
            if en = '1' and MemWrite = '1' then
                MEM(conv_integer(ALURes_in(7 downto 2))) <= RD2;			
            end if;
        end if;
    end process;

    MemData <= MEM(conv_integer(ALURes_in(7 downto 2)));
    ALURes_out <= ALURes_in;

end Behavioral;