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
            alu1_op     : out alu_operation;
            alu2_op     : out alu_operation;
            mult1_mux1  : out std_logic;    -- Multiplexer of the first operand of the first multiplier
            mult1_mux2  : out std_logic_vector (1 downto 0);    
            mult2_mux1  : out std_logic;    -- Multiplexer of the first operand of the second multiplier
            mult2_mux2  : out std_logic;
            alu1_mux1   : out std_logic;
            reg_mux     : out std_logic;    -- Multiplexer leading to every register
            reg_enable  : out std_logic_vector (5 downto 0);    -- Enable of the 6 registers
            addr        : out std_logic_vector (9 downto 0);    -- Counter used to address memory
            write_en    : out std_logic     -- Write enable
        ); 
    end component;
        
    signal clk_in : std_logic;
    signal reset : std_logic := '1';
    signal alu1_op : alu_operation;
    signal alu2_op : alu_operation;
    signal mult1_mux1 : std_logic;
    signal mult1_mux2 : std_logic_vector (1 downto 0);
    signal mult2_mux1 : std_logic;
    signal mult2_mux2 : std_logic;
    signal alu1_mux1 : std_logic;
    signal reg_mux : std_logic;
    signal reg_enable : std_logic_vector (5 downto 0);
    signal addr : std_logic_vector (9 downto 0);
    signal write_en : std_logic;

    CONSTANT clk_period : time := 10 ns;
begin

    uut: control port map(
        clk => clk_in,
        reset => reset,
        alu1_op => alu1_op,
        alu2_op => alu2_op,
        mult1_mux1 => mult1_mux1,
        mult1_mux2 => mult1_mux2,
        mult2_mux1=> mult2_mux1,
        mult2_mux2 => mult2_mux2,
        alu1_mux1 => alu1_mux1,
        reg_mux => reg_mux,
        reg_enable => reg_enable,
        addr => addr,
        write_en => write_en
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
