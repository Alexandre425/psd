--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   14:31:45 09/10/2014
-- Design Name:
-- Module Name:   C:/xup/vhdl/introLab/tb_circuito.vhd
-- Project Name:  introLab
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: circuito
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY circuito_tb IS
END circuito_tb;

ARCHITECTURE behavior OF circuito_tb IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT circuito
    PORT(
      clk     : IN  std_logic;
      rst     : IN  std_logic;
      instr   : IN  std_logic_vector(2 DOWNTO 0);
      data_in : IN  std_logic_vector(7 DOWNTO 0);
      res     : OUT std_logic_vector(7 DOWNTO 0)
      );
  END COMPONENT;


  --Inputs
  SIGNAL clk     : std_logic                    := '0';
  SIGNAL rst     : std_logic                    := '0';
  SIGNAL instr   : std_logic_vector(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL data_in : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

  --Outputs
  SIGNAL res : std_logic_vector(7 DOWNTO 0);

  -- Clock period definitions
  CONSTANT clk_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : circuito PORT MAP (
    clk     => clk,
    rst     => rst,
    instr   => instr,
    data_in => data_in,
    res     => res
    );

  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR clk_period/2;
    clk <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;


  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 100 ns;

    WAIT FOR clk_period*10;

    -- insert stimulus here
    rst <= '1' AFTER 20 ns,
           '0' AFTER 40 ns;

    data_in <= X"67" AFTER 40 ns,
               X"12" AFTER 120 ns,
               X"C3" AFTER 200 ns;

    instr <= "001" AFTER 40 ns,
             "000" AFTER 80 ns,
             "010" AFTER 120 ns,
             "000" AFTER 160 ns,
             "100" AFTER 200 ns,
             "000" AFTER 300 ns;

    WAIT;
  END PROCESS;

END;
