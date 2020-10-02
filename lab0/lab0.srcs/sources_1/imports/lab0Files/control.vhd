library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control is
  port (
    clk, rst : in  std_logic;
    instr    : in  std_logic_vector (2 downto 0);
    enable   : out std_logic;
    oper     : out std_logic_vector (1 downto 0));
end control;

architecture behavioral of control is
  type fsm_states is (s_initial, s_add, s_sub, s_and, s_end);
  signal currstate, nextstate : fsm_states;

begin
  state_reg : process (clk, rst)
  begin
    if rst = '1' then
      currstate <= s_initial;
    elsif clk'event and clk = '1' then
      currstate <= nextstate;
    end if;
  end process;


  state_comb : process (currstate, instr)
  begin  --  process

    nextstate <= currstate; -- by default, does not change the state.

    case currstate is
      when s_initial =>
        if instr = "001" then
          nextstate <= s_add;
        elsif instr = "010" then
          nextstate <= s_sub;
        elsif instr = "100" then
          nextstate <= s_and;
        end if;
        oper   <= "00";
        enable <= '0';

      when s_add =>
        nextstate <= s_end;
        oper      <= "00";
        enable    <= '1';

      when s_sub =>
        nextstate <= s_end;
        oper      <= "01";
        enable    <= '1';

      when s_and =>
        nextstate <= s_end;
        oper      <= "10";
        enable    <= '1';

      when s_end =>
        if instr = "000" then
          nextstate <= s_initial;
        end if;
        oper   <= "00";
        enable <= '0';

    end case;
  end process;

end behavioral;

