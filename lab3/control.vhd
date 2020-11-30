library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity control is
    port (
        clk :       in std_logic;
        start :     in std_logic;
        reset :     in std_logic;
        enable :    out std_logic;  -- Enables the saving of new values on the datapath
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
        S_LOAD_D
    );
    signal state : fsm_states;
    signal idx_counter :    unsigned (2 downto 0);  -- Counts matrices 
    signal addr_counter :   unsigned (7 downto 0);  -- Counts memory addresses
    signal sync_counter :   unsigned (1 downto 0);  -- To help keep the control unit in sync with the quarter speed clock
    
begin

    process (clk, reset)
	begin
        if clk'event and clk = '1' then
            if reset = '1' then           	-- On a reset
                idx_counter     <= "000";   -- Reset the counters
                addr_counter    <= "00000000";
            else 
            	if state = S_LOAD_A then               	-- When loading A from the next matrix
                	idx_counter <= idx_counter + 1;         -- Increment the matrix count
               	end if;
            	if state /= S_WAIT and state /= S_WAIT_RELEASE then	-- When loading any value
                	addr_counter <= addr_counter + 1;       -- Increment the adress
                end if;
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
                        if idx_counter = "111" then -- If processing the last matrix
                            state <= S_WAIT;        -- Calculations finished
                        else                        -- If not
                            state <= S_LOAD_A;      -- Load the next matrix
                        end if;
                    when others =>
                        state <= S_WAIT;
                end case;
         	end if;
		end if;
    end process;

    process (state)
    begin
        case state is
            when S_WAIT =>
                enable      <= '0';     -- Don't write new values to the datapath registers
                buffer_fwd  <= '0';     -- Don't forward the first buffer
            when S_WAIT_RELEASE =>
                enable      <= '0';
                buffer_fwd  <= '0';   
            when S_FIRST_LOAD_A =>
                enable      <= '0';
                buffer_fwd  <= '0';
            when S_LOAD_A =>
                enable      <= '1';
                buffer_fwd  <= '1';
            when S_LOAD_B =>
                enable      <= '1';
                buffer_fwd  <= '0';
            when S_LOAD_C =>
                enable      <= '1';
                buffer_fwd  <= '0';
            when S_LOAD_D =>
                enable      <= '1';
                buffer_fwd  <= '0';
            when others =>
                enable      <= '0';
                buffer_fwd  <= '0';
        end case;
    end process;

end architecture behavioral;