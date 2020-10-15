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
        S_RELEASE,      -- Wait for the realease of the keys
        S_ADD,          -- States to select the operator
        S_MULT, 
        S_OR, 
        S_RTR
    );
    signal currstate, nextstate, state_buffer : fsm_states; --Current state and next state signals
     
    
    constant REG1 : std_logic_vector (1 downto 0) := "01";
    constant REG2 : std_logic_vector (1 downto 0) := "10";
    
begin

    state_comb : process (clk)
    begin  --  process
    
        if clk'event and clk = '1' then
            case currstate is
                when S_RESET =>
                    currstate <= S_WAIT;            -- Next state is "wait and load to R1"
                    slct <= ALU_ADD;
                    enable <= "00";
                    
                when S_WAIT =>
                    if buttons(BUT_ENTER) = '1' then   -- When pressing the enter button
                        currstate <= S_LOAD;
                    end if;
                    slct   <= ALU_ADD;          -- Select the operation the ALU will perform
                    enable <= REG1;
                    
                when S_LOAD =>                 
                    state_buffer    <= S_ADD; 
                    currstate       <= S_RELEASE;
                    slct            <= ALU_ADD;
                    enable          <= REG2;
                    
                when S_OPER =>   
                    state_buffer    <= S_ADD;       
                    currstate       <= S_RELEASE;
                    enable          <= REG2;
                    
                when S_RELEASE =>
                    if buttons = "00000" then
                        currstate <= state_buffer;
                    end if;
                    enable <= "00";
                    
                when S_ADD =>
                    if buttons(BUT_OPER_FWD) = '1' then
                        state_buffer <= S_MULT;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_OPER_BCK) = '1' then
                        state_buffer <= S_RTR;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_ENTER) = '1' then
                        currstate <= S_OPER;
                    elsif buttons(BUT_RESET) = '1' then
                        currstate <= S_RESET;
                    end if;            
                    slct    <= ALU_ADD;
                    enable  <= REG1;
                    
                when S_MULT =>
                    if buttons(BUT_OPER_FWD) = '1' then
                        state_buffer <= S_OR;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_OPER_BCK) = '1' then
                        state_buffer <= S_ADD;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_ENTER) = '1' then
                        currstate <= S_OPER;
                    elsif buttons(BUT_RESET) = '1' then
                        currstate <= S_RESET;
                    end if;                  
                    slct    <= ALU_MULT;
                    enable  <= REG1;
                    
                when S_OR =>
                    if buttons(BUT_OPER_FWD) = '1' then
                        state_buffer <= S_RTR;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_OPER_BCK) = '1' then
                        state_buffer <= S_MULT;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_ENTER) = '1' then
                        currstate <= S_OPER;
                    elsif buttons(BUT_RESET) = '1' then
                        currstate <= S_RESET;
                    end if;                  
                    slct    <= ALU_OR;
                    enable  <= REG1;
                    
                when S_RTR =>
                    if buttons(BUT_OPER_FWD) = '1' then
                        state_buffer <= S_ADD;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_OPER_BCK) = '1' then
                        state_buffer <= S_OR;
                        currstate <= S_RELEASE;
                    elsif buttons(BUT_ENTER) = '1' then
                        currstate <= S_OPER;
                    elsif buttons(BUT_RESET) = '1' then
                        currstate <= S_RESET;
                    end if;                 
                    slct    <= ALU_RTR;
                    enable  <= REG1;
            end case;
        end if;
    end process;
    
    with currstate select
        oper_disp <=
            "0001" when S_ADD,
            "0010" when S_MULT,
            "0011" when S_OR,
            "0100" when S_RTR,
            "0000" when others;
            
end behavioral;

