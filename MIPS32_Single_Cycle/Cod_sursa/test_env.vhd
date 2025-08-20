library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           sw : in  STD_LOGIC_VECTOR(15 downto 0);
           btn : in  STD_LOGIC_VECTOR(4 downto 0);
           clk : in  STD_LOGIC);
end test_env;

architecture Behavioral of test_env is
    signal en : STD_LOGIC;
    
    signal instr : STD_LOGIC_VECTOR(31 downto 0); -- Instruction IFetch
    signal jump_address : STD_LOGIC_VECTOR(31 downto 0); -- Jump address IFetch
    signal branch_out : STD_LOGIC;  -- PCSrc din IFetch
    signal pc_plus_4 : STD_LOGIC_VECTOR(31 downto 0);
    
    signal digits : STD_LOGIC_VECTOR(31 downto 0); -- intrare SSD
    
    signal Rdst, Eop, Asrc, br, brgez, j, Mwrite, Mreg, Rwrite : STD_LOGIC; -- iesiri UC
    signal Aop : STD_LOGIC_VECTOR(1 downto 0); -- ALUOp din UC
    
    -- iesiri / intrari ID
    signal rd1, rd2 : STD_LOGIC_VECTOR(31 downto 0);
    signal ext_imm : STD_LOGIC_VECTOR(31 downto 0);
    signal func1 : STD_LOGIC_VECTOR(5 downto 0);
    signal sa : STD_LOGIC_VECTOR(4 downto 0);
    signal gez : STD_LOGIC;
    signal z : STD_LOGIC;
    signal branch_adr : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_res : STD_LOGIC_VECTOR(31 downto 0);
    signal wd : STD_LOGIC_VECTOR(31 downto 0);
    
    signal dataMem : STD_LOGIC_VECTOR(31 downto 0); -- iesire MEM
    signal AluOut : STD_LOGIC_VECTOR(31 downto 0); -- iesire MEM
   
    
    component MPG
        Port ( enable : out STD_LOGIC;
               btn : in  STD_LOGIC;
               clk : in  STD_LOGIC);
    end component;
    
    component SSD
        Port ( clk : in STD_LOGIC;
               digits : in STD_LOGIC_VECTOR(31 downto 0);
               an : out STD_LOGIC_VECTOR(7 downto 0);
               cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;
    
    component IFetch is
        Port ( en : in STD_LOGIC;
               rst : in STD_LOGIC;
               clk : in STD_LOGIC;
               Jump : in STD_LOGIC;
               JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
               PCSrc : in STD_LOGIC;
               BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
               Instruction : out STD_LOGIC_VECTOR(31 downto 0);
               PC_plus4 : out STD_LOGIC_VECTOR(31 downto 0));
    end component;
    
    component ID is
    Port ( en : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0));
    end component;
    
    component UC is
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
    end component;
    
    component EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           ALUSrc : in STD_LOGIC;
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
           PC_plus_4 : in STD_LOGIC_VECTOR (31 downto 0);
           GEZ : out STD_LOGIC;
           Zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALURes_in : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALURes_out : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
begin

    monopulse : MPG port map(en, btn(0), clk);
    
    instructionFetch : IFetch port map(
        en => en, 
        rst => btn(1), 
        clk => clk, 
        Jump => j, 
        JumpAddress => jump_address, 
        PCSrc => branch_out, 
        BranchAddress => branch_adr, 
        Instruction => instr, 
        PC_plus4 => pc_plus_4);
    
    
    UC_portmap : UC port map(
        Instr => instr(31 downto 26), 
        RegDst => Rdst, 
        ExtOp => Eop, 
        ALUSrc => Asrc, 
        Branch => br, 
        Br_gez => brgez, 
        Jump => j, 
        ALUOp => Aop, 
        MemWrite => Mwrite, 
        MemtoReg => Mreg, 
        RegWrite => Rwrite);
    
    
    ID_portmap : ID port map(
        en => en, 
        Instr => instr(25 downto 0), 
        RegDst => Rdst, 
        ExtOp => Eop, 
        WD => wd, 
        clk => clk, 
        RegWrite => Rwrite, 
        RD1 => rd1, 
        RD2 => rd2, 
        Ext_Imm => ext_imm, 
        func => func1, 
        sa => sa);
    
    
    EX_portmap: EX port map(
        RD1 => rd1, 
        RD2 => rd2, 
        ALUSrc => Asrc, 
        Ext_Imm => ext_imm, 
        sa => sa, 
        func => func1, 
        ALUOp => Aop, 
        PC_plus_4 => pc_plus_4, 
        GEZ => gez, 
        Zero => z, 
        ALURes => alu_res, 
        BranchAddress => branch_adr);
    
    
    MEM_portmap: MEM port map(
        MemWrite => Mwrite, 
        ALURes_in => alu_res, 
        RD2 => rd2, 
        CLK => clk, 
        EN => en, 
        MemData => dataMem, 
        ALURes_out => AluOut);

    
    process(sw, instr, pc_plus_4, rd1, rd2, ext_imm, alu_res, dataMem, wd)
    begin
        case sw(7 downto 5) is
            when "000" =>
                digits <= instr;
            when "001" =>
                digits <= pc_plus_4;
            when "010" =>
                digits <= rd1;
            when "011" =>
                digits <= rd2;
            when "100" =>
                digits <= ext_Imm;
            when "101" =>
                digits <= alu_res;
            when "110" =>
                digits <= dataMem;
            when "111" =>
                digits <= wd; 
            when others =>
                digits <= (others => '0');
        end case;
    end process;
    
    jump_address <= pc_plus_4(31 downto 28) & instr(25 downto 0) & "00";
    
    branch_out <= (z and br) or (gez and brgez);
    
    wd <= AluOut when Mreg = '0' else dataMem;
    
    led(10 downto 0) <= Aop & Rdst & Eop & Asrc & br & brgez & j & Mwrite & Mreg & Rwrite;
    
    display : SSD port map(clk, digits, an, cat);
    
end Behavioral;