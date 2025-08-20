library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           Jump : in STD_LOGIC;
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PC_plus4 : out STD_LOGIC_VECTOR(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
    signal pc, next_pc, mux_out : STD_LOGIC_VECTOR(31 downto 0);
    
-- Cerinta problemei:
    -- 17. Sa se calculeze produsul a 2 numere pozitive X (X <= 255) si Y (Y <= 255) citite din
    -- memorie de la adresele 0, respectiv 4. Rezultatul se va scrie in memorie la adresa 8.
    -- Calculul va avea la baza adunari repetate, astfel: se parcurg bitii lui Y de la Y0
    -- la Y7 si daca bitul curent este 1 se aduna la rezultatul final valoarea lui X, deplasata
    -- la stanga cu numarul corespunzator de pozitii.
    
    type rom_array is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal rom : rom_array := (
    B"100011_00000_00010_0000000000000000",   -- X"8C02_0000"   00: LW $2, 0($0)     Incarca X din memorie
    B"100011_00000_00011_0000000000000100",   -- X"8C03_0004"   01: LW $3, 4($0)     Incarca Y din memorie
    B"000000_00000_00000_00100_00000_100000", -- X"0000_2020"   02: ADD $4, $0, $0   Initializeaza rezultatul cu 0
    B"000000_00000_00000_00001_00000_100000", -- X"0000_0820"   03: ADD $1, $0, $0   Initializeaza contorul cu 0
    B"001000_00000_01000_0000000000001000",   -- X"2008_0008"   04: ADDI $8, $0, 8   Salveaza nr maxim de iteratii (8)
    
    B"000100_00001_01000_0000000000000111",   -- X"1028_0007"   05: BEQ $1, $8, 7    Daca i=8 iesim din bucla si sarim la end_loop 
    B"001100_00011_00110_0000000000000001",   -- X"3066_0001"   06: ANDI $6, $3, 1   Verifica ultimul bit al lui Y
    B"000100_00110_00000_0000000000000010",   -- X"10C0_0002"   07: BEQ $6, $0, 2    Daca e 0 nu adunam si sarim la skip_loop (adica trecem peste acel bit)
    B"000000_00001_00010_00111_00000_000100", -- X"0022_3804"   08: SLLV $7, $2, $1  X << i
    B"000000_00100_00111_00100_00000_100000", -- X"0087_2020"   09: ADD $4, $4, $7   R = R + (X << i)
    
    B"000000_00000_00011_00011_00001_000010", -- X"0003_1842"   10: SRL $3, $3, 1    Deplaseaza Y spre dreapta
    B"001000_00001_00001_0000000000000001",   -- X"2021_0001"   11: ADDI $1, $1, 1   Incrementeaza i
    B"000010_00000000000000000000000101",     -- X"0800_0005"   12: J 5              Salt la instructiunea cu index 05 (a 6-a in program)
    
    B"101011_00000_00100_0000000000001000",   -- X"AC04_0008"   13: SW $4, 8($0)     Stocheaza in memorie la adresa 8 valoarea rezultatului 
    
    others => X"00000000");
    
begin

    process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                pc <= next_pc;
            end if;
        end if;
    end process;
    
    
    process(PCSrc, BranchAddress, pc)
    begin
        if PCSrc = '1' then
            mux_out <= BranchAddress;
        else
            mux_out <= pc + 4;
        end if;
    end process;
    
    
    process(Jump, JumpAddress, mux_out)
    begin
        if Jump = '1' then
            next_pc <= JumpAddress;
        else
            next_pc <= mux_out;
        end if;
    end process;
    
    
    Instruction <= rom(conv_integer(pc(6 downto 2)));
    PC_plus4 <= pc + 4;
    
end Behavioral;
