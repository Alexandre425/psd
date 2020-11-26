library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Evaluates operand1 > operand2
entity comparator is
    generic (
        N : integer := 8
    );
    port(
        operand1, operand2 : in std_logic_vector (N-1 downto 0);  -- Operands
        result : out std_logic  -- 1 if oper1 > oper2, 0 if oper1 <= oper2
    );
end comparator;

architecture behavioral of comparator is
begin
    result <= std_logic(signed(operand1) > signed(operand2));
end behavioral;
