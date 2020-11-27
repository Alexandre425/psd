library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity control is
    port (
        clk :       in std_logic;
        reset :     in std_logic;
        max_sel :   out std_logic;      -- Controls wether the max/min regs get loaded with +inf/-inf
        save_avg :  out std_logic;      -- Wether the average should be saved to the circuit buffer
        save_idx :  out std_logic;      -- Wether the indexes should be saved to the circuit buffer
        idx :       out std_logic_vector (2 downto 0);
        idx_offset: out std_logic_vector (2 downto 0)   -- Index of the value in the comparison layer
    );
end entity control;

architecture behavioral of control is
    type fsm_states is(
        S_START,            -- Start of the calculations, then after 4 steps ->
        S_UNLOCK_MIN_MAX,   -- Unlock the max and min calculators (data has reached the third layer)
        S_SAVE_AVG,         -- After the last det passes through the second layer, save the average
        S_SAVE_IDX,         -- After it passes through the third, save the indexes
        S_DONE              -- After that, stay here forever to prevent overwritting the saved values
    );
    signal state : fsm_states;
    signal counter, counter_offset : unsigned (2 downto 0);

begin

    process (clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then                     -- Set both to 0 on a reset
                counter <= (others => '0');
                counter_offset <= (others => '0');
            else
                counter <= counter + 1;             -- Otherwise increment the counter
                if state /= S_START then         -- Increment the offset counter when data reaches third layer
                    counter_offset <= counter_offset + 1;
                end if;
            end if;
        end if;
    end process;

    -- Outputting the counters
    idx <= std_logic_vector(counter);
    idx_offset <= std_logic_vector(counter_offset);

    process (clk, reset)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then     -- Synchronous reset
                state <= S_START;
            else                    -- If not reset
                case state is       -- Next state depends on state and counter
                    when S_START =>
                        if counter = "011" then
                            state <= S_UNLOCK_MIN_MAX;  -- Data reaches third layer
                        end if;
                    when S_UNLOCK_MIN_MAX =>
                        if counter = "010" then
                            state <= S_SAVE_AVG;        -- Data passes through second layer
                        end if;
                    when S_SAVE_AVG =>                  -- NOTE: Counter overflows! so "2" is actually 
                        state <= S_SAVE_IDX;            --  the 10th cycle
                    when S_SAVE_IDX =>
                        state <= S_DONE;
                    when S_DONE =>
                        state <= S_DONE;
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