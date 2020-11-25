library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;


entity datapath is
    port (
        clk :       in std_logic;
        reset :     in std_logic;
        data_in :   in complex_matrix
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

    -- Array of registers of the first layer - Stores the 8 matrix values from the memory
    type ra1 is array (7 downto 0) of std_logic_vector (11 downto 0);
    signal reg_array1_in, reg_array1_out : ra1;
    -- Second layer - Stores the 2 mult results and the accumulator
    type ra2 is array (4 downto 0) of std_logic_vector (31 downto 0);
    signal reg_array2_in, reg_array2_out : ra2;
    -- Third layer - Stores the absolute values of the subtraction and the max and min values
    type ra3 is array (3 downto 0) of std_logic_vector (31 downto 0);
    signal reg_array3_in, reg_array3_out : ra3;
    -- Stores the max and min indexes
    type ra3_idx is array (1 downto 0) of std_logic_vector (2 downto 0);
    signal reg_array3_idx_in, reg_array3_idx_out : ra3_idx;

    -- Output of the subtractor, input of the abs
    signal sub_out : std_logic_vector (31 downto 0);
    -- Output of the abs value
    signal abs_out : std_logic_vector (31 downto 0);
    -- Input and output of the accumulator
    signal accum_in, accum_out : std_logic_vector (31 downto 0);
    -- Output of the adder, input of the comparators and multiplexers
    signal add_out : std_logic_vector (31 downto 0);

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
    -- Last register is different - accumulator
    reg_accum : reg
        generic map (N => 32)
        port map (
            clk => clk,
            D   => accum_out,
            Q   => accum_in
        )
    -- The accumulator adder
    accum : fp_adder
        generic map (I => 14, F => 18)
        port map (
            operand1    => accum_in,
            operand2    => sub_out,
            result      => accum_out
        )

    
end architecture behavioral;