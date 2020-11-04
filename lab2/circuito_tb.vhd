library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity circuito_tb is
end circuito_tb;

architecture Behavioral of circuito_tb is
    component circuito
        port (
            clk     : in  std_logic;
            reset   : in std_logic;                         -- Reset signal
            done    : buffer std_logic;                        -- Done Signal
            addr    : out std_logic_vector (9 downto 0);
            dataOUT : out std_logic_vector (31 downto 0);   -- 32 bits determinant
            we      : out std_logic                         -- Write enable
        );
    end component;

    signal clk_in : std_logic;
    signal reset : std_logic := '1';
    signal dataOUT : std_logic_vector (31 downto 0);
    signal addr : std_logic_vector (9 downto 0);
    signal done : std_logic := '0';
    signal we : std_logic := '0';

    CONSTANT clk_period : time := 10 ns;
begin

    uut: circuito port map(
        clk     => clk_in,
        reset   => reset,
        dataOUT => dataOUT,
        addr    => addr,
        done    => done,
        we      => we
    );

    clk_process : PROCESS
    BEGIN
        clk_in <= '0';
        WAIT FOR clk_period/2;
        clk_in <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

   stim_proc : process
    begin
        reset <= '1';
        wait for 50ns;
        reset <= '0';
        wait for 500ns;
        reset <= '1';
        wait for 50ns;
        reset <= '0';

       wait;
    end process;

end Behavioral;
