--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
use work.common.all;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behavior OF alu_tb IS

  -- Component Declaration for the Unit Under Test (UUT)

   COMPONENT alu
     PORT(
         operand1, operand2 : in std_logic_vector (7 downto 0);  -- Operands
         operator : in alu_operation;                            -- Operator
         result : out std_logic_vector (7 downto 0)              -- Result of operation
    );
   END COMPONENT;

  --Inputs
  SIGNAL operand1_in, operand2_in   : std_logic_vector(7 DOWNTO 0);
  SIGNAL operator_in : alu_operation;

  --Outputs
  SIGNAL result_out : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

BEGIN

  -- Instantiate the Unit Under Test (UUT)
    uut : alu PORT MAP (
    operand1 => operand1_in,
    operand2 => operand2_in,
    operator => operator_in,
    result   => result_out
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
