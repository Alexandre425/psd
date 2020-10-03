library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity control is
  port (
    clk, rst : in  std_logic; --Clock e reset
    oper    : in  std_logic_vector (2 downto 0); --Instrução para a transição de estados na fsm
    enable   : out std_logic; 
    slct     : out std_logic_vector (1 downto 0) --Selecionar Operação
        ); 
end control;

architecture behavioral of control is
  type fsm_states is (s_initial, s_unsg_add, s_unsg_multip, s_or, s_rtr, s_end); --Estados da fsm
  signal currstate, nextstate : fsm_states; --Sinais estado atual e estado seguinte

begin
  state_reg : process (clk, rst)
  begin
    if rst = '1' then
      currstate <= s_initial;
    elsif clk'event and clk = '1' then
      currstate <= nextstate;
    end if;
  end process;


  state_comb : process (currstate, oper)
  begin  --  process

    nextstate <= currstate; -- by default, does not change the state.

    case currstate is
      when s_initial =>
        if oper = "001" then --Soma
          nextstate <= s_unsg_add;
        elsif oper = "010" then --Multiplicação
          nextstate <= s_unsg_multip;
        elsif oper = "011" then --Or
          nextstate <= s_or;
        else --Rotate right
            nextstate <= s_rtr;
        end if;
        slct   <= "00";
        enable <= '0';

      when s_unsg_add =>
        nextstate <= s_end;
        slct      <= "00";
        enable    <= '1';

      when s_unsg_multip =>
        nextstate <= s_end;
        slct     <= "01";
        enable    <= '1';

      when s_or =>
        nextstate <= s_end;
        slct      <= "10";
        enable    <= '1';
        
      when s_rtr =>
        nextstate <= s_end;
        slct      <= "11";
        enable    <= '1';

      when s_end =>
        if oper = "000" then
          nextstate <= s_initial;
        end if;
        slct   <= "00";
        enable <= '0';

    end case;
  end process;

end behavioral;

