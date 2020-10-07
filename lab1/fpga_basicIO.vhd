library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity fpga_basicIO is
    port (
        clk : in  std_logic;  -- 100MHz clock
        btnC, btnU, btnL, btnR, btnD : in  std_logic;  -- buttons
        sw : in  std_logic_vector(15 downto 0);        -- switches
        led : out std_logic_vector(15 downto 0);       -- leds
        an : out std_logic_vector(3 downto 0);         -- display selectors
        seg : out std_logic_vector(6 downto 0);        -- display 7-segments
        dp : out std_logic                             -- display point
    );
end fpga_basicIO;

architecture Behavioral of fpga_basicIO is
    signal dd3, dd2, dd1, dd0 : std_logic_vector(6 downto 0);
    signal res : std_logic_vector(7 downto 0);
    signal dact : std_logic_vector(3 downto 0);
    signal buttons : std_logic_vector(4 downto 0);
    signal clk10hz, clk_disp : std_logic;
    signal btnCreg, btnUreg, btnLreg, btnRreg, btnDreg : std_logic;  -- registered input buttons
    signal oper_disp : std_logic_vector (3 downto 0); -- Number of the operation selected

    component disp7
        port (
            disp3, disp2, disp1, disp0 : in  std_logic_vector(6 downto 0);
            dp3, dp2, dp1, dp0         : in  std_logic;
            dclk                       : in  std_logic;
            dactive                    : in  std_logic_vector(3 downto 0);
            en_disp_l                  : out std_logic_vector(3 downto 0);
            segm_l                     : out std_logic_vector(6 downto 0);
            dp_l                       : out std_logic);
    end component;
    component hex2disp
        port (
            sw  : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0));
    end component;
    component clkdiv
        port(
            clk100M  : in  std_logic;
            clk10Hz  : out std_logic;
            clk_disp : out std_logic);
    end component;
    component circuito
        port (
            clk         : in  std_logic;
            buttons     : in  std_logic_vector(4 downto 0);
            ent         : in  std_logic_vector(7 downto 0);
            res         : out std_logic_vector(15 downto 0);
            oper_disp   : out std_logic_vector(3 downto 0)
        );
    end component;

begin
  led <= sw;
--  led(15 downto 7) <= (others => '0');
--  led(6 downto 0) <= dd0;

  dact <= "1111";

  inst_disp7 : disp7 port map(
    disp3 => dd3, disp2 => dd2, disp1 => dd1, disp0 => dd0,
    dp3 => oper_disp(3), dp2 => oper_disp(2), dp1 => oper_disp(1), dp0 => oper_disp(0),
    dclk => clk_disp,
    dactive => dact,
    en_disp_l => an,
    segm_l => seg,
    dp_l => dp);

  inst_hex0 : hex2disp port map(sw => res(3 downto 0), seg => dd0);
  inst_hex1 : hex2disp port map(sw => res(7 downto 4), seg => dd1);
  inst_hex2 : hex2disp port map(sw => sw(3 downto 0), seg => dd2);
  inst_hex3 : hex2disp port map(sw => sw(7 downto 4), seg => dd3);

  inst_clkdiv : clkdiv port map(
    clk100M  => clk,
    clk10hz  => clk10hz,
    clk_disp => clk_disp);


    buttons <= btnUreg & btnLreg & btnCreg & btnRreg & btnDreg;
    inst_circuito : circuito port map(
        clk         => clk,
        buttons     => buttons,
        ent         => sw(7 downto 0),
        res         => res,
        oper_disp   => oper_disp
    );

  process (clk10hz, btnC)
  begin
    if rising_edge(clk10hz) then
      btnCreg <= btnC;
      btnUreg <= btnU;
      btnLreg <= btnL;
      btnRreg <= btnR;
      btnDreg <= btnD;
    end if;
  end process;
end Behavioral;
