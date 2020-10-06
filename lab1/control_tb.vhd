--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
use work.common.all;

ENTITY control_tb IS
END control_tb;

ARCHITECTURE behavior OF control_tb IS

  -- Component Declaration for the Unit Under Test (UUT)

   COMPONENT control
     PORT(
         clk : in  std_logic; -- Clock e reset
         buttons  : in  std_logic_vector (4 downto 0); -- Input buttons
         enable   : out std_logic_vector (1 downto 0); -- Enable signals of the registers
         slct     : out alu_operation --Selecionar Operação
         );
   END COMPONENT;

  --Inputs
  SIGNAL clk_in: std_logic := '0';
  SIGNAL buttons_in :  std_logic_vector (4 DOWNTO 0) := (OTHERS=>'0');

  --Outputs
  SIGNAL enable_out : std_logic_vector(1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL slct_out : alu_operation := ALU_ADD;
  
  -- Clock period definitions
  CONSTANT clk_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
    uut : control PORT MAP (
    clk => clk_in,
    buttons => buttons_in,
    enable => enable_out,
    slct   => slct_out
    );
    
    
  -- Clock process definitions
  clk_process : PROCESS
  BEGIN
    clk_in <= '0';
    WAIT FOR clk_period/2;
    clk_in <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 10 ns;

    -- insert stimulus here
    buttons_in(4) <= '1' AFTER 0 ns,      --botao de reset
                   '0' AFTER 10 ns,
                   '1' AFTER 150ns;

    buttons_in(2) <= '1' AFTER 20 ns,      --botao de enter
                   '0' AFTER 30 ns,
                   '1' AFTER 100 ns,
                   '0' AFTER 110ns,
                   '1' AFTER 120ns,
                   '0' AFTER 130ns;

    buttons_in(3) <= '1' AFTER 40 ns,      --botao de forward
                   '0' AFTER 50 ns,
                   '1' AFTER 60 ns,
                   '0' AFTER 70 ns,
                   '1' AFTER 80 ns,
                   '0' AFTER 90 ns;

                   
    buttons_in(1) <= '1' AFTER 90 ns,      --botao de backwards
                   '0' AFTER 100 ns;
 

    WAIT;
  END PROCESS;

END;
