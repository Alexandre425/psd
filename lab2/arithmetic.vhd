library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity alu is
    port(
        operand1, operand2 : in std_logic_vector (31 downto 0);  -- Operands
        operator : in alu_operation;                   -- Operator
        result : out std_logic_vector (31 downto 0)              -- Result of operation
    );
end alu;

architecture Behavioral of alu is
    signal add_out, sub_out : signed (31 downto 0);       -- Arith outputs
begin
           
    -- Add
    add_out <= signed(operand1) + signed(operand2);
    -- Sub
    sub_out <= signed(operand1) - signed(operand2);
    
    -- Output multiplexing
    with operator select
        result <=
            std_logic_vector(add_out)   when ALU_ADD,
            std_logic_vector(sub_out)   when ALU_SUB, 
           	(others => '0')             when others;    
    
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity multiplier is
	port (
        operand1, operand2 : in std_logic_vector (31 downto 0);
        result : out std_logic_vector (31 downto 0)
    );
end multiplier;

architecture arch of multiplier is

signal result64 : std_logic_vector (63 downto 0);

begin
   result64 <= std_logic_vector(signed(operand1) * signed(operand2));
   result <= result64(31 downto 0);
end arch ;
