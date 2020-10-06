--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY reg8_tb IS
END reg8_tb;

ARCHITECTURE arch1 OF reg8_tb IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT reg8
    PORT(
        clk : in std_logic;                     --clock
        D : in std_logic_vector (7 downto 0);   --register input (load)
        Q : out std_logic_vector (7 downto 0);  --register output (load)
        rst : in std_logic                     --register reset
        );
  END COMPONENT;

  --Inputs
  SIGNAL clk     : std_logic                    := '0';
  SIGNAL D_in : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rst : std_logic := '0';

  --Outputs
  SIGNAL Q_out : std_logic_vector(7 DOWNTO 0);

  -- Clock period definitions
  CONSTANT clk_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : reg8 PORT MAP (
    clk     => clk,
    D   => D_in,
    Q => Q_out,
    rst => rst
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
    D_in <= X"67" AFTER 40 ns,
            X"12" AFTER 120 ns,
            X"C3" AFTER 200 ns;
            
    WAIT;
  END PROCESS;

END;
