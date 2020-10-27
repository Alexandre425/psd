library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.common.all;

entity alu is
    port(
        operand1, operand2 : in signed (15 downto 0);  -- Operands
        operator : in alu_operation;                   -- Operator
        result : out signed (15 downto 0)              -- Result of operation
    );
end alu;

architecture Behavioral of alu is
    signal add_out, sub_out : signed (15 downto 0);       -- Arith outputs
begin
           
    -- Add
    add_out <= operand1 + operand2;
    -- Sub
    sub_out <= operand1 - operand2;
    
    -- Output multiplexing
    with operator select
        result <=
            add_out   when ALU_ADD,
            sub_out   when ALU_SUB, 
            X"00"                       when others;    
    
end Behavioral;
