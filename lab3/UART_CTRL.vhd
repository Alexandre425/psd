library IEEE;
use IEEE.STD_LOGIC_1164.all;

--The IEEE.std_logic_unsigned contains definitions that allow
--std_logic_vector types to be used with the + operator to instantiate a
--counter.
use IEEE.std_logic_unsigned.all;


entity UART_CTRL is
  port (
    CLK          : in  std_logic;
    RESET        : in  std_logic;
    START_TX     : in  std_logic;
    UART_TX_RDY  : in  std_logic;
    UART_TX_SEND : out std_logic;
    RD_ADDR      : out std_logic_vector(9 downto 0)
    );
end entity UART_CTRL;


architecture Behavioral of UART_CTRL is

  --Contains the length of the memory block sent over uart.
--  constant ADDRESS_END : natural := 1024;
  --constant ADDRESS_END : std_logic_vector(9 downto 0) := (others => '1');
  constant ADDRESS_END : std_logic_vector(10 downto 0) := "10000000000"; -- 1024b

-- The type definition for the UART state machine type. Here is a description of what
--occurs during each state:
-- RST_REG     -- Do Nothing. This state is entered after configuration or a user reset.
--                The state is set to READY_SEND.
-- READY_SEND  -- without start start btn pressed goto WAIT_BTN
-- SEND_BYTE   -- uartSend is set high for a single clock cycle, signaling the character
--                data at sendStr(readAddress) to be registered by the UART_TX_CTRL at the next
--                cycle. Also, readAddress is incremented (behaves as if it were post
--                incremented after reading the sendStr data). The state is set to RDY_LOW.
-- RDY_LOW     -- Do nothing. Wait for the READY signal from the UART_TX_CTRL to go low,
--                indicating a send operation has begun. State is set to WAIT_RDY.
-- WAIT_RDY    -- Do nothing. Wait for the READY signal from the UART_TX_CTRL to go high,
--                indicating a send operation has finished. If READY is high and ADDRESS_END =
--                StrIndex then state is set to WAIT_BTN, else if READY is high and ADDRESS_END /=
--                StrIndex then state is set to SEND_BYTE.
-- WAIT_BTN    -- Do nothing. Wait for a button press on BTNU, BTNL, BTND, or BTNR. If a
--                button press is detected, set the state to START_SEND.
-- START_SEND  -- start the beginning of sending data. The state is set to SEND_BYTE.
--

  type UART_STATE_TYPE is (RST_REG, READY_SEND, SEND_BYTE, RDY_LOW, WAIT_RDY, WAIT_BTN, START_SEND);
--Current uart state signal
  signal uartState : UART_STATE_TYPE := RST_REG;

  constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";  -- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms

--this counter counts the amount of time paused in the UART reset state
  signal reset_cntr : std_logic_vector (17 downto 0) := (others => '0');

--Contains the index of the next character to be sent over uart
--within the sendStr variable.
  signal readAddress : std_logic_vector(10 downto 0);

begin  -- architecture Behavioral

----------------------------------------------------------
------              UART Control                   -------
----------------------------------------------------------
--Messages are sent on reset and when a button is pressed.

--This counter holds the UART state machine in reset for ~2 milliseconds. This
--will complete transmission of any byte that may have been initiated during
--FPGA configuration due to the UART_TX line being pulled low, preventing a
--frame shift error from occuring during the first message.

  process(CLK)
  begin
    if (rising_edge(CLK)) then
      if ((reset_cntr = RESET_CNTR_MAX) or (uartState /= RST_REG)) then
        reset_cntr <= (others => '0');
      else
        reset_cntr <= reset_cntr + 1;
      end if;
    end if;
  end process;

--Next Uart state logic (states described above)
  next_uartState_process : process (CLK)
  begin
    if (rising_edge(CLK)) then
      if (RESET = '1') then
        uartState <= RST_REG;
      else
        case uartState is
          when RST_REG =>
            if (reset_cntr = RESET_CNTR_MAX) then
              uartState <= READY_SEND;
              -- uartState <= WAIT_BTN;
            end if;
          when READY_SEND =>
               if (START_TX = '0') then
                 uartState <= WAIT_BTN;
               end if;
          when SEND_BYTE =>
            uartState <= RDY_LOW;
          when RDY_LOW =>
            uartState <= WAIT_RDY;
          when WAIT_RDY =>
            if (UART_TX_RDY = '1') then
              if (ADDRESS_END = readAddress) then
                -- uartState <= WAIT_BTN;
                uartState <= READY_SEND;
              else
                uartState <= SEND_BYTE;
              end if;
            end if;
          when WAIT_BTN =>
            if (START_TX = '1') then
              uartState <= START_SEND;
            end if;
          when START_SEND =>
            uartState <= SEND_BYTE;
          when others =>                --should never be reached
            uartState <= RST_REG;
        end case;
      end if;
    end if;
  end process;


--Conrols the readAddress signal so that it contains the address
--of the next character that needs to be sent over uart
  char_count_process : process (CLK)
  begin
    if (rising_edge(CLK)) then
      if (uartState = READY_SEND or uartState = START_SEND) then
        readAddress <= (others => '0');
      elsif (uartState = SEND_BYTE) then
        readAddress <= readAddress + 1;
      end if;
    end if;
  end process;

  RD_ADDR <= readAddress(9 downto 0);

--Controls the UART_TX_CTRL signals
  char_load_process : process (CLK)
  begin
    if (rising_edge(CLK)) then
      if (uartState = SEND_BYTE) then
        UART_TX_SEND <= '1';
      else
        UART_TX_SEND <= '0';
      end if;
    end if;
  end process;

end architecture Behavioral;


