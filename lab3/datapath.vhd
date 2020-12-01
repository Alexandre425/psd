library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity datapath is
    port (
        clk :           in std_logic;
        reset :         in std_logic;
        enable :        in std_logic;   -- Enables saving new values to the registers
        a, b, c, d :    in std_logic_vector (31 downto 0);  -- Matrix values
        idx:            in std_logic_vector (2 downto 0);
        det :           out complex_num;
        min_idx_out :   out std_logic_vector (2 downto 0);  -- Index of the matrix with the smallest determinant
        max_idx_out :	out std_logic_vector (2 downto 0);  -- With the largest
        avg_det :       out complex_num                     -- Average of the determinant
    );
end entity datapath;

architecture behavioral of datapath is
    
    component comp_fp_multiplier
        port(
            operand1_r, operand1_i, operand2_r, operand2_i : in std_logic_vector (5+7-1 downto 0);  -- Operands
            result_r, result_i : out std_logic_vector (11+14-1 downto 0) -- Result of operation
        );
    end component;

    component fp_adder
        generic(
            I : integer := 5; F : integer := 7
        );
        port(
            operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result : out std_logic_vector (I+F downto 0)      -- Result of operation
        );
    end component;

    component fp_subtractor
        generic(
            I : integer := 5; F : integer := 7
        );
        port(
            operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result : out std_logic_vector (I+F downto 0)      -- Result of operation
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


    -- Output of the complex multipliers
    type q11_14 is array (1 downto 0) of std_logic_vector (11+14-1 downto 0);
    type multout is array (1 downto 0) of q11_14;
    signal mult_out : multout;
    -- Output of the subtractors and absolute value
    type q12_14 is array (1 downto 0) of std_logic_vector (12+14-1 downto 0);
    signal sub_out, abs_out : q12_14;
    -- Register array for the accumulator
    type q12_17 is array (1 downto 0) of std_logic_vector (12+17-1 downto 0);
    signal accum_array_in, accum_array_out : q12_17;
    -- Register array for the min and max determinant values
    type q13_14 is array (1 downto 0) of std_logic_vector (13+14-1 downto 0);
    signal minmax_array_in, minmax_array_out : q13_14;
    signal add_out : std_logic_vector (13+14-1 downto 0);
    -- Register array for the index of the min and max determinant matrices
    type idxreg is array (1 downto 0) of std_logic_vector (2 downto 0);
    signal idx_array_in, idx_array_out : idxreg;
    -- Result of the comparisons
    signal max_cmp, min_cmp : std_logic;
    -- To control the enable of the minmax registers
    signal max_reg_en, min_reg_en : std_logic;
    -- The enable of the min and max index registers
    signal max_idx_reg_en, min_idx_reg_en : std_logic;

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
            generic map (N => 12+17)
            port map (
                clk => clk, reset => reset, enable => enable,
                D   => accum_array_in(I),
                Q   => accum_array_out(I)
            );
        -- The accumulator adders
        accum : fp_adder
            generic map (I => 11, F => 17)
            port map (
                operand1 (11+17-1) => sub_out(I)(25),   -- Extend the signal bit
                operand1 (11+17-2) => sub_out(I)(25),
                operand1 (9+17-1 downto 0) => sub_out(I),
                operand2    => accum_array_out(I) (11+17-1 downto 0),   -- Last bit is discarded, shouldn't matter
                result      => accum_array_in(I)
            );
        -- The subtractor (performs a*d - b*c)
        sub : fp_subtractor
            generic map (I => 11, F => 14)
            port map (
                operand1    => mult_out(0)(I),  -- ad   NOTE:   I = 0 makes the real subtractor
                operand2    => mult_out(1)(I),  -- bc           I = 1 makes imaginary subtractor
                result      => sub_out(I)
            );
        -- Taking the absolute value of the determinant (of the real and imaginary parts)
        abs_out(I) <= std_logic_vector(abs(signed(sub_out(I))));
        -- Outputting the average in Q14.18 format
        avg_det(I) <= accum_array_out(I)(28) & accum_array_out(I)(28) & accum_array_out(I) & '0';
        -- Outputting the determinant in Q14.18 format
        det(I) <= sub_out(I)(25) & sub_out(I)(25) & sub_out(I) & "0000";
    end generate accum_gen;

    -- The abs value adder
    accum : fp_adder
        generic map (I => 12, F => 14)
        port map (
            operand1    => abs_out(0),
            operand2    => abs_out(1),
            result      => add_out
        );

    -- The val > max branch
    comp_max : comparator
        generic map (N => 13+14)
        port map (
            operand1    => add_out,
            operand2    => minmax_array_out(MAX_IDX),
            result      => max_cmp
        );
    max_reg_en <= (enable and max_cmp) or reset;
    -- The min and max value registers don't need to reset, as resetting them should load
    --  the minimum and max values possible, not 0. So the reset bit instead enables them,
    --  and selects 0 or +inf on their input.
    reg_max : reg
        generic map (N => 13+14)
        port map (
            clk => clk, reset => '0', enable => max_reg_en,   -- Write to the max val register on a new greater val or a reset
            D   => minmax_array_in(MAX_IDX),
            Q   => minmax_array_out(MAX_IDX)
        );
    max_idx_reg_en <= enable and max_cmp;
    reg_max_idx : reg
        generic map (N => 3)
        port map (
            clk => clk, reset => reset, enable => max_idx_reg_en,
            D   => idx,
            Q   => idx_array_out(MAX_IDX)
        );
    with reset select minmax_array_in(MAX_IDX) <=
        add_out                     when '0',       -- When not resetting, store the new value (if the register is enabled)
        (others => '0')             when others;    -- When resetting, store 0 (the minimum value)
    -- The val < min branch
    comp_min : comparator
        generic map (N => 13+14)
        port map (
            operand1    => minmax_array_out(MIN_IDX),
            operand2    => add_out,
            result      => min_cmp
        );
    min_reg_en <= (enable and min_cmp) or reset;
        reg_min : reg
        generic map (N => 13+14)
        port map (
            clk => clk, reset => '0', enable => min_reg_en,   -- Write to the max val register on a new greater val or a reset
            D   => minmax_array_in(MIN_IDX),
            Q   => minmax_array_out(MIN_IDX)
        );
    min_idx_reg_en <= enable and min_cmp;
    reg_min_idx : reg
        generic map (N => 3)
        port map (
            clk => clk, reset => reset, enable => min_idx_reg_en,
            D   => idx,
            Q   => idx_array_out(MIN_IDX)
        );
    with reset select minmax_array_in(MIN_IDX) <=
        add_out                     when '0',
        (others => '1')             when others;    -- When resetting, store +inf
    
end architecture behavioral;