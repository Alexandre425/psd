library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.common.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity circuito is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    instr   : in  std_logic_vector(2 downto 0);
    data_in : in  std_logic_vector(7 downto 0);
    res     : out std_logic_vector(7 downto 0)
    );
end circuito;

architecture behavioral of circuito is
    component control
        port(
            clk, rst : in  std_logic; --Clock e reset
            oper     : in  std_logic_vector (2 downto 0); --Instrução para a transição de estados na fsm
            enable   : out std_logic; 
            slct     : out alu_operation --Selecionar Operação
        );
  end component;
  component datapath
    port(
      a         : in  std_logic_vector(7 downto 0);
      oper      : in  std_logic_vector(1 downto 0);
      clk       : in  std_logic;
      en_accum  : in  std_logic;
      rst_accum : in  std_logic;
      res       : out std_logic_vector(7 downto 0)
      );
  end component;

  signal enable : std_logic;
  signal oper   : std_logic_vector(1 downto 0);

begin
    inst_control : control port map(
        clk    => clk,
        rst    => rst,
        enable => enable,
        oper   => oper
    );
    inst_datapath : datapath port map(
        a         => data_in,
        rst_accum => rst,
        en_accum  => enable,
        oper      => oper,
        clk       => clk,
        res       => res
    );

end Behavioral;

