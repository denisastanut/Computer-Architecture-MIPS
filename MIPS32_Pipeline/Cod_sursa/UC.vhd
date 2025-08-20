library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Br_gez : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(1 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end UC;

architecture Behavioral of UC is

begin

    process(Instr)
    begin
        RegDst <= '0';
        ExtOp <= '0';
        ALUSrc <= '0';
        Branch <= '0';
        Br_gez <= '0';
        Jump <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        ALUOp <= "00";
        
        case Instr is
            when "000000" =>
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "10";
            when "001000" =>
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
            when "100011" =>
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
            when "101011" =>
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "00";
            when "000100" =>
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "01";
            when "000001" =>
                ExtOp <= '1';
                Br_gez <= '1';
                ALUOp <= "01";
            when "001100" =>
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "11";
            when "000010" =>
                Jump <= '1';
            when others => NULL;
        end case;
    end process;

end Behavioral;