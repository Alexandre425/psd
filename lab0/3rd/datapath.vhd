library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
  port (a : in  std_logic_vector (7 downto 0);
        oper : in  std_logic_vector (1 downto 0);
        clk, en_accum, rst_accum : in  std_logic;
        res : out std_logic_vector (7 downto 0));
end datapath;

architecture behavioral of datapath is
  signal addsub, logic_and, res_alu : std_logic_vector (7 downto 0);
  signal accum : std_logic_vector (7 downto 0) := (others => '0');
begin

-- aritmentic unit: adder/subtracter
  addsub <= accum + a when oper(0) = '0' else
            accum - a;

-- logic unit: and
  logic_and <= data and accum;

-- multiplexer
  res_alu <= addsub when oper(1) = '0' else
             logic_and;

-- accumulator
  process (clk)
  begin
    if clk'event and clk = '1' then
      if rst_accum = '1' then
        accum <= X"00";
      elsif en_accum = '1' then
        accum <= res_alu;
      end if;
    end if;
  end process;

-- datapath output
  res <= accum;

end behavioral;
