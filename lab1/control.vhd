library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.common.all;


entity control is
    port (
        clk : in  std_logic; -- Clock e reset
        buttons  : in  std_logic_vector (4 downto 0); -- Input buttons
        enable   : out std_logic_vector (1 downto 0); -- Enable signals of the registers
        slct     : out alu_operation --Selecionar Operação
        ); 
end control;

architecture behavioral of control is
    type fsm_states is (    -- State machine states
        S_RESET,        -- State after pressing the reset button
        S_LOAD,         -- Load the value into register 2 after a reset
        S_OPER,         -- Save the result of an operation
        S_ADD,          -- States to select the operator
        S_MULT, 
        S_OR, 
        S_RTR, 
        S_DISPLAY       -- Display the result value
    );
    signal currstate, nextstate : fsm_states; --Current state and next state signals
     
    constant BUT_OPER_FWD : integer := 3;
    constant BUT_OPER_BCK : integer := 1;
    constant BUT_ENTER : integer := 2;
    constant BUT_RESET : integer := 4;
    constant REG1 : std_logic_vector (1 downto 0) := "01";
    constant REG2 : std_logic_vector (1 downto 0) := "10";
    
begin
    state_reg : process (clk)
    begin
        if clk'event and clk = '1' then
            currstate <= nextstate;
        end if;
    end process;


    state_comb : process (currstate, buttons)
    begin  --  process

        nextstate <= currstate; -- by default, does not change the state.

        case currstate is
            when S_RESET =>
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then   -- When pressing the enter button
                    nextstate <= S_LOAD;    -- Next state is the "load to R2" state
                end if;
                slct   <= ALU_ADD;
                enable <= REG1 or not REG2;
                
            when S_LOAD =>
                nextstate   <= S_ADD;
                slct        <= ALU_ADD;
                enable      <= not REG1 or REG2;
                
            when S_OPER =>
                nextstate   <= S_DISPLAY;
                enable      <= not REG1 or REG2;
                
            when S_ADD =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_MULT;
                elsif buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_RTR;
                elsif buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                elsif buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_ADD;
                enable  <= REG1 or not REG2;
                
            when S_MULT =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_OR;
                elsif buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_ADD;
                elsif buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                elsif buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_MULT;
                enable  <= REG1 or not REG2;
                
            when S_OR =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_RTR;
                elsif buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_MULT;
                elsif buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                elsif buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_OR;
                enable  <= REG1 or not REG2;
                
            when S_RTR =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_ADD;
                elsif buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_OR;
                elsif buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                elsif buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_RTR;
                enable  <= REG1 or not REG2;
            when S_DISPLAY =>
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_ADD;
                elsif buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                enable <= not REG1 or not REG2;
                end if; 
        end case;
  end process;

end behavioral;

