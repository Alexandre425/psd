library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity datapath is
    port (
        clk :       in std_logic;
        reset :     in std_logic;
        data_in :   in complex_matrix;
        max_sel :   in std_logic;   -- Controls wether the max/min regs get loaded with +inf/-inf
        idx_offset: in std_logic_vector (2 downto 0)    -- Index of the value in the comparison layer
    );
end entity datapath;

architecture behavioral of datapath is
    
    component comp_fp_multiplier
        port(
            operand1_r, operand1_i, operand2_r, operand2_i : in std_logic_vector (11 downto 0);  -- Operands
            result_r, result_i : out std_logic_vector (31 downto 0) -- Result of operation
        );
    end component;

    component fp_adder
        generic(
            I : integer := 5; F : integer := 7
        );
        port(
            operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result : out std_logic_vector (I+F-1 downto 0)      -- Result of operation
        );
    end component;

    component fp_subtractor
        generic(
            I : integer := 5; F : integer := 7
        );
        port(
            operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result : out std_logic_vector (I+F-1 downto 0)      -- Result of operation
        );
    end component;
    
    component reg is
        generic (
            N : integer := 12
        );
        port(
            clk : in std_logic;
            D : in std_logic_vector (N-1 downto 0);
            Q : out std_logic_vector (N-1 downto 0)
        );
    end component;

    component comparator is
        generic (
            N : integer := 8
        );
        port(
            operand1, operand2 : in std_logic_vector (N-1 downto 0);
            result : out std_logic
        );
    end component;

    constant MIN_IDX : integer := 0;
    constant MAX_IDX : integer := 1;

    -- Array of registers of the first layer - Stores the 8 matrix values from the memory
    type ra1 is array (7 downto 0) of std_logic_vector (11 downto 0);
    signal reg_array1_in, reg_array1_out : ra1;
    -- Second layer - Stores the 2 mult results and the accumulator
    type ra2 is array (4 downto 0) of std_logic_vector (31 downto 0);
    signal reg_array2_in, reg_array2_out : ra2;
    -- Accumulator registers
    type ac2 is array (1 downto 0) of std_logic_vector (31 downto 0);
    signal accum_array_in, accum_array_out : ac2;
    -- Third layer - Stores the absolute values of the subtraction and the min and max values
    type ra3 is array (1 downto 0) of std_logic_vector (31 downto 0);
    signal reg_array3_in, reg_array3_out : ra3;
    signal minmax_array_in, minmax_array_out : ra3;
    -- Stores the min and max indexes
    type ra3_idx is array (1 downto 0) of std_logic_vector (2 downto 0);
    signal idx_array_in, idx_array_out : ra3_idx;

    -- Output of the subtractor, input of the abs
    type sub_abs is array (1 downto 0) of std_logic_vector (1 downto 0);
    signal sub_out : sub_abs;
    -- Output of the adder, input of the comparators and multiplexers
    signal add_out : std_logic_vector (31 downto 0);
    -- Result of the comparisons
    signal max_cmp, min_cmp : std_logic;
    -- Comparisons concatenated with max_sel for the multiplexer
    signal max_concat, min_concat : std_logic_vector (1 downto 0);

begin
    -- First layer
    -- Generate the first layer's registers
    layer1 : for I in 0 to 7 generate   -- yay for not having to type it 8 times :)
        reg_array1: reg
            generic map (N => 12)
            port map (
                clk => clk,
                D   => data_in(I),
                Q   => reg_array1_in(I)
            );
    end generate layer1;
    -- First layer's multipliers
    comp_mult_1 : comp_fp_multiplier
        port map (
            operand1_r  => reg_array1_out(0),   -- 11 * 22 or
            operand1_i  => reg_array1_out(1),   -- a * d
            operand2_r  => reg_array1_out(6),
            operand2_i  => reg_array1_out(7),
            result_r    => reg_array2_in(0),
            result_i    => reg_array2_in(1)
        );
    comp_mult_2 : comp_fp_multiplier
        port map (
            operand1_r  => reg_array1_out(2),   -- 12 * 21 or
            operand1_i  => reg_array1_out(3),   -- b * c
            operand2_r  => reg_array1_out(4),
            operand2_i  => reg_array1_out(5),
            result_r    => reg_array2_in(2),
            result_i    => reg_array2_in(3)
        );

    -- Second layer
    -- Generating the registers
    layer2 : for I in 0 to 3 generate
        reg_array2 : reg
            generic map (N => 32)
            port map (
                clk => clk,
                D   => reg_array2_in(I),
                Q   => reg_array2_out(I)
            );
    end generate layer2;
    -- Accumulator and subtractor
    accum_gen : for I in 0 to 1 generate
        -- Last registers are different - accumulator
        reg_accum : reg
            generic map (N => 32)
            port map (
                clk => clk,
                D   => accum_array_in(I),
                Q   => accum_array_out(I)
            );
        -- The accumulator adders
        accum : fp_adder
            generic map (I => 14, F => 18)
            port map (
                operand1    => accum_array_out(I),
                operand2    => sub_out(I),
                result      => accum_array_in(I)
            );
        -- The subtractor (performs a*d - b*c)
        sub : fp_subtractor
            generic map (I => 14, F => 18)
            port map (
                operand1    => reg_array2_out(2*I),     -- ad
                operand2    => reg_array2_out(2*I + 1), -- bc
                result      => sub_out(I)
            );
        -- Taking the absolute value of the determinant (of the real and imaginary parts)
        reg_array3_in(I) <= std_logic_vector(abs(signed(sub_out(I))));

    end generate accum_gen;

    -- Third layer
    -- The abs value adder
    accum : fp_adder
        generic map (I => 14, F => 18)
        port map (
            operand1    => reg_array2_out(0),
            operand2    => reg_array2_out(1),
            result      => add_out
        );
    -- The val > max branch
    comp_max : comparator
        generic map (N => 32)
        port map (
            operand1    => add_out,
            operand2    => minmax_array_out(MAX_IDX),
            result      => max_cmp
        );
    max_concat <= max_sel & max_cmp;
    with max_concat select minmax_array_in(MAX_IDX) <=
        minmax_array_out(MAX_IDX)   when "00",      -- When the result is not greater, feed it the same value
        add_out                     when "01",      -- When it's greater, update the value
        x"00000000"                 when others;    -- When max_sel, minimum possible value
    with max_cmp select idx_array_in(MAX_IDX) <=
        idx_array_out(MAX_IDX)  when '0',   -- Don't update the index
        idx_offset              when '1';   -- Update it
    -- The val < min branch
    comp_min : comparator
        generic map (N => 32)
        port map (
            operand1    => minmax_array_out(MIN_IDX),
            operand2    => add_out,
            result      => max_cmp
        );
    min_concat <= max_sel & min_cmp;
    with min_concat select minmax_array_in(MIN_IDX) <=
        minmax_array_out(MIN_IDX)   when "00",      -- When the result is not lesser, feed it the same value
        add_out                     when "01",      -- When it's lesser, update the value
        x"7FFFFFFF"                 when others;    -- When max_sel, maximum possible value
    with max_cmp select idx_array_in(MIN_IDX) <=
        idx_array_out(MIN_IDX)  when '0',   -- Don't update the index
        idx_offset              when '1';   -- Update it

    
end architecture behavioral;