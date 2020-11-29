library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity control is
    port (
        clk :       in std_logic;
        start :     in std_logic;
        reset :     in std_logic;
        buffer_fwd: out std_logic;  -- Forward the data from the buffer to the datapath
        addr :      out std_logic_vector (7 downto 0);  -- Memory address
        idx:        out std_logic_vector (2 downto 0)   -- Index of the matrix
    );
end entity control;

architecture behavioral of control is
    type fsm_states is(
        S_WAIT,         -- Wait until the start button is pressed
        S_WAIT_RELEASE, -- Wait for the button to be released
        S_FIRST_LOAD_A, -- Load A into the first buffer, runs only for the first cycle
        S_LOAD_A,       -- Load A and pass the ABCD values from the first to the second buffer
        S_LOAD_B,       -- Load B, so on...
        S_LOAD_C,
        S_LOAD_D,
    );
    signal state : fsm_states;
    signal idx_counter :    unsigned (2 downto 0);  -- Counts matrices 
    signal addr_counter :   unsigned (7 downto 0);  -- Counts memory addresses
begin

    process (clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then                         -- On a reset
                idx_counter     <= (others => "000");   -- Reset the counters
                addr_counter    <= (others => "00000000");
            else if state = S_LOAD_A then               -- When loading A from the next matrix
                idx_counter <= idx_counter + 1;         -- Increment the matrix count
            else if state /= S_WAIT then                -- When loading any value
                addr_counter <= addr_counter + 1;       -- Increment the adress
            end if;
        end if;
    end process;

    -- Outputting the counters
    idx     <= std_logic_vector(idx_counter);
    addr    <= std_logic_vector(addr_counter);

    process (clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then     -- Synchronous reset
                state <= S_WAIT;
            else                    -- If not reset
                case state is       -- Next state depends on state and counter
                    when S_WAIT =>
                        if start = '1' then
                            state <= S_WAIT_RELEASE;
                        end if;
                    when S_WAIT_RELEASE =>
                        if start = '0' then
                            state <= S_FIRST_LOAD_A;
                        end if;
                    when S_FIRST_LOAD_A =>
                        state <= S_LOAD_B;
                    when S_LOAD_A =>
                        state <= S_LOAD_B;
                    when S_LOAD_B =>
                        state <= S_LOAD_C;
                    when S_LOAD_C =>
                        state <= S_LOAD_D;
                    when S_LOAD_D =>
                        state <= S_LOAD_A;
                end case;
         	end if;
		end if;
    end process;

    process (state)
    begin
        case state is
            when S_START =>
                max_sel     <= '1'; -- Here the min and max values shouldn't be updated
                save_avg    <= 'X'; -- Don't care about saving, will be overwritten later
                save_idx    <= 'X';
            when S_UNLOCK_MIN_MAX =>
                max_sel     <= '0'; -- Unlocking the updates as data reaches third layer
                save_avg    <= 'X';
                save_idx    <= 'X';
            when S_SAVE_AVG =>
                max_sel     <= '0';
                save_avg    <= '1'; -- Saving the average
                save_idx    <= 'X'; -- Still don't care about the index
            when S_SAVE_IDX =>
                max_sel     <= 'X'; -- Don't care what will be saved to the min and max registers
                save_avg    <= '0'; -- Don't overwrite the average, must be 0
                save_idx    <= '1'; -- Finally save the index
            when S_DONE =>
                max_sel     <= 'X'; -- Don't care 
                save_avg    <= '0'; -- Don't overwrite either!
                save_idx    <= '0';
        end case;
    end process;

end architecture behavioral;