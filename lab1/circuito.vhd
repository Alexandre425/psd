library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity circuito is
    port (
        clk         : in  std_logic;
        buttons     : in  std_logic_vector(4 downto 0);     -- Directional buttons
        ent         : in  std_logic_vector(7 downto 0);     -- Input data 
        res         : out std_logic_vector(7 downto 0);    -- 16 bits that go to the 7seg display
        oper_disp   : out std_logic_vector(3 downto 0)      -- Translates the alu operation to a number to display
        );
end circuito;

architecture behavioral of circuito is
    component control
        port (
            clk : in  std_logic; -- Clock e reset
            buttons  : in  std_logic_vector (4 downto 0); -- Input buttons
            enable   : out std_logic_vector (1 downto 0); -- Enable signals of the registers
            slct     : out alu_operation; --Selecionar Operação
            oper_disp: out std_logic_vector (3 downto 0)    -- Number of the operation to be performed
            );  
    end component;
    component datapath
        port( 
            ent : in std_logic_vector (7 downto 0); --Dados de entrada
            slct : in alu_operation; --Seleção da operação a realizar na ALU
            enable : in std_logic_vector (1 downto 0);  -- Enable signals of the registers
            clk, rst: in std_logic; --Clock, reset
            res : out std_logic_vector (7 downto 0) --Dados de entrada e saída do registo 2, ambos sinais a representar no display de 7 segmentos; Saída do registo 2 
            ); 
    end component;

    signal enable : std_logic_vector (1 downto 0);
    signal slct   : alu_operation;
    signal rst    : std_logic;
    signal slct_disp : std_logic;
    
    signal test2: std_logic_vector (7 downto 0);

begin
    inst_control : control port map(
        clk         => clk,
        buttons     => buttons,
        enable      => enable,
        slct        => slct,
        oper_disp   => oper_disp
    );
    inst_datapath : datapath port map(
        ent         => ent,
        slct        => slct,
        enable      => enable,
        rst         => buttons(BUT_RESET),
        clk         => clk,
        res         => res
    );
    

end Behavioral;

