library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity circuito is
    port (
        clk     : in  std_logic;
        reset   : in std_logic;                         -- Reset signal
        res     : out signed (31 downto 0);    -- 32 bits determinant
        addr    : out std_logic_vector (9 downto 0)    
    );
end circuito;

architecture behavioral of circuito is

    component MemIN is
        port (
            clk    : in  std_logic;
            addr   : in  std_logic_vector(9 downto 0);
            A, B, C, D, E, F : out std_logic_vector(15 downto 0)
        );
    end component;
    
    component control
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            alu1_op     : out alu_operation;
            alu2_op     : out alu_operation;
            mult1_mux1  : out std_logic;    -- Multiplexer of the first operand of the first multiplier
            mult1_mux2  : out std_logic_vector (1 downto 0);    
            mult2_mux1  : out std_logic;    -- Multiplexer of the first operand of the second multiplier
            mult2_mux2  : out std_logic;
            alu1_mux1   : out std_logic;
            reg_mux     : out std_logic;    -- Multiplexer leading to every register
            reg_enable  : out std_logic_vector (5 downto 0);    -- Enable of the 6 registers
            addr        : out std_logic_vector (9 downto 0);    -- Counter used to address memory
            write_en    : out std_logic     -- Write enable
        );  
    end component;
    
    component datapath
        port( 
            A, B, C, D, E, F : in std_logic_vector (15 downto 0); -- Input data from memory
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
            res : out signed (31 downto 0)
            ); 
    end component;

    -- Operation selection for the ALU
    signal slctALU1   : alu_operation;
    signal slctALU2   : alu_operation;
    -- Input multiplexers
    signal mult1_mux1  : std_logic; 
    signal mult1_mux2  : std_logic_vector(1 downto 0); 
    signal mult2_mux1  : std_logic;
    signal mult2_mux2  : std_logic; 
    signal alu1_mux1  : std_logic; 
    -- Input multiplexers of the registers (to select arith unit or ABCDF)
    signal reg_mux : std_logic; 
    signal reg_enable : std_logic_vector(5 downto 0);
    -- Input data form MemIN to the datapath
    signal A_in: std_logic_vector (15 downto 0);
    signal B_in: std_logic_vector (15 downto 0);
    signal C_in: std_logic_vector (15 downto 0);
    signal D_in: std_logic_vector (15 downto 0);
    signal E_in: std_logic_vector (15 downto 0);
    signal F_in: std_logic_vector (15 downto 0);

    -- Memory address
    signal addr_buf : std_logic_vector (9 downto 0);
    
begin
    mem_in : MemIN port map(
        clk => clk,
        addr => addr_buf,
        A => A_in,
        B => B_in,
        C => C_in,
        D => D_in,
        E => E_in,
        F => F_in
    );
    
    inst_control : control port map(
        clk => clk,
        reset => reset,
        alu1_op => slctALU1,
        alu2_op => slctALU2,
        mult1_mux1 => mult1_mux1,   
        mult1_mux2 => mult1_mux2,
        mult2_mux1 => mult2_mux1,
        mult2_mux2 => mult2_mux2,
        alu1_mux1 => alu1_mux1,
        reg_mux => reg_mux,
        reg_enable => reg_enable,
        addr => addr_buf
    );
    inst_datapath : datapath port map(
        A => A_in,
        B => B_in,
        C => C_in,
        D => D_in,
        E => E_in,
        F => F_in,
        alu1_op => slctALU1,
        alu2_op => slctALU2,
        clk => clk,
        rst => reset,
        mult1_mux1 => mult1_mux1,   
        mult1_mux2 => mult1_mux2,
        mult2_mux1 => mult2_mux1,
        mult2_mux2 => mult2_mux2,
        alu1_mux1 => alu1_mux1,
        reg_mux => reg_mux,
        reg_enable => reg_enable,
        res => res
    );
    
    addr <= addr_buf;

end Behavioral;

