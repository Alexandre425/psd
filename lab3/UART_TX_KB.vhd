library IEEE;
use IEEE.STD_LOGIC_1164.all;

--The IEEE.std_logic_unsigned contains definitions that allow
--std_logic_vector types to be used with the + operator to instantiate a
--counter.
use IEEE.std_logic_unsigned.all;

entity UART_TX_KB is
  port(
    CLK      : in  std_logic;
    RESET    : in  std_logic;
    START_TX : in  std_logic;
    RD_ADDR  : out std_logic_vector (9 downto 0);
    RD_DATA  : in  std_logic_vector (7 downto 0);
    TX_OUT   : out std_logic);
end entity UART_TX_KB;

architecture Behavioral of UART_TX_KB is

  component UART_TX_1B
    port(
      SEND    : in  std_logic;
      DATA    : in  std_logic_vector(7 downto 0);
      CLK     : in  std_logic;
      READY   : out std_logic;
      UART_TX : out std_logic
      );
  end component;


  component UART_CTRL
    port (
      CLK            : in  std_logic;
      RESET          : in  std_logic;
      START_TX      : in  std_logic;
      UART_TX_RDY    : in  std_logic;
      UART_TX_SEND : out std_logic;
      RD_ADDR        : out std_logic_vector(9 downto 0)
      );
  end component UART_CTRL;

  signal tx_send  : std_logic;
  signal tx_ready : std_logic;

begin  -- architecture Behavioral


--Component used to send a byte of data over a UART line.
  UART_TX_1B_1 : UART_TX_1B port map(
    SEND    => tx_send,
    DATA    => RD_DATA,
    CLK     => CLK,
    READY   => tx_ready,
    UART_TX => TX_OUT
    );


--Component used to control the UART transmission of 1Kb of 8b words
  UART_CTRL_1 : UART_CTRL port map (
    CLK          => CLK,
    RESET        => RESET,
    START_TX     => START_TX,
    UART_TX_RDY  => tx_ready,
    UART_TX_SEND => tx_send,
    RD_ADDR      => RD_ADDR
    );

end architecture Behavioral;
