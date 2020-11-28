library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity datapath is
    port (
        clk :           in std_logic;
        reset :         in std_logic;
        a, b, c, d :    in std_logic_vector (31 downto 0);  -- Matrix values
        idx:            in std_logic_vector (2 downto 0);
        min_idx_out, max_idx_out :	out std_logic_vector (2 downto 0);  -- The indexes of the matrices with the min and max det
        avg_det :       out complex_num     -- Average of the determinant
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
            clk, reset, enable : in std_logic;
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

    -- Register array for the accumulator
    type accreg is array (1 downto 0) of std_logic_vector (31 downto 0);
    signal accum_array_in, accum_array_out : accreg;
    -- Register array for the min and max determinant values
    type mmreg is array (1 downto 0) of std_logic_vector (31 downto 0);
    signal minmax_array_in, minmax_array_out : mmreg;
    -- Register array for the index of the min and max determinant matrices
    type idxreg is array (1 downto 0) of std_logic_vector (2 downto 0);
    signal idx_array_in, idx_array_out : idxreg;

    -- Output of the complex multipliers, feeds the subtractors
    type mulout is array (1 downto 0) of complex_num;
    signal mult_out : mulout;
    -- Output of the subtractor and the accumulator adder
    signal sub_out, accum_out, abs_out : complex_num;
    -- Output of the adder
    signal add_out, new_max, new_min: std_logic_vector (31 downto 0);
    -- Result of the comparisons
    signal max_cmp, min_cmp : std_logic;
    -- To control the enable of the minmax registers
    signal max_cmp_or_rst, min_cmp_or_rst : std_logic;

begin

    -- Complex multipliers
    comp_mult_1 : comp_fp_multiplier    -- Doing a*d
        port map (
            operand1_r  => a (27 downto 16),    -- Get the real 12 bit portion of the 32 bit complex number
            operand1_i  => a (11 downto 0),     -- Get the imaginary portion
            operand2_r  => d (27 downto 16),
            operand2_i  => d (11 downto 0),
            result_r    => mult_out(0)(REAL_PART),
            result_i    => mult_out(0)(IMAGINARY_PART)
        );
    comp_mult_2 : comp_fp_multiplier    -- Doing b*c
        port map (
            operand1_r  => b (27 downto 16),
            operand1_i  => b (11 downto 0),
            operand2_r  => c (27 downto 16),
            operand2_i  => c (11 downto 0),
            result_r    => mult_out(1)(REAL_PART),
            result_i    => mult_out(1)(IMAGINARY_PART)
        );

    -- Accumulator and subtractor
    accum_gen : for I in 0 to 1 generate
        -- Accumulator registers
        reg_accum : reg
            generic map (N => 32)
            port map (
                clk => clk, reset => reset, enable => '1',
                D   => accum_array_in(I),
                Q   => accum_array_out(I)
            );
        -- The accumulator adders
        accum : fp_adder
            generic map (I => 14, F => 18)
            port map (
                operand1    => sub_out(I),
                operand2    => accum_array_out(I),
                result      => accum_array_in(I)
            );
        -- The subtractor (performs a*d - b*c)
        sub : fp_subtractor
            generic map (I => 14, F => 18)
            port map (
                operand1    => mult_out(0)(I),  -- ad   NOTE:   I = 0 makes the real subtractor
                operand2    => mult_out(1)(I),  -- bc           I = 1 makes imaginary subtractor
                result      => sub_out(I)
            );
        -- Taking the absolute value of the determinant (of the real and imaginary parts)
        abs_out(I) <= std_logic_vector(abs(signed(sub_out(I))));
        -- Outputting the average (accumulator divided by 8 / shifted by 3)
        avg_det(I) <= std_logic_vector(shift_right(signed(accum_array_out(I)),3));
    end generate accum_gen;

    -- The abs value adder
    accum : fp_adder
        generic map (I => 14, F => 18)
        port map (
            operand1    => abs_out(0),
            operand2    => abs_out(1),
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
    max_cmp_or_rst <= max_cmp or reset;
    reg_max : reg
        generic map (N => 32)
        port map (
            clk => clk, reset => reset, enable => max_cmp_or_rst,   -- Write to the max val register on a new greater val or a reset
            D   => minmax_array_in(MAX_IDX),
            Q   => minmax_array_out(MAX_IDX)
        );
    reg_max_idx : reg
        generic map (N => 3)
        port map (
            clk => clk, reset => reset, enable => max_cmp,
            D   => idx,
            Q   => idx_array_out(MAX_IDX)
        );
    with reset select minmax_array_in(MAX_IDX) <=
        add_out                     when '0',       -- When not resetting, store the new value (if the register is enabled)
        x"00000000"                 when others;    -- When resetting, store 0 (the minimum value)
    -- The val < min branch
    comp_min : comparator
        generic map (N => 32)
        port map (
            operand1    => add_out,
            operand2    => minmax_array_out(MIN_IDX),
            result      => min_cmp
        );
    min_cmp_or_rst <= min_cmp_or_rst or reset;
    reg_min : reg
        generic map (N => 32)
        port map (
            clk => clk, reset => reset, enable => min_cmp_or_rst,   -- Write to the max val register on a new greater val or a reset
            D   => minmax_array_in(MIN_IDX),
            Q   => minmax_array_out(MIN_IDX)
        );
    reg_min_idx : reg
        generic map (N => 3)
        port map (
            clk => clk, reset => reset, enable => min_cmp,
            D   => idx,
            Q   => idx_array_out(MIN_IDX)
        );
    with reset select minmax_array_in(MIN_IDX) <=
        add_out                     when '0',
        x"FFFFFFFF"                 when others;    -- When resetting, store +inf
    
end architecture behavioral;