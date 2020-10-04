library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.common.all;

entity alu is
    port(
        operand1, operand2 : in std_logic_vector (7 downto 0);
        operator : in alu_operation;
        result : out std_logic_vector (7 downto 0)
        -- clk : in std_logic -- Probably doesn't actually need a clock
    );
end alu;

architecture Behavioral of alu is
    signal arith_in1, arith_in2 : unsigned (7 downto 0);
    signal add_out, mult_out : unsigned (7 downto 0);
    signal or_out, rtr_out: std_logic_vector (7 downto 0);
    
begin
    -- Data conversion
    arith_in1 <= unsigned(operand1);
    arith_in2 <= unsigned(operand2);
    
    -- Adder
    add_out <= arith_in1 + arith_in2;
    -- Multiplier
    mult_out <= arith_in1 * arith_in2;
    -- Logic OR
    or_out <= operand1 or operand2;
    -- Rotate right
    rtr_out <= operand2(0) & operand2(7 downto 1);
    
    -- Output multiplexing
    with operator select
        result <=
            std_logic_vector(add_out)   when ALU_ADD,
            std_logic_vector(mult_out)  when ALU_MULT, 
            or_out                      when ALU_OR,
            rtr_out                     when ALU_RTR,
            X"00"                       when others;    
    

end Behavioral;
