library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity datapath is
    port( 
        alu1_op : in alu_operation;
        alu2_op : in alu_operation;
        clk, rst: in std_logic; --Clock, reset
        mult1_mux1  : in std_logic;    -- Multiplexer of the first operand of the first multiplier
        mult1_mux2  : in std_logic_vector (1 downto 0);    
        mult2_mux1  : in std_logic;    -- Multiplexer of the first operand of the second multiplier
        mult2_mux2  : in std_logic;
        alu1_mux1   : in std_logic;
        reg_mux     : in std_logic;    -- Multiplexer leading to every register
        reg_enable  : in std_logic_vector (5 downto 0);     -- Enable of the 6 registers
        res : out std_logic_vector (31 downto 0)
    ); 
end datapath;

architecture behavioral of datapath is
    -- Six registers numbered 1 through 6
    type reg_out_t is array (5 downto 0) of std_logic_vector(31 downto 0);
    signal reg_out : reg_out_t;  -- Outputs of the registers
    -- ALU inputs
    signal alu1_in1, alu1_in2, alu2_in1, alu2_in2 : std_logic_vector(31 downto 0);
    -- ALU outputs
    signal alu1_out, alu2_out : std_logic_vector(31 downto 0);
    -- Same for multipliers
    signal mult1_in1, mult1_in2, mult2_in1, mult2_in2 : std_logic_vector(31 downto 0);
    signal mult1_out, mult2_out : std_logic_vector(31 downto 0);

    component alu
        port(
            operand1, operand2 : in std_logic_vector (31 downto 0);
            operator : in alu_operation;
            result : out std_logic_vector (31 downto 0)
            );
    end component;

    component multiplier
        port (
            operand1, operand2 : in std_logic_vector (31 downto 0);
            result : out std_logic_vector (31 downto 0)
        );
    end component;

    component reg32
		port(
			clk : in std_logic;
			D : in std_logic_vector (31 downto 0);
			Q : out std_logic_vector (31 downto 0);
			rst, en : in std_logic
		);
	end component;
                
begin
    alu1 : alu port map(    -- Mapping the ports of the ALU1 instance to the signals
        operand1 => alu1_in1,
        operand2 => alu1_in2,
        operator => alu1_op,
        result => alu1_out
    ); 
    alu2 : alu port map(    -- Mapping the ports of the ALU2 instance to the signals
        operand1 => alu2_in1,
        operand2 => alu2_in2,
        operator => alu2_op,
        result => alu2_out
    );

    mult1 : multiplier port map (
        operand1 => mult1_in1,
        operand2 => mult1_in2,
        result => mult1_out
    );
    mult2 : multiplier port map (
        operand1 => mult2_in1,
        operand2 => mult2_in2,
        result => mult2_out
    );

	-- Six registers, each mapping to their output signal and enable bit
	-- as well as their input being one of the arithmetic units
    reg1 : reg32 port map (
        clk => clk,
        D => mult2_out,
        rst => rst, en => reg_enable(R1_IDX),
        Q => reg_out(R1_IDX)
    );
    reg2 : reg32 port map (
        clk => clk,
        D => mult1_out,
        rst => rst, en => reg_enable(R2_IDX),
        Q => reg_out(R2_IDX)
    );
    reg3 : reg32 port map (
        clk => clk,
        D => alu2_out,
        rst => rst, en => reg_enable(R3_IDX),
        Q => reg_out(R3_IDX)
    );
    reg4 : reg32 port map (
        clk => clk,
        D => alu1_out,
        rst => rst, en => reg_enable(R4_IDX),
        Q => reg_out(R4_IDX)
    );
    reg5 : reg32 port map (
        clk => clk,
        D => alu2_out,
        rst => rst, en => reg_enable(R5_IDX),
        Q => reg_out(R5_IDX)
    );
    reg6 : reg32 port map (
        clk => clk,
        D => mult1_out,
        rst => rst, en => reg_enable(R6_IDX),
        Q => reg_out(R6_IDX)
    );
        
        
end behavioral;