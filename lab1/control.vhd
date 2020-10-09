library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity control is
    port (
        clk         : in  std_logic;
        buttons     : in  std_logic_vector (4 downto 0); -- Input buttons
        enable      : out std_logic_vector (1 downto 0); -- Enable signals of the registers
        slct        : out alu_operation; --Selecionar Operação
        oper_disp   : out std_logic_vector (3 downto 0)
        ); 
end control;

architecture behavioral of control is
    type fsm_states is (    -- State machine states
        S_RESET,        -- State after pressing the reset button
        S_WAIT,         -- Load the value into register 1 after a reset and wait for an enter
        S_LOAD,         -- Load the value into register 2 
        S_OPER,         -- Save the result of an operation
        S_ADD,          -- States to select the operator
        S_MULT, 
        S_OR, 
        S_RTR
    );
    signal currstate, nextstate : fsm_states; --Current state and next state signals
     
    
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
                nextstate <= S_WAIT;            -- Next state is "wait and load to R1"
                enable <= not REG1 or not REG2; -- Choose which registers will be enabled
                slct <= ALU_ADD;
                
            when S_WAIT =>
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then   -- When pressing the enter button
                    nextstate <= S_LOAD;
                end if;
                slct   <= ALU_ADD;          -- Select the operation the ALU will perform
                enable <= REG1 or not REG2;
                
            when S_LOAD =>                  
                nextstate   <= S_ADD;
                slct        <= ALU_ADD;
                enable      <= not REG1 or REG2;
                
            when S_OPER =>                 
                nextstate   <= S_ADD;
                enable      <= not REG1 or REG2;
                slct <= ALU_ADD;
                
            when S_ADD =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_MULT;
                end if;
                if buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_RTR;
                end if;
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                end if;
                if buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_ADD;
                enable  <= REG1 or not REG2;
                
            when S_MULT =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_OR;
                end if;
                if buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_ADD;
                end if;
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                end if;
                if buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_MULT;
                enable  <= REG1 or not REG2;
                
            when S_OR =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_RTR;
                end if;
                if buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_MULT;
                end if;
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                end if;
                if buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_OR;
                enable  <= REG1 or not REG2;
                
            when S_RTR =>
                if buttons(BUT_OPER_FWD)'event and buttons(BUT_OPER_FWD) = '1' then
                    nextstate <= S_ADD;
                end if;
                if buttons(BUT_OPER_BCK)'event and buttons(BUT_OPER_BCK) = '1' then
                    nextstate <= S_OR;
                end if;
                if buttons(BUT_ENTER)'event and buttons(BUT_ENTER) = '1' then
                    nextstate <= S_OPER;
                end if;
                if buttons(BUT_RESET)'event and buttons(BUT_RESET) = '1' then
                    nextstate <= S_RESET;
                end if;
                slct    <= ALU_RTR;
                enable  <= REG1 or not REG2;
        end case;
    end process;
    
    with currstate select
        oper_disp <=
            "0001" when S_ADD,
            "0010" when S_MULT,
            "0011" when S_OR,
            "0100" when S_RTR,
            "0000" when others;
            
end behavioral;

