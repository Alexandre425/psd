----------------------------------------------------------------------------
--      GPIO_Demo.vhd -- Basys3 GPIO/UART Demonstration Project
----------------------------------------------------------------------------
-- Author:  Marshall Wingerson Adapted from Sam Bobrowicz
--          Copyright 2013 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--      The GPIO/UART Demo project demonstrates a simple usage of the Basys3's
--  GPIO and UART. The behavior is as follows:
--
--       *The 16 User LEDs are tied to the 16 User Switches. While the center
--         User button is pressed, the LEDs are instead tied to GND
--       *The 7-Segment display counts from 0 to 9 on each of its 8
--        digits. This count is reset when the center button is pressed.
--        Also, single anodes of the 7-Segment display are blanked by
--        holding BTNU, BTNL, BTND, or BTNR. Holding the center button
--        blanks all the 7-Segment anodes.
--       *An introduction message is sent across the UART when the device
--        is finished being configured, and after the center User button
--        is pressed.
--       *A message is sent over UART whenever BTNU, BTNL, BTND, or BTNR is
--        pressed.
--       *Note that the center user button behaves as a user reset button
--        and is referred to as such in the code comments below
--       *A test pattern is displayed on the VGA port at 1280x1024 resolution.
--        If a mouse is attached to the USB-HID port, a cursor can be moved
--        around the pattern.
--
--      All UART communication can be captured by attaching the UART port to a
-- computer running a Terminal program with 9600 Baud Rate, 8 data bits, no
-- parity, and 1 stop bit.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Revision History:
--  08/08/2011(SamB): Created using Xilinx Tools 13.2
--  08/27/2013(MarshallW): Modified for the Nexys4 with Xilinx ISE 14.4\
--              --added RGB and microphone
--  7/22/2014(SamB): Modified for the Basys3 with Vivado 2014.2\
--              --Removed RGB and microphone
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
--The IEEE.std_logic_unsigned contains definitions that allow
--std_logic_vector types to be used with the + operator to instantiate a
--counter.
use IEEE.std_logic_unsigned.all;

use IEEE.std_logic_misc.all;


entity top_circuit is
  port (SW       : in  std_logic_vector (15 downto 0);
        BTN      : in  std_logic_vector (4 downto 0);
        CLK      : in  std_logic;
        LED      : out std_logic_vector (15 downto 0);
        SSEG_CA  : out std_logic_vector (7 downto 0);
        SSEG_AN  : out std_logic_vector (3 downto 0);
        UART_TXD : out std_logic
        );
end top_circuit;

architecture Behavioral of top_circuit is

  component MemIn is
    port (
      DataRDA : out std_logic_vector(31 downto 0);
      AddrRDA : in  std_logic_vector(7 downto 0);
      ClkRDA  : in  std_logic;
      DataWRB : in  std_logic_vector(7 downto 0);
      AddrWRB : in  std_logic_vector(9 downto 0);
      ClkWRB  : in  std_logic;
      WeWRB   : in  std_logic);
  end component MemIn;

  component MemOuT is
    port (
      DataWRA : in  std_logic_vector(31 downto 0);
      AddrWRA : in  std_logic_vector(7 downto 0);
      ClkWRA  : in  std_logic;
      WeWRA   : in  std_logic;
      DataRDB : out std_logic_vector(7 downto 0);
      AddrRDB : in  std_logic_vector(9 downto 0);
      ClkRDB  : in  std_logic);
  end component MemOuT;


  component circuit is
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      start      : in  std_logic;
      dataIn     : in  std_logic_vector (31 downto 0);
      addrIn     : out std_logic_vector (7 downto 0);
      dataOut    : out std_logic_vector (31 downto 0);
      addrOut    : out std_logic_vector (7 downto 0);
      weOut      : out std_logic;
      statusLeds : out std_logic_vector (15 downto 0));
  end component circuit;


  component debouncer
    generic(
      DEBNC_LOG_CLOCKS : integer;
      PORT_WIDTH       : integer);
    port(
      SIGNAL_I : in  std_logic_vector(4 downto 0);
      CLK_I    : in  std_logic;
      SIGNAL_O : out std_logic_vector(4 downto 0)
      );
  end component;

  component UART_TX_KB is
    port (
      CLK      : in  std_logic;
      RESET    : in  std_logic;
      START_TX : in  std_logic;
      RD_ADDR  : out std_logic_vector (9 downto 0);
      RD_DATA  : in  std_logic_vector (7 downto 0);
      TX_OUT   : out std_logic);
  end component UART_TX_KB;

  component sevenSeg is
    port (
      RST     : in  std_logic;
      CLK     : in  std_logic;
      SEG0    : in  std_logic_vector (7 downto 0);
      SEG1    : in  std_logic_vector (7 downto 0);
      SEG2    : in  std_logic_vector (7 downto 0);
      SEG3    : in  std_logic_vector (7 downto 0);
      SSEG_CA : out std_logic_vector (7 downto 0);
      SSEG_AN : out std_logic_vector (3 downto 0));
  end component sevenSeg;

