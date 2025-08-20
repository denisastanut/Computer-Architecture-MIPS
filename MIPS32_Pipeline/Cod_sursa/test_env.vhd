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
    signal en, rst : STD_LOGIC;
    
    -- SSD
    signal digits : STD_LOGIC_VECTOR (31 downto 0);
    
    -- Instruction Fetch
    signal instruction, pc_plus_4 : STD_LOGIC_VECTOR (31 downto 0);
    signal jump_adr, branch_adr : STD_LOGIC_VECTOR (31 downto 0);
    signal jump_id, pcsrc : STD_LOGIC;

    -- Main Control
    signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWr, Mem2R, RegWr, Br_gez : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR (1 downto 0);
    
    -- Instruction Decode
    signal rd1, rd2, ext_imm : STD_LOGIC_VECTOR(31 downto 0);
    signal rt, rd, sa : STD_LOGIC_VECTOR(4 downto 0);
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    
    -- Execute
    signal zero, gez : STD_LOGIC;
    signal ALURes : STD_LOGIC_VECTOR(31 downto 0);
    signal br_adr : STD_LOGIC_VECTOR(31 downto 0);
    signal rWA : STD_LOGIC_VECTOR(4 downto 0);
    signal wa_ex : STD_LOGIC_VECTOR(4 downto 0);
    
    -- Memory
    signal dataMem : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResOut : STD_LOGIC_VECTOR(31 downto 0);

    signal writeData : STD_LOGIC_VECTOR(31 downto 0);

    
    -- Registre pipeline
    -- IF/ID
    signal PCp4_IF_ID : STD_LOGIC_VECTOR (31 downto 0);
    signal Instruction_IF_ID : STD_LOGIC_VECTOR (31 downto 0);
    
    -- ID/EX
    signal RegDst_ID_EX, AluSrc_ID_EX, Branch_ID_EX, Br_gez_ID_EX, MemWr_ID_EX, Mem2R_ID_EX, RegWr_ID_EX : STD_LOGIC;
    signal ALUOp_ID_EX : STD_LOGIC_VECTOR (1 downto 0);
    signal PCp4_ID_EX, RD1_ID_EX, RD2_ID_EX, Ext_Imm_ID_EX : STD_LOGIC_VECTOR(31 downto 0);
    signal rt_ID_EX, rd_ID_EX, sa_ID_EX : STD_LOGIC_VECTOR(4 downto 0);
    signal func_ID_EX : STD_LOGIC_VECTOR(5 downto 0);
    
    -- EX/MEM
    signal Branch_EX_MEM, MemWr_EX_MEM, Mem2R_EX_MEM, RegWr_EX_MEM, Zero_EX_MEM, Gez_EX_MEM, Br_gez_EX_MEM : STD_LOGIC;
    signal ALURes_EX_MEM, RD2_EX_MEM, BrAddr_EX_MEM : STD_LOGIC_VECTOR(31 downto 0);
    signal WA_EX_MEM : STD_LOGIC_VECTOR(4 downto 0);
    
    -- MEM/WB
    signal Mem2R_MEM_WB, RegWr_MEM_WB : STD_LOGIC;
    signal MemData_MEM_WB, ALURes_MEM_WB : STD_LOGIC_VECTOR(31 downto 0);
    signal WA_MEM_WB : STD_LOGIC_VECTOR(4 downto 0); 
   
   
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
           WA : in STD_LOGIC_VECTOR (4 downto 0);
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           RegWrite : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           rt : out STD_LOGIC_VECTOR (4 downto 0);
           rd : out STD_LOGIC_VECTOR (4 downto 0));
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
           rt : in STD_LOGIC_VECTOR (4 downto 0);
           rd : in STD_LOGIC_VECTOR (4 downto 0);
           RegDst : in STD_LOGIC;
           Gez : out STD_LOGIC;
           Zero : out STD_LOGIC;
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
           rWA : out STD_LOGIC_VECTOR (4 downto 0));
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

    mpg1 : MPG port map(en, btn(0), clk);
    
    jump_adr <= PCp4_IF_ID(31 downto 28) & instruction_IF_ID(25 downto 0) & "00";
    
    pcsrc <= (Zero_EX_MEM and Branch_EX_MEM) or (Gez_EX_MEM and Br_gez_EX_MEM);
    
    IF_portmap : IFetch port map(
        en => en, 
        rst => btn(1), 
        clk => clk, 
        Jump => jump_id, 
        JumpAddress => jump_adr, 
        PCSrc => pcsrc, 
        BranchAddress => BrAddr_EX_MEM, 
        Instruction => instruction, 
        PC_plus4 => pc_plus_4);
    
    
    UC_portmap : UC port map(
        Instr => Instruction_IF_ID(31 downto 26), 
        RegDst => RegDst, 
        ExtOp => ExtOp, 
        ALUSrc => ALUSrc, 
        Branch => Branch, 
        Br_gez => Br_gez, 
        Jump => jump_id, 
        ALUOp => ALUOp, 
        MemWrite => MemWr, 
        MemtoReg => Mem2R, 
        RegWrite => RegWr);
    
    ID_portmap : ID port map(
        en => en, 
        Instr => Instruction_IF_ID(25 downto 0), 
        WA => WA_MEM_WB, 
        ExtOp => ExtOp, 
        WD => WriteData, 
        clk => clk, 
        RegWrite => RegWr_MEM_WB, 
        RD1 => rd1, 
        RD2 => rd2, 
        Ext_Imm => ext_imm, 
        func => func, 
        sa => sa,
        rt => rt,
        rd => rd);
    
    
    EX_portmap: EX port map(
        RD1 => RD1_ID_EX, 
        RD2 => RD2_ID_EX, 
        ALUSrc => ALUSrc_ID_EX, 
        Ext_Imm => Ext_Imm_ID_EX, 
        sa => sa_ID_EX, 
        func => func_ID_EX, 
        ALUOp => ALUOp_ID_EX, 
        PC_plus_4 => PCp4_ID_EX, 
        rt => rt_ID_EX,
        rd => rd_ID_EX,
        RegDst => RegDst_ID_EX,
        Gez => gez, 
        Zero => zero, 
        ALURes => ALURes, 
        BranchAddress => branch_adr,
        rWA => rWA);
    
    
    MEM_portmap: MEM port map(
        MemWrite => MemWr_EX_MEM,
        ALURes_in => ALURes_EX_MEM,
        RD2 => RD2_EX_MEM,
        CLK => clk,
        EN => en,
        MemData => dataMem,
        ALURes_out => ALUResOut);

    
    WriteData <= AluRes_MEM_WB when Mem2R_MEM_WB = '0' else MemData_MEM_WB;


    -- Registre pipeline
    process(clk)
    begin
        if rising_edge(clk) then 
            if en = '1' then
            
                -- IF/ID
                PCp4_IF_ID <= pc_plus_4;
                Instruction_IF_ID <= instruction;
                
                -- ID/EX
                RegDst_ID_EX <= RegDst;
                ALUSrc_ID_EX <= ALUSrc;
                Branch_ID_EX <= branch;
                Br_gez_ID_EX <= br_gez;
                ALUOp_ID_EX <= ALUOp;
                MemWr_ID_EX <= MemWr;
                Mem2R_ID_EX <= Mem2R;
                RegWr_ID_EX <= RegWr;
                RD1_ID_EX <= rd1;
                RD2_ID_EX <= rd2;
                Ext_Imm_ID_EX <= ext_imm;
                sa_ID_EX <= sa;
                func_ID_EX <= func;
                rt_ID_EX <= rt;
                rd_ID_EX <= rd;
                PCp4_ID_EX <= PCp4_IF_ID;
                
                -- EX/MEM
                Branch_EX_MEM <= Branch_ID_EX;
                Br_gez_EX_MEM <= Br_gez_ID_EX;
                MemWr_EX_MEM <= MemWr_ID_EX;
                Mem2R_EX_MEM <= Mem2R_ID_EX;
                RegWr_EX_MEM <= RegWr_ID_EX;
                Zero_EX_MEM <= zero;
                Gez_EX_MEM <= gez;
                BrAddr_EX_MEM <= branch_adr;
                ALURes_EX_MEM <= ALURes;
                WA_EX_MEM <= rWA;
                RD2_EX_MEM <= RD2_ID_EX;

                -- MEM/WB
                Mem2R_MEM_WB <= Mem2R_EX_MEM;
                RegWr_MEM_WB <= RegWr_EX_MEM;
                ALURes_MEM_WB <= ALUResOut;
                MemData_MEM_WB <= dataMem;
                WA_MEM_WB <= WA_EX_MEM;
                
            end if;
        end if;
    end process;
    
    
    process(sw(7 downto 5), instruction, pc_plus_4, rd1, rd2, ext_imm, ALURes, dataMem, WriteData)
    begin
        case sw(7 downto 5) is
            when "000" =>
                digits <= instruction;
            when "001" =>
                digits <= pc_plus_4;
            when "010" =>
                digits <= rd1;
            when "011" =>
                digits <= rd2;
            when "100" =>
                digits <= ext_imm;
            when "101" =>
                digits <= ALURes; --EX
            when "110" =>
                digits <= dataMem; --MEM
            when "111" =>
                digits <= WriteData; --ID
            when others =>
                digits <= (others => '0');
        end case;
    end process;

    display : SSD port map(clk, digits, an, cat);
    
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & branch & br_gez & jump & MemWr & Mem2R & RegWr;
    
end Behavioral;