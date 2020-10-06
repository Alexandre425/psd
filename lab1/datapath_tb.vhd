--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY datapath_tb IS
END datapath_tb;

ARCHITECTURE behavior OF datapath_tb IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT datapath
    PORT(
        ent : in std_logic_vector (7 downto 0); --Dados de entrada
        slct : in alu_operation; --Seleção da operação a realizar na ALU
        clk, rst, slct_disp, enable: in std_logic; --Clock, reset, seleção de display e enable
        res : out std_logic_vector (7 downto 0) --Dados de entrada e saída do registo 2, ambos sinais a representar no display de 7 segmentos; Saída do registo 2 
        );
  END COMPONENT;


  --Inputs
  SIGNAL clk, rst, enable : std_logic := '0';
  SIGNAL slct_disp : std_logic := '1';
  SIGNAL ent : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL slct : alu_operation := ALU_ADD;

  --Outputs
  SIGNAL res : std_logic_vector(7 DOWNTO 0);

  -- Clock period definitions
  CONSTANT clk_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : datapath PORT MAP (
    clk => clk,
    rst => rst,
    slct => slct,
    enable => enable,
    slct_disp => slct_disp,
    ent => ent,
    res => res
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
    WAIT FOR 10 ns;

    -- insert stimulus here
    rst <= '1' AFTER 0 ns,      -- STATE 1 (0)
           '0' AFTER 10 ns;     ----------
           
    enable <= '1' AFTER 80 ns,  -- STATE 1 (1) (INPUT)
              '0' AFTER 90 ns,  ----------
              '1' AFTER 170 ns, -- STATE 2 (2) (INPUT)
              '0' AFTER 180 ns, ----------
              '1' AFTER 230 ns, -- STATE 2 (3) (OPERATION)
              '0' AFTER 240 ns, ----------
              '1' AFTER 280 ns, -- STATE 3 (4) (DISPLAY)
              '0' AFTER 290 ns, ----------
              '1' AFTER 330 ns, -- STATE 2 (5) (INPUT)
              '0' AFTER 340 ns, ----------
              '1' AFTER 380 ns, -- STATE 2 (6) (OPERATION)
              '0' AFTER 390 ns, ----------
              '1' AFTER 410 ns, -- STATE 2 (7) (DISPLAY)
              '0' AFTER 420 ns; ----------

 
    slct <= ALU_OR AFTER 200 ns, -- STATE 2 (3)
            ALU_ADD AFTER 360 ns; -- STATE 2 (6)

    ent <= X"01" AFTER 40 ns,   -- STATE 1 (1)
           X"02" AFTER 150 ns,  -- STATE 2 (2)
           X"03" AFTER 300 ns;  -- STATE 2 (5)

    WAIT;
  END PROCESS;

END;
