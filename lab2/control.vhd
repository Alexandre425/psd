library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity control is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        alu1_op     : out alu_operation;
        alu2_op     : out alu_operation;
        mult1_mux1  : out std_logic;    -- Multiplexer of the first operand of the first multiplier
        mult1_mux2  : out std_logic_vector (1 downto 0);    
        mult2_mux1  : out std_logic;    -- Multiplexer of the first operand of the second multiplier
        mult2_mux2  : out std_logic;
        alu1_mux1   : out std_logic;
        reg_mux     : out std_logic;    -- Multiplexer leading to every register
        reg_enable  : out std_logic_vector (5 downto 0);    -- Enable of the 6 registers
        addr        : out std_logic_vector (9 downto 0);    -- Counter used to address memory
        write_en    : out std_logic;    -- Write enable
        done        : buffer std_logic  -- Done Signal
    ); 
end control;
    
architecture behavioral of control is

    type fsm_states is (    -- State machine states
        S_LOAD,     -- Loads the values from memory to the registers
        S_CYCLE1,   -- Cycles to complete the operation
        S_CYCLE2,
        S_CYCLE3,
        S_CYCLE4,
        S_WRITE,    -- Stores the result into memory
        S_ADDR_INC, -- Increments the memory address
        S_DATA_WAIT -- Waits for the data from MemIN to become available
    );
    signal state : fsm_states;
    signal counter : unsigned (9 downto 0);
    
    constant R1_EN : std_logic_vector (5 downto 0) := "000001";
    constant R2_EN : std_logic_vector (5 downto 0) := "000010";
    constant R3_EN : std_logic_vector (5 downto 0) := "000100";
    constant R4_EN : std_logic_vector (5 downto 0) := "001000";
    constant R5_EN : std_logic_vector (5 downto 0) := "010000";
    constant R6_EN : std_logic_vector (5 downto 0) := "100000";
    
begin

    process (clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                counter <= "0000000000";
                done    <= '0';
            elsif state = S_WRITE then
                counter <= counter + 1;
                if counter = "0000001111" then
                    done <= '1';                --All the determinants have been calculated
                end if;
            end if;
        end if;
    end process;

    addr <= std_logic_vector(counter);

    process (clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then   -- If resetting or done, wait indefinitely
                state <= S_DATA_WAIT;
            end if;
            case state is
                when S_LOAD =>
                    if reset = '0' and done = '0' then     -- Wait for reset to stop being pressed
                        state <= S_CYCLE1;
                    else
                        state <= S_LOAD;
                    end if;
                when S_CYCLE1 =>
                    state <= S_CYCLE2;
                when S_CYCLE2 =>
                    state <= S_CYCLE3;
                when S_CYCLE3 =>
                    state <= S_CYCLE4;
                when S_CYCLE4 =>
                    state <= S_WRITE;
                when S_WRITE =>
                    state <= S_ADDR_INC;
                when S_ADDR_INC =>
                    if done = '1' then
                        state <= S_LOAD;
                    else
                        state <= S_DATA_WAIT;
                    end if;
                when S_DATA_WAIT =>
                    state <= S_LOAD;
            end case;
        end if;                
    end process;
    
    process(state)
    begin
        case state is
            when S_LOAD =>
                alu1_op <= ALU_ADD;     -- Set the ALU operation
                alu2_op <= ALU_ADD;
                mult1_mux1 <= 'X';      -- Select the correct registers with the arith unit muxes
                mult1_mux2 <= "XX";
                mult2_mux1 <= 'X';
                mult2_mux2 <= 'X';
                alu1_mux1 <= 'X';
                reg_mux <= '1';         -- Load from memory with the register muxes
                reg_enable <= R1_EN or R2_EN or R3_EN or R4_EN or R5_EN or R6_EN;   -- Enable registers to write
                write_en <= '0';    -- Enable writting to the output memory
            when S_CYCLE1 =>
                alu1_op <= ALU_ADD;
                alu2_op <= ALU_ADD;
                mult1_mux1 <= '1';  -- Select R2
                mult1_mux2 <= "10"; -- Select R6
                mult2_mux1 <= 'X';  -- R2 * R6 -> R2 / R6 (shifted right by 2 for R6)
                mult2_mux2 <= 'X';
                alu1_mux1 <= '0';   -- Select R3
                reg_mux <= '0';     -- R3 + R4 -> R4 (no need to select R4 because it needs no mux)
                reg_enable <= R2_EN or R4_EN or R6_EN;   -- Enable the registers to store the result
                write_en <= '0';
            when S_CYCLE2 =>
                alu1_op <= ALU_ADD;
                alu2_op <= ALU_ADD;
                mult1_mux1 <= '0';  -- R1 *
                mult1_mux2 <= "01"; -- R5
                mult2_mux1 <= '1';  -- R4 *
                mult2_mux2 <= '1';  -- R5
                alu1_mux1 <= '1';   -- R6 +
                reg_mux <= '0';     -- R4
                reg_enable <= R1_EN or R2_EN or R3_EN or R4_EN;
                write_en <= '0';
            when S_CYCLE3 =>
                alu1_op <= ALU_ADD;
                alu2_op <= ALU_ADD;
                mult1_mux1 <= '1';  -- R2 *
                mult1_mux2 <= "00"; -- R4
                mult2_mux1 <= '0';  -- R3 *
                mult2_mux2 <= '0';  -- R1
                alu1_mux1 <= 'X';
                reg_mux <= '0';
                reg_enable <= R1_EN or R2_EN;
                write_en <= '0';
            when S_CYCLE4 =>
                alu1_op <= ALU_SUB;
                alu2_op <= ALU_SUB;
                mult1_mux1 <= 'X';
                mult1_mux2 <= "XX";
                mult2_mux1 <= 'X';
                mult2_mux2 <= 'X';
                alu1_mux1 <= 'X';
                reg_mux <= '0';     -- R2 - R1
                reg_enable <= R5_EN;
                write_en <= '0';
            when S_WRITE =>
                alu1_op <= ALU_ADD;
                alu2_op <= ALU_ADD;
                mult1_mux1 <= 'X';
                mult1_mux2 <= "XX";
                mult2_mux1 <= 'X';
                mult2_mux2 <= 'X';
                alu1_mux1 <= 'X';
                reg_mux <= 'X';
                reg_enable <= "000000";
                write_en <= '1';
            when S_ADDR_INC =>
                alu1_op <= ALU_ADD;
                alu2_op <= ALU_ADD;
                mult1_mux1 <= 'X';
                mult1_mux2 <= "XX";
                mult2_mux1 <= 'X';
                mult2_mux2 <= 'X';
                alu1_mux1 <= 'X';
                reg_mux <= 'X';
                reg_enable <= "XXXXXX";
                write_en <= '0';
            when S_DATA_WAIT =>
                alu1_op <= ALU_ADD;
                alu2_op <= ALU_ADD;
                mult1_mux1 <= 'X';
                mult1_mux2 <= "XX";
                mult2_mux1 <= 'X';
                mult2_mux2 <= 'X';
                alu1_mux1 <= 'X';
                reg_mux <= 'X';
                reg_enable <= "XXXXXX";
                write_en <= '0';
        end case;
	end process;

    
end behavioral;

