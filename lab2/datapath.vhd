library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity datapath is
    port( 
        alu1_op : in alu_operation ; --Seleção da operação a realizar na ALU 1
        alu2_op : in alu_operation ; --Seleção da operação a realizar na ALU 2
        enable : in std_logic_vector (1 downto 0);  -- Enable signals of the registers
        clk, rst: in std_logic; --Clock, reset
        res : out std_logic_vector (15 downto 0) -- Results (data in (15:8) and R2 (7:0))
    ); 
end datapath;

architecture behavioral of datapath is
    signal r1_out, r2_out, alu1mux_out, r4_out : signed(15 downto 0);  -- Outputs of the registers
    signal alu1_out, alu2_out : signed(15 downto 0);
    -- Instância da alu
    component alu
        port(
            operand1, operand2 : in signed (15 downto 0);
            operator : in alu_operation;
            result : out signed (15 downto 0)
            );
    end component;
    
               -- ACRESCENTAR REGISTOS--
                
begin
    alu1 : alu port map(    -- Mapping the ports of the ALU1 instance to the signals
        operand1 => alu1mux_out,
        operand2 => r4_out,
        operator => alu1_op,
        result => alu1_out);
        
    alu2 : alu port map(    -- Mapping the ports of the ALU2 instance to the signals
        operand1 => r1_out,
        operand2 => r2_out,
        operator => alu2_op,
        result => alu2_out);
        
        
end behavioral;