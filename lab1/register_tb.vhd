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
<<<<<<< HEAD
        rst, en_reg8 : in std_logic             --register reset and enable
=======
        rst : in std_logic                     --register reset
>>>>>>> 2ac309a69851620b6d641a3558b1aa32976e64a2
        );
  END COMPONENT;

  --Inputs
  SIGNAL clk  : std_logic := '0';
  SIGNAL D_in : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rst : std_logic := '0';
<<<<<<< HEAD
  SIGNAL en_reg8 : std_logic := '0';  
=======
>>>>>>> 2ac309a69851620b6d641a3558b1aa32976e64a2

  --Outputs
  SIGNAL Q_out : std_logic_vector(7 DOWNTO 0);

  -- Clock period definitions
  CONSTANT clk_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut : reg8 PORT MAP (
<<<<<<< HEAD
    clk => clk,
    D => D_in,
    Q => Q_out,
    rst => rst,
    en_reg8 => en_reg8
=======
    clk     => clk,
    D   => D_in,
    Q => Q_out,
    rst => rst
>>>>>>> 2ac309a69851620b6d641a3558b1aa32976e64a2
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
    rst <= '1' AFTER 0 ns,
           '0' AFTER 20 ns,
           '1' AFTER 180 ns,
           '0' AFTER 190 ns;
    
    en_reg8 <= '1' AFTER 70 ns,
               '0' AFTER 100 ns,
               '1' AFTER 150 ns,
               '0' AFTER 170 ns;
    
    D_in <= X"67" AFTER 40 ns,
            X"12" AFTER 120 ns,
            X"C3" AFTER 200 ns;
            
    WAIT;
  END PROCESS;

END;
