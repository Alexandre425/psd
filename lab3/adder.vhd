library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fp_adder is
    generic (
        I : integer := 5; F : integer := 7
    );
    port(
        operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
        result : out std_logic_vector (I+F downto 0)      -- Result of operation
    );
end fp_adder;

architecture behavioral of fp_adder is
    signal temp : std_logic_vector (I+F-1 downto 0);
begin
    temp <= std_logic_vector(signed(operand1) + signed(operand2));
    result <= temp(I+F-1) & temp;
end behavioral;