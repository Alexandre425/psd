library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity comparator is
    port (oper1, oper2 : in std_logic_vector(64 downto 0);
    flag : out std_logic);
end comparator;

architecture archi of comparator is
begin
    flag <= '1' when oper1 >= oper2
    else '0';
end archi;
