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

BEGIN

  -- Instantiate the Unit Under Test (UUT)
    uut : control PORT MAP (
    clk => clk_in,
    buttons => buttons_in,
    enable => enable_out,
    slct   => slct_out
    );

  -- Stimulus process
  stim_proc : PROCESS
  BEGIN
    -- hold reset state for 100 ns.
    WAIT FOR 10 ns;

    -- insert stimulus here
    operator_in <= ALU_ADD AFTER 0 ns,
                   ALU_MULT AFTER 30 ns,
                   ALU_OR AFTER 70 ns,
                   ALU_RTR AFTER 80 ns;

    operand1_in <= X"01" AFTER 0 ns,
                   X"ff" AFTER 10 ns,
                   X"fd" AFTER 20 ns,
                   X"01" AFTER 30 ns,
                   X"02" AFTER 40 ns,
                   X"7F" AFTER 50 ns,
                   X"01" AFTER 70 ns;
                   
    operand2_in <= X"01" AFTER 0 ns,
                   X"01" AFTER 10 ns,
                   X"01" AFTER 20 ns,
                   X"01" AFTER 30 ns,
                   X"02" AFTER 40 ns,
                   X"02" AFTER 50 ns,
                   X"03" AFTER 60 ns,
                   X"02" AFTER 70 ns,
                   X"01" AFTER 80 ns,
                   X"02" AFTER 90 ns;

    WAIT;
  END PROCESS;

END;
