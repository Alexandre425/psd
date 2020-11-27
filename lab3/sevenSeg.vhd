library IEEE;
use IEEE.STD_LOGIC_1164.all;

--The IEEE.std_logic_unsigned contains definitions that allow
--std_logic_vector types to be used with the + operator to instantiate a
--counter.
use IEEE.std_logic_unsigned.all;


entity sevenSeg is
  port (
    RST     : in  std_logic;
    CLK     : in  std_logic;
    SEG0    : in  std_logic_vector (7 downto 0);
    SEG1    : in  std_logic_vector (7 downto 0);
    SEG2    : in  std_logic_vector (7 downto 0);
    SEG3    : in  std_logic_vector (7 downto 0);
    SSEG_CA : out std_logic_vector (7 downto 0);
    SSEG_AN : out std_logic_vector (3 downto 0)
    );
end entity sevenSeg;


architecture Behavioral of sevenSeg is

  --This is used to determine when the 7-segment display should be
  --incremented
  signal tmrCntr : std_logic_vector(26 downto 0) := (others => '0');

  --This counter keeps track of which number is currently being displayed
  --on the 7-segment.
  signal tmrVal : std_logic_vector(3 downto 0) := (others => '0');

  constant TMR_CNTR_MAX_CONST :         --100,000,000 = clk cycles per second
    std_logic_vector(26 downto 0) := "101111101011110000100000000";  -- 1 seg.
  constant TMR_VAL_MAX9_CONST : std_logic_vector(3 downto 0) := "1001";  --9

  signal SSEG_AN_sel : std_logic_vector(3 downto 0);
  signal sseg_val    : std_logic_vector(7 downto 0);

begin  -- architecture Behavioral


----------------------------------------------------------
------           7-Seg Display Control             -------
----------------------------------------------------------
  -- Left Digit is incremented every second, and are blanked in
  --response to RST presses.

  --Individual and reset blanking of Anodes
  with RST select
    SSEG_AN <=
    SSEG_AN_sel when '0',
    "1111"      when others;

  --This process controls the counter that triggers the 7-segment
  --to be incremented. It counts 100,000,000 (one sec) and then resets.
  timer_counter_process : process (CLK)
  begin
    if (rising_edge(CLK)) then
      if ((tmrCntr = TMR_CNTR_MAX_CONST) or (RST = '1')) then
        tmrCntr <= (others => '0');
      else
        tmrCntr <= tmrCntr + 1;
      end if;
    end if;
  end process;

  --This process increments the digit being displayed on the
  --7-segment display every second.
  timer_inc_process : process (CLK)
  begin
    if (rising_edge(CLK)) then
      if (RST = '1') then
        tmrVal <= (others => '0');
      elsif (tmrCntr = TMR_CNTR_MAX_CONST) then
        if (tmrVal = TMR_VAL_MAX9_CONST) then
          tmrVal <= (others => '0');
        else
          tmrVal <= tmrVal + 1;
        end if;
      end if;
    end if;
  end process;



  with tmrCntr(17 downto 16) select SSEG_CA <=
    SEG0              when "00",
    SEG1              when "01",
    SEG2              when "10",
--  SEG3              when others;
    SEG3 and sseg_val when others;  -- for test: (input of SEG3) and (value of counter tmrVal)

  with tmrCntr(17 downto 16) select SSEG_AN_sel <=
    "1110" when "00",
    "1101" when "01",
    "1011" when "10",
    "0111" when others;


  --This select statement encodes the value of tmrVal to the necessary
  --cathode signals to display it on the 7-segment (MSB is decimal point)
  with tmrVal select sseg_val <=
    "01000000" when "0000",
    "01111001" when "0001",
    "00100100" when "0010",
    "00110000" when "0011",
    "00011001" when "0100",
    "00010010" when "0101",
    "00000010" when "0110",
    "01111000" when "0111",
    "10000000" when "1000",
    "00010000" when "1001",
    "00001000" when "1010",             --A
    "00000011" when "1011",             --b
    "01000110" when "1100",             --C
    "00100001" when "1101",             --d
    "00000110" when "1110",             --E
    "00001110" when "1111",             --F
    "11111111" when others;


end architecture Behavioral;

