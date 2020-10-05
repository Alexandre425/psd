library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--library UNISIM;
--use UNISIM.VComponents.all;

entity disp7 is
  port (
   disp3, disp2, disp1, disp0 : in std_logic_vector(6 downto 0);
   dp3, dp2, dp1, dp0 : in std_logic;
   dclk : in std_logic;
   dactive : in std_logic_vector(3 downto 0);
   en_disp_l : out std_logic_vector(3 downto 0);
   segm_l : out std_logic_vector(6 downto 0);
   dp_l : out std_logic
  );
end disp7;

architecture mixed of disp7 is
  signal sel_disp : std_logic_vector(3 downto 0);
  signal ndisp : std_logic_vector(1 downto 0);

begin

  -- 4 bit counter --- multiplexes displays
  process (dclk)
  begin
    if rising_edge(dclk) then
        ndisp <= ndisp + 1;
    end if;
  end process;

  -- 4-to-1 Mux
  with ndisp select
    segm_l <= not(disp0) when "00",
              not(disp1) when "01",
              not(disp2) when "10",
              not(disp3) when others;
  -- 4-to-1 Mux
  with ndisp select
    dp_l <= not(dp0) when "00",
            not(dp1) when "01",
            not(dp2) when "10",
            not(dp3) when others;
  -- 4-to-1 Mux
  with ndisp select
    sel_disp  <= "0001" when "00",
                 "0010" when "01",
                 "0100" when "10",
                 "1000" when others;

  en_disp_l(0) <= not(dactive(0) and sel_disp(0));
  en_disp_l(1) <= not(dactive(1) and sel_disp(1));
  en_disp_l(2) <= not(dactive(2) and sel_disp(2));
  en_disp_l(3) <= not(dactive(3) and sel_disp(3));

end mixed;
