library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reg is
    generic (
        X : integer := 12
    );
    port(
        clk : in std_logic;
        D : in std_logic_vector (X-1 downto 0);
        Q : out std_logic_vector (X-1 downto 0)
    );
end reg;

architecture behavioral of reg is
begin
    process (clk)
    begin
        if(clk'event and clk = '1') then
            Q <= D;
        end if;
    end process;
end behavioral;