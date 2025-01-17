
library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;


entity top_circuit_tb is
end entity top_circuit_tb;


architecture test of top_circuit_tb is
  component top_circuit is
    port (
      SW       : in  std_logic_vector (15 downto 0);
      BTN      : in  std_logic_vector (4 downto 0);
      CLK      : in  std_logic;
      LED      : out std_logic_vector (15 downto 0);
      SSEG_CA  : out std_logic_vector (7 downto 0);
      SSEG_AN  : out std_logic_vector (3 downto 0);
      UART_TXD : out std_logic);
  end component top_circuit;

  signal SW       : std_logic_vector (15 downto 0) := (others => '0');
  signal BTN      : std_logic_vector (4 downto 0)  := (others => '0');
  signal CLK      : std_logic                      := '0';
  signal LED      : std_logic_vector (15 downto 0);
  signal SSEG_CA  : std_logic_vector (7 downto 0);
  signal SSEG_AN  : std_logic_vector (3 downto 0);
  signal UART_TXD : std_logic;

  -- Clock period definitions
  constant clk_period : time := 6 ns;


begin  -- architecture test

  top_circuit_1 : top_circuit
    port map (
      SW       => SW,
      BTN      => BTN,
      CLK      => CLK,
      LED      => LED,
      SSEG_CA  => SSEG_CA,
      SSEG_AN  => SSEG_AN,
      UART_TXD => UART_TXD);

-- Clock process definitions
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  stim_proc : process
  begin

    wait for 500 ns;

    -- Reset
    btn(3) <= '1';
    wait for 500 ns;
    btn(3) <= '0';
    wait for 500 ns;
    -- Start
    btn(2) <= '1';
    wait for 500 ns;
    btn(2) <= '0';
    wait for 500 ns;

    wait for 2 ms;

    -- Transfer
    btn(0) <= '1';
    wait for 100 ns;
    btn(0) <= '0';
    wait for 100 ns;

    wait;
  end process;



end architecture test;
