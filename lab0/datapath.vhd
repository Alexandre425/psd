library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is
    port
    (
        a   : in std_logic_vector (7 downto 0);         -- input data
        oper: in std_logic_vector (1 downto 0);         -- operand selection ("opcode")
        clk, en_accum, rst_accum: in std_logic;   -- accumulator control signals
        res : out std_logic_vector (7 downto 0)         -- result of the operation
    );
end datapath;

architecture behavioral of datapath is
    signal addsub, logic_and, res_alu : std_logic_vector (7 downto 0);  -- result of data operations
    signal addsub_sg, a_sg, accum_sg : signed (7 downto 0);             -- inputs for units that operate on signed data
    signal accum : std_logic_vector (7 downto 0) := (others => '0');      -- initializes the accumulator as 0
    
    begin
        -- Convert to signals to the proper type
        a_sg <= signed(a);
        accum_sg <= signed(accum);
        addsub <= std_logic_vector(addsub_sg);
        
        -- Adder/subtractor unit
        addsub_sg <= accum_sg + a_sg when oper(0) = '0' else    -- Add or subtract depending on the operator signal
                     accum_sg - a_sg;
        -- Logic unit
        logic_and <= a and accum;
        -- Output multiplexer
        res_alu <= addsub when oper(1) = '0' else
                   logic_and;
        -- Accumulator
        process(clk)
        begin
            if clk'event and clk = '1' then     -- On a positive edge clock event
                if rst_accum = '1' then
                    accum <= X"00";
                elsif en_accum = '1' then
                    accum <= res_alu;
                end if;
            end if;
        end process;
        
        -- Output
        res <= accum;
end behavioral;
