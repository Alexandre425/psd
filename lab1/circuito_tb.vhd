LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE ieee.numeric_std.ALL;
use work.common.all;

ENTITY circuito_tb IS
END circuito_tb;

ARCHITECTURE behavior OF circuito_tb IS

    -- Component Declaration for the Unit Under Test 
    component circuito is
        port (
            clk         : in  std_logic;
            buttons     : in  std_logic_vector(4 downto 0);
            ent         : in  std_logic_vector(7 downto 0);
            res         : out std_logic_vector(7 downto 0);
            oper_disp   : out std_logic_vector(3 downto 0)
        );
    end component;
    
    -- Inputs
    signal clk_in: std_logic := '0';
    signal buttons_in: std_logic_vector (4 downto 0) := (others => '0');
    signal ent_in: std_logic_vector (7 downto 0);
    -- Outputs
    signal res_out: std_logic_vector (7 downto 0);
    signal oper_disp_out: std_logic_vector (3 downto 0);

    -- Clock period definitions
    CONSTANT clk_period : time := 10 ns;
  
BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : circuito PORT MAP (
        clk         => clk_in,
        buttons     => buttons_in,
        ent         => ent_in,
        res         => res_out,
        oper_disp   => oper_disp_out
    );
    
    
    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk_in <= '0';
        WAIT FOR clk_period/2;
        clk_in <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Do nothing
        wait for 100 ns;
       
       -- Reset
        buttons_in <= "10000";
        wait for 100ns;
        buttons_in <= "00000";
        
        -- Insert the second operand
        ent_in <= x"02";
        wait for 100ns;
        
        -- Press the enter button
        buttons_in <= "00100";
        wait for 100ns;
        buttons_in <= "00000";
        
        -- Insert the first operand
        ent_in <= x"0A";
        wait for 100ns;
        
        -- Press enter (perform the sum)
        buttons_in <= "00100";
        wait for 100ns;
        buttons_in <= "00000";
        
         -- Press forward (advance to multiplication)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
       
        -- Press enter to perform the multiplication 
        buttons_in <= "00100";
        wait for 100ns;
        buttons_in <= "00000";
        
         -- Press forward (advance to Multiplication)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
         -- Press forward (advance to Or)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
        
         -- Press enter to perform the OR 
        buttons_in <= "00100";
        wait for 100ns;
        buttons_in <= "00000";
        
         -- Press forward (advance to multiplication)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
        -- Press forward (advance to OR)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
        -- Press forward (advance to RTR)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
        -- Press enter to perform the RTR 
        buttons_in <= "00100";
        wait for 100ns;
        buttons_in <= "00000";
        
        -- Press forward (advance to multiplication)
        buttons_in <= "01000";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
        -- Press backwards (go back to add)
        buttons_in <= "00010";
        wait for 100ns;
        buttons_in <= "00000";
        wait for 100 ns;
        
        -- Press enter to perform the sum 
        buttons_in <= "00100";
        wait for 100ns;
        buttons_in <= "00000";
        
        -- Reset again
        buttons_in <= "10000";
        wait for 100ns;
        buttons_in <= "00000";     
        
        wait;


    END PROCESS;

END;
