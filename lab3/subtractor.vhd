library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fp_subtractor is
    generic (
        I : integer := 5; F : integer := 7
    );
    port(
        operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
        result : out std_logic_vector (I+F-1 downto 0)      -- Result of operation
    );
end fp_subtractor;

architecture behavioral of fp_subtractor is
begin
    result <= std_logic_vector(signed(operand1) - signed(operand2));
end behavioral;