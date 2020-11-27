library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common.all;

entity control_tb is
end control_tb;
    
architecture Behavioral of control_tb is
    component control
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            max_sel     : out std_logic;
            save_avg    : out std_logic;
            save_idx    : out std_logic;
            idx         : out std_logic_vector (2 downto 0);
            idx_offset  : out std_logic_vector (2 downto 0)            
        ); 
    end component;
        
    signal clk_in       : std_logic;
    signal reset        : std_logic := '1';
    signal max_sel      : std_logic;
    signal save_avg     : std_logic;
    signal save_idx     : std_logic;
    signal idx          : std_logic_vector (2 downto 0);
    signal idx_offset   : std_logic_vector (2 downto 0);
    CONSTANT clk_period : time := 10 ns;
begin

    uut: control port map(
        clk => clk_in,
        reset => reset,
        max_sel => max_sel,
        save_avg => save_avg,
        save_idx => save_idx,
        idx => idx,
        idx_offset => idx_offset
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
        wait for 100ns;
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
