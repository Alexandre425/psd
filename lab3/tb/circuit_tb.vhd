library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;

entity control_tb is
end control_tb;
    
architecture Behavioral of control_tb is
    component control
        port (
            clk :       in std_logic;
            clk_qt :    in std_logic;   -- Quarter speed clock (control unit has to align with datapath)
            start :     in std_logic;
            reset :     in std_logic;
            enable :    out std_logic;  -- Enables the saving of new values on the datapath
            buffer_fwd: out std_logic;  -- Forward the data from the buffer to the datapath
            addr :      out std_logic_vector (7 downto 0);  -- Memory address
            idx:        out std_logic_vector (2 downto 0)   -- Index of the matrix
        ); 
    end component;
        
    signal clk : std_logic;
    signal clk_qt : std_logic;
    signal start : std_logic;
    signal reset : std_logic;
    signal enable : std_logic;
    signal buffer_fwd : std_logic;
    signal addr : std_logic_vector (7 downto 0);
    signal idx : std_logic_vector (2 downto 0);

    CONSTANT clk_period : time := 10 ns;
begin

    uut: control port map(
        clk => clk,
        clk_qt => clk_qt,
        start => start,
        reset => reset,
        enable => enable,
        buffer_fwd => buffer_fwd,
        addr => addr,
        idx => idx
    );

    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    clk_qt_process : process
    begin
        clk_qt <='0';
        wait for clk_period*2;
        clk_qt <='1';
        wait for clk_period*2;
    end process;

    stim_proc : process
    begin
        reset <= '1';
        wait for 50ns;
        reset <= '0';
        wait for 50ns;
        start <= '1';
        wait for 50ns;
        start <= '0';
        wait;
    end process;

end Behavioral;
