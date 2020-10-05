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
        clk : in std_logic;                     --clock
        D : in std_logic_vector (7 downto 0);   --register input (load)
        Q : out std_logic_vector (7 downto 0);   --register output (load)
        rst : in std_logic                     --register reset
        );
end reg8;

--register output,conditioned by the clock 
architecture arch1 of reg8 is
begin
    process (clk,rst)
    begin
        if rst = '1' then
            Q <= (others => '0');
        elsif (clk'event and clk = '1') then
            Q <= D;
        end if;
    end process;
end arch1;