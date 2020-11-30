library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;

entity circuit_tb is
end circuit_tb;
    
architecture Behavioral of circuit_tb is
    component circuit
        port (
            clk        : in  std_logic;
            clk_qt     : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            dataIn     : in  std_logic_vector (31 downto 0);
            addrIn     : out std_logic_vector (7 downto 0);
            dataOut    : out std_logic_vector (31 downto 0);
            addrOut    : out std_logic_vector (7 downto 0);
            weOut      : out std_logic;
            statusLeds : out std_logic_vector (15 downto 0)
        ); 
    end component;
        
    signal clk :    std_logic; 
    signal clk_qt : std_logic;
    signal reset :  std_logic;      
    signal start :  std_logic;
    signal dataIn : std_logic_vector (31 downto 0);
    signal addrIn : std_logic_vector (7 downto 0); 
    signal dataOut :std_logic_vector (31 downto 0);
    signal addrOut :std_logic_vector (7 downto 0);
    signal weOut :  std_logic;
    signal statusLeds : std_logic_vector (15 downto 0);

    CONSTANT clk_period : time := 10 ns;
begin

    uut: circuit port map(
        clk => clk,
        clk_qt  => clk_qt,
        reset   => reset,  
        start   => start,
        dataIn  => dataIn,
        addrIn  => addrIn,
        dataOut => dataOut,
        addrOut => addrOut,
        weOut   => weOut,
        statusLeds  => statusLeds
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
        wait for clk_period;
        dataIn <= x"aaaaaaaa";
        wait for clk_period;
        dataIn <= x"bbbbbbbb";
        wait for clk_period;
        dataIn <= x"cccccccc";
        wait for clk_period;
        dataIn <= x"dddddddd";
        wait;
    end process;

end Behavioral;