-- buttons signals
  signal btnReset  : std_logic;
  signal btnStart  : std_logic;
  signal btnLoad   : std_logic;
  signal btnCenter : std_logic;
  signal btnLeft   : std_logic;

-- memIn signals
  signal dataIn : std_logic_vector(31 downto 0);
  signal addrIn : std_logic_vector(7 downto 0);

-- memOut signals
  signal dataOut : std_logic_vector(31 downto 0);
  signal addrOut : std_logic_vector(7 downto 0);
  signal weOut   : std_logic;

-- Led signal
  signal statusLeds : std_logic_vector(15 downto 0);

-- Seven segments (digit 3)
  signal sevenSeg3 : std_logic_vector(7 downto 0);

-- UART_TX_KB  signals
  signal dataSend : std_logic_vector (7 downto 0);
  signal readAddr : std_logic_vector (9 downto 0);


--Debounced btn signals used to prevent single button presses
--from being interpreted as multiple button presses.
  signal btnDeBnc : std_logic_vector(4 downto 0);


begin
  -- Signal renaming
  btnReset  <= btnDeBnc(3);             -- btnD
  btnStart  <= btnDeBnc(2);             -- btnR
  btnLoad   <= btnDeBnc(0);             -- btnU
  btnCenter <= btnDeBnc(4);             -- btnC
  btnLeft   <= btnDeBnc(1);             -- btnL

----------------------------------------------------------
------           Some LED Control                  -------
----------------------------------------------------------
  with btnReset select
    LED(15 downto 0) <=
    X"FFFF"    when '1',
    statusLeds when others;
----------------------------------------------------------
------       Some SW and SSeg  signals             -------
----------------------------------------------------------

  sevenSeg3 <= not(SW(15 downto 8) or SW(7 downto 0));

----------------------------------------------------------
------             Components Inst.                -------
----------------------------------------------------------

  -- Input memory
  MemIn_1 : MemIn
    port map (
      DataRDA => dataIn,
      AddrRDA => addrIn,
      ClkRDA  => CLK,
      DataWRB => "00000000",
      AddrWRB => (others => '0'),
      ClkWRB  => CLK,
      WeWRB   => '0');

  -- Output memory
  MemOuT_1 : MemOuT
    port map (
      DataWRA => dataOut,
      AddrWRA => addrOut,
      clkWRA  => CLK,
      WeWRA   => weOut,
      DataRDB => dataSend,
      AddrRDB => readAddr,
      clkRDB  => CLK);


  -- developed circuit to implement an algorithm
  circuit_1 : circuit
    port map (
      clk        => CLK,
      rst        => btnReset,
      start      => btnStart,
      dataIn     => dataIn,
      addrIn     => addrIn,
      dataOut    => dataOut,
      addrOut    => addrOut,
      weOut      => weOut,
      statusLeds => statusLeds);


  -- circuit to upload output memory to the PC using UART interface (via USB)
  UART_TX_KB_1 : UART_TX_KB
    port map (
      CLK      => CLK,
      RESET    => btnReset,
      START_TX => btnLoad,
      RD_ADDR  => readAddr,
      RD_DATA  => dataSend,
      TX_OUT   => UART_TXD);

  --Debounces btn signals
  debouncer_1 : debouncer
    generic map(
      DEBNC_LOG_CLOCKS => 4,
      PORT_WIDTH       => 5)
    port map(
      SIGNAL_I => BTN,
      CLK_I    => CLK,
      SIGNAL_O => btnDeBnc);

  -- Seven segments display interface
  sevenSeg_1 : sevenSeg
    port map (
      RST     => btnReset,
      CLK     => CLK,
      SEG0    => "00001000",            -- A
      SEG1    => "01000111",            -- L
      SEG2    => "01000000",            -- O
      SEG3    => sevenSeg3,             -- and counter from sevenSeg.vhd
      SSEG_CA => SSEG_CA,
      SSEG_AN => SSEG_AN);

end Behavioral;
