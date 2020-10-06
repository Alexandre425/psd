library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity datapath is
    port( 
        ent : in std_logic_vector (7 downto 0); --Dados de entrada
        slct : in alu_operation; --Seleção da operação a realizar na ALU
        clk, rst, slct_disp, enable: in std_logic; --Clock, reset, seleção de display e enable
        res : out std_logic_vector (7 downto 0) --Dados de entrada e saída do registo 2, ambos sinais a representar no display de 7 segmentos; Saída do registo 2 
        ); 
end datapath;

architecture behavioral of datapath is
    signal r1_out, r2_out : std_logic_vector (7 downto 0);  -- Outputs of the registers
    signal alu_out : std_logic_vector (7 downto 0);
    -- Instância da alu
    component alu
        port(
            operand1, operand2 : in std_logic_vector (7 downto 0);
            operator : in alu_operation;
            result : out std_logic_vector (7 downto 0)
            );
    end component;
    
    --register´s instance
    component reg8
        port(
            clk : in std_logic;                     --clock
            D : in std_logic_vector (7 downto 0);   --register input (load)
            Q : out std_logic_vector (7 downto 0);  --register output (load)
            rst, en_reg8 : in std_logic             --register reset and enable
            );
    end component;
                
begin
    alu_inst : alu port map(    -- Mapping the ports of the ALU instance to the signals
        operand1 => r1_out,
        operand2 => r2_out,
        operator => slct,
        result => alu_out);
    reg1_inst : reg8 port map(  -- Mapping the ports of the register1 instance to the signals
        clk => clk,
        D => ent,
        Q => r1_out,
        rst => rst,
        en_reg8 => enable);
    reg2_inst : reg8 port map(  -- Mapping the ports of the register2 instance to the signals
        clk => clk,
        D => alu_out,
        Q => r2_out,
        rst => rst,
        en_reg8 => enable);
        
    --Display selection
    with slct_disp select
        res <=
                ent when DISP_ENT,
                r2_out when others;
        
end behavioral;