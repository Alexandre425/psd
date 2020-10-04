library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;

entity alu is
    port(
        operand1 : in std_logic_vector (7 downto 0);
        operand2 : in std_logic_vector (7 downto 0);
        operator : in alu_operation;
        result : out std_logic_vector (7 downto 0);
        clk : in std_logic
    );
end alu;

architecture Behavioral of alu is
    type alu_operation is (ALU_ADD, ALU_MULT, ALU_OR, ALU_RTR);
begin
    
end Behavioral;
