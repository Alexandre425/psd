----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg8 is
    port(
        clk : in std_logic;
        D : in std_logic_vector (7 downto 0);
        Q : out std_logic_vector (7 downto 0)
        );
end reg8;

architecture archi of reg8 is
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            Q <= D;
        end if;
    end process;
end archi;