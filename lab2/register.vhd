library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg32 is
    port(
        clk : in std_logic;
        D : in std_logic_vector (31 downto 0);
        Q : out std_logic_vector (31 downto 0);
        rst, en : in std_logic
    );
end reg32;

architecture arch of reg32 is
begin
    process (clk,rst)
    begin
        if rst = '1' then
            Q <= (others => '0');
        elsif (clk'event and clk = '1') then
            if en = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end arch;