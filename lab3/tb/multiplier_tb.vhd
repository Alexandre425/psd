library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity multiplier_tb is
end multiplier_tb;
    
architecture Behavioral of multiplier_tb is
    component comp_fp_multiplier
        port(
            operand1_r, operand1_i, operand2_r, operand2_i : in std_logic_vector (11 downto 0);  -- Operands
            result_r, result_i : out std_logic_vector (31 downto 0) -- Result of operation
        );
    end component;
        
    signal op1r, op1i, op2r, op2i, resr, resi: real := 0.0;	-- The values in fixed point representation
    signal operand1_r, operand1_i, operand2_r, operand2_i : std_logic_vector (11 downto 0);
    signal result_r, result_i : std_logic_vector (31 downto 0);
    
begin

    uut: comp_fp_multiplier port map(
        operand1_r => operand1_r,
        operand1_i => operand1_i,
        operand2_r => operand2_r,
        operand2_i => operand2_i,
        result_r => result_r, 
        result_i => result_i
    );


    stim_proc : process
    begin
        wait for 10ns;

        operand1_r <= "00010" & "0000000"; -- 2.0
        operand1_i <= "00000" & "0000000"; -- 0.0
        operand2_r <= "00110" & "0000000"; -- 6.0
        operand2_i <= "00000" & "0000000"; -- 0.0
        wait for 100ns;

        operand1_r <= "00010" & "0001100"; -- 2.?
        operand1_i <= "00000" & "0000000"; -- 0.0
        operand2_r <= "00010" & "0000000"; -- 2.0
        operand2_i <= "00000" & "0000000"; -- 0.0
        wait for 100ns;

        operand1_r <= "00011" & "0000001"; -- 3.?
        operand1_i <= "00010" & "0000000"; -- 2.0i
        operand2_r <= "00011" & "0000000"; -- 3.0
        operand2_i <= "00011" & "0000000"; -- 3.0i
        wait for 100ns;

        operand1_r <= "11101" & "0000001"; -- -3.?
        operand1_i <= "11110" & "0000000"; -- -2.0i
        operand2_r <= "11101" & "0000000"; -- -3.0
        operand2_i <= "00011" & "0000000"; --  3.0i
        wait for 100ns;

        wait;
    end process;
    
    op1r <= real(to_integer(signed(operand1_r))) / (real(2**7));
    op2r <= real(to_integer(signed(operand2_r))) / (real(2**7));
    op1i <= real(to_integer(signed(operand1_i))) / (real(2**7));
    op2i <= real(to_integer(signed(operand2_i))) / (real(2**7));
    resr <= real(to_integer(signed(result_r))) / (real(2**18));
    resi <= real(to_integer(signed(result_i))) / (real(2**18));

end Behavioral;
