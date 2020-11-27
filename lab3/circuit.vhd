-- Example circuit by Prof. Paulo Flores (2020/21 1S)
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.all;
use ieee.std_logic_signed.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity circuit is
  port (clk        : in  std_logic;
        rst        : in  std_logic;                        -- btnD
        start      : in  std_logic;                        -- btnR
        dataIn     : in  std_logic_vector (31 downto 0);
        addrIn     : out std_logic_vector (7 downto 0);
        dataOut    : out std_logic_vector (31 downto 0);
        addrOut    : out std_logic_vector (7 downto 0);
        weOut      : out std_logic;
        statusLeds : out std_logic_vector (15 downto 0));  -- leds
end circuit;

architecture Behavioral of circuit is
  signal cnt                        : std_logic_vector(5 downto 0);
  signal cnt_o                      : std_logic_vector(5 downto 0);
  signal dataInIm, dataInRe         : std_logic_vector(11 downto 0);  -- Q5.7
  signal dataInIm_reg, dataInRe_reg : std_logic_vector(11 downto 0);  -- Q5.7
  signal resRe2, resIm2             : std_logic_vector(23 downto 0);  -- Q10.14
  signal resRe2_reg, resIm2_reg     : std_logic_vector(23 downto 0);  -- Q10.14
  signal sum2, sum2_reg             : std_logic_vector(24 downto 0);  -- Q11.14

  signal signal_ext : std_logic_vector(2 downto 0);

  signal startMode : std_logic;
  signal we        : std_logic;

begin

  counter : process (clk, rst)
  begin  -- process counter
    if clk'event and clk = '1' then                -- rising clock edge
      if rst = '1' then                            -- synchronous reset
        cnt <= (others => '0');
      elsif startMode = '1' and cnt(5) = '0' then  -- synchronous count upto
        cnt <= cnt + 1;                            -- 100000 = 32 after start
      end if;
    end if;
  end process counter;

  counter_o : process (clk, rst)
  begin  -- process counter
    if clk'event and clk = '1' then            -- rising clock edge
      if rst = '1' then                        -- synchronous reset
        cnt_o <= (others => '0');
      elsif startMode = '1' and cnt >= 4 then  -- synchronous count
        cnt_o <= cnt_o + 1;
      end if;
    end if;
  end process counter_o;


  data_registers : process (clk, rst)
  begin  -- process registers
    if clk'event and clk = '1' then     -- rising clock edge
      if rst = '1' then                 -- synchronous reset
        dataInIm_reg <= (others => '0');
        dataInRe_reg <= (others => '0');
        resRe2_reg   <= (others => '0');
        resIm2_reg   <= (others => '0');
        sum2_reg     <= (others => '0');
      else
        dataInIm_reg <= dataInIm;
        dataInRe_reg <= dataInRe;
        resRe2_reg   <= resRe2;
        resIm2_reg   <= resIm2;
        sum2_reg     <= sum2;
      end if;
    end if;
  end process data_registers;


  wait_for_start : process (clk, rst)
  begin  -- process wait_for_start
    if clk'event and clk = '1' then     -- rising clock edge
      if rst = '1' then                 -- synchronous reset
        startMode <= '0';
      elsif cnt(5) = '1' then
        startMode <= '0';
      elsif start = '1' then            -- synchronous start
        startMode <= '1';
      end if;
    end if;
  end process wait_for_start;


-- control signals and input address packing
  addrIn <= ("00" & cnt);

  dataInIm <= dataIn(11 downto 0);
  dataInRe <= dataIn(27 downto 16);

  -- Datapath
  resIm2 <= dataInIm_reg * dataInIm_reg;
  resRe2 <= dataInRe_reg * dataInRe_reg;

  sum2 <= (resRe2_reg(23) & resRe2_reg) + (resIm2_reg(23) & resIm2_reg);

  -- packing results from Q11.14 to Q14.18 (32bit)
  signal_ext <= (others => sum2(24));
  dataOut    <= signal_ext & sum2_reg & "0000";

  -- more control signals and output address packing
  addrOut <= ("00" & cnt_o);


  weOut <=
    '1' when (cnt >= 4) else
    '0';

  statusLeds <= sum2(15 downto 0);

end Behavioral;
