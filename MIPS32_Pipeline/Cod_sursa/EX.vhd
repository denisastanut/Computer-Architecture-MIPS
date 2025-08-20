library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           ALUSrc : in STD_LOGIC;
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           PC_plus_4 : in STD_LOGIC_VECTOR (31 downto 0);
           rt : in STD_LOGIC_VECTOR (4 downto 0);
           rd : in STD_LOGIC_VECTOR (4 downto 0);
           RegDst : in STD_LOGIC;
           Gez : out STD_LOGIC;
           Zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
           rWA : out STD_LOGIC_VECTOR (4 downto 0));
end EX;

architecture Behavioral of EX is

    signal a, b, c : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    
begin
   
    process(ALUOp, func)
    begin
        case ALUOp is
            when "10" =>
                case func is
                    when "100000" => ALUCtrl <= "000";  -- ADD
                    when "100010" => ALUCtrl <= "100";  -- SUB
                    when "000000" => ALUCtrl <= "011";  -- SLL
                    when "000010" => ALUCtrl <= "101";  -- SRL
                    when "100100" => ALUCtrl <= "001";  -- AND
                    when "100101" => ALUCtrl <= "010";  -- OR
                    when "000011" => ALUCtrl <= "110";  -- SRA
                    when "000100" => ALUCtrl <= "111";  -- SLLV
                    when others   => ALUCtrl <= (others => '0');
                end case;
            when "00" => ALUCtrl <= "000"; --adunare
            when "01" => ALUCtrl <= "100"; --scadere
            when "11" => ALUCtrl <= "001"; --and
            when others => ALUCtrl <= (others => '0');
        end case;
    end process;
    
    a <= RD1;
    b <= RD2 when ALUSrc = '0' else Ext_Imm;
    
    process(a, b, ALUCtrl, sa)
    begin
        case ALUCtrl is
            when "000" => c <= a + b; -- ADD
            when "100" => c <= a - b; -- SUB
            when "011" => c <= to_stdlogicvector(to_bitvector(b) sll conv_integer(sa)); -- SLL
            when "101" => c <= to_stdlogicvector(to_bitvector(b) srl conv_integer(sa)); -- SRL
            when "001" => c <= a and b; -- AND
            when "010" => c <= a or b; -- OR
            when "110" => c <= to_stdlogicvector(to_bitvector(b) sra conv_integer(sa)); -- SRA
            when "111" => c <= to_stdlogicvector(to_bitvector(b) sll conv_integer(a)); -- SLLV
            when others => c <= (others => '0');
        end case;
    end process;
    
    BranchAddress <= PC_plus_4 + (Ext_Imm(29 downto 0) & "00");
    
    ALURes <= c;
    Zero <= '1' when c = X"00000000" else '0';
    Gez <= not c(31);
    
    rWA <= rt when RegDst = '0' else rd;
    
end Behavioral;