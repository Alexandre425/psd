-----------------------------------------------------------------------------
-- Vhdl model created on Oct 2020, (c) 2020 Paulo Flores.
-----------------------------------------------------------------------------
library ieee;
library UNISIM;
library UNIMACRO;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;
use UNIMACRO.vcomponents.all;


entity memOUT is
  port (
    clk     : in  std_logic;
    addr    : in  std_logic_vector(9 downto 0);
    we      : in  std_logic;
    dataIN  : in  std_logic_vector(31 downto 0);
    dataOUT : out  std_logic_vector(31 downto 0)
    );
end memOUT;


architecture gen of memOUT is
  signal we4 : std_logic_vector(3 downto 0);
begin

  we4 <= (others => we);

  MEM_out : BRAM_SINGLE_MACRO
    generic map (          -- memory initialization
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb"
      DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6"
      WRITE_WIDTH => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH  => 32    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")

    )
    port map (
      CLK   => clk,     -- Clock
      ADDR  => addr,    -- 10-bit Address Input, width defined by read/write port depth
      DI    => dataIn,  -- 32-bit Data Input, width defined by WRITE_WIDTH parameter
      DO    => dataOut, -- 32-bit Data Output, width defined by READ_WIDTH parameter
      EN    => '1',     -- 1-bit RAM Enable Input
      WE    => we4,     -- Write Enable Input, width defined by write port depth
      REGCE => '0',     -- 1-bit Input, output register enable
      RST   => '0'      -- 1-bit Input reset
      );

end gen;
