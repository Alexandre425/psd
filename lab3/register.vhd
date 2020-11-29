library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
    generic (
        N : integer := 12
    );
    port(
        clk, reset, enable: in std_logic;
        D : in std_logic_vector (N-1 downto 0);
        Q : out std_logic_vector (N-1 downto 0)
    );
end reg;

architecture behavioral of reg is
begin
    process (clk, rst)
    begin
        if reset = '1' then
            Q <= (others => '0');
        elsif clk'event and clk = '1' and enable = '1' then
            Q <= D;
        end if;
    end process;
end behavioral;