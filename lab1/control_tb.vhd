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
    
    wait for 100ns;
    
    buttons_in(BUT_RESET) <= '1';
    wait for 50ns;
    buttons_in(BUT_RESET) <= '0';
    wait for 50ns;
    
    buttons_in(BUT_ENTER) <= '1';
    wait for 50ns;
    buttons_in(BUT_ENTER) <= '0';
    wait for 50ns;
    
    buttons_in(BUT_OPER_FWD) <= '1';
    wait for 50ns;
    buttons_in(BUT_OPER_FWD) <= '0';
    wait for 50ns;
    
    buttons_in(BUT_OPER_FWD) <= '1';
    wait for 50ns;
    buttons_in(BUT_OPER_FWD) <= '0';
    wait for 50ns;
    
    buttons_in(BUT_ENTER) <= '1';
    wait for 50ns;
    buttons_in(BUT_ENTER) <= '0';
    wait for 50ns;
    
    buttons_in(BUT_RESET) <= '1';
    wait for 50ns;
    buttons_in(BUT_RESET) <= '0';
    wait for 50ns;
    
    WAIT;
  END PROCESS;

END;
