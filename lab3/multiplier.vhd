library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fp_multiplier is
    generic (
        I : integer := 5; F : integer := 7);
    )
    port(
        operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
        result : out std_logic_vector (I*2 + F*2 + 1 downto 0)      -- Result of operation
    );
end fp_multiplier;

architecture behavioral of fp_multiplier is
begin
    c <= std_logic_vector(signed(operand1) * signed(operand2))
end behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comp_fp_multiplier is
    generic (
        I : integer := 5; F : integer := 7);
    )
    port(
        operand1_r, operand1_i, operand2_r, operand2_i : in std_logic_vector (I+F-1 downto 0);  -- Operands
        result_r, result_i : out std_logic_vector (I*2 + F*2 + 1 downto 0)          -- Result of operation
    );
end comp_fp_multiplier;

architecture behavioral of comp_fp_multiplier is
    component fp_multiplier
        generic (
            I : integer := 5; F : integer := 7);
        );
        port(
            operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result : out std_logic_vector (I*2 + F*2 + 1 downto 0)      -- Result of operation
        );
    end component;
    component fp_adder
        generic (
            I : integer := 5; F : integer := 7);
        );
        port(
            operand1, operand2 : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result : out std_logic_vector (I*2 + F*2 + 1 downto 0)      -- Result of operation
        );
    end component;
    component fp_subtractor
        generic (
            I : integer := 5; F : integer := 7);
        )
        port(
            operand1_r, operand1_i, operand2_r, operand2_i : in std_logic_vector (I+F-1 downto 0);  -- Operands
            result_r, result_i : out std_logic_vector (I*2 + F*2 + 1 downto 0)          -- Result of operation
        );
    end component;

    signal ac : std_logic_vector(10+14-1 downto 0);
    signal bd : std_logic_vector(10+14-1 downto 0);
    signal ad : std_logic_vector(10+14-1 downto 0);
    signal bc : std_logic_vector(10+14-1 downto 0);
begin

    mult_ac : fp_multiplier
        generic map (I => 5, F => 7);
        port map    (operand1 => a, operand2 => c, result => ac);
    mult_bd : fp_multiplier
        generic map (I => 5, F => 7);
        port map    (operand1 => b, operand2 => d, result => bd);
    mult_ad : fp_multiplier
        generic map (I => 5, F => 7);
        port map    (operand1 => a, operand2 => d, result => ad);
    mult_bc : fp_multiplier
        generic map (I => 5, F => 7);
        port map    (operand1 => b, operand2 => c, result => bc);
    sub : fp_subtractor
        generic map (I => 14, F => 18);
        port map    (
            -- Q10.14 to Q14.18 conversion
            -- Pad the int part with the signal
            -- Pad the end of the fractional part with zeros
            operand1 => ac(23)&ac(23)&ac(23)&ac(23) & ac(23 downto 0) & (others=>0),
            operand2 => bd(23)&bd(23)&bd(23)&bd(23) & bd(23 downto 0) & (others=>0),
            result => result_r
        )
    add : fp_adder
        generic map (I => 14, F => 18);
        port map    (
            -- Q10.14 to Q14.18 conversion
            -- Pad the int part with the signal
            -- Pad the end of the fractional part with zeros
            operand1 => ad(23)&ad(23)&ad(23)&ad(23) & ad(23 downto 0) & (others=>0),
            operand2 => bc(23)&bc(23)&bc(23)&bc(23) & bc(23 downto 0) & (others=>0),
            result => result_i
        )

end behavioral ; -- behavioral