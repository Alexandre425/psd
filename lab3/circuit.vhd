library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
use work.common.all;


entity circuit is
    port (
        clk        : in  std_logic;
        clk_qt     : in  std_logic;
        reset      : in  std_logic;                         -- btnD
        start      : in  std_logic;                         -- btnR
        dataIn     : in  std_logic_vector (31 downto 0);
        addrIn     : out std_logic_vector (7 downto 0);
        dataOut    : out std_logic_vector (31 downto 0);
        addrOut    : out std_logic_vector (7 downto 0);
        weOut      : out std_logic;
        statusLeds : out std_logic_vector (15 downto 0)     -- leds
    ); 
end circuit;

architecture Behavioral of circuit is

    component datapath is
        port (
            clk :           in std_logic;
            reset :         in std_logic;
            enable :        in std_logic;
            a, b, c, d :    in std_logic_vector (31 downto 0);
            idx:            in std_logic_vector (2 downto 0);
            min_idx_out :	out std_logic_vector (2 downto 0);
            max_idx_out :	out std_logic_vector (2 downto 0);
            avg_det :       out complex_num
        );
    end component;

    component control is
        port (
            clk :       in std_logic;
            start :     in std_logic;
            reset :     in std_logic;
            buffer_fwd: out std_logic;
            addr :      out std_logic_vector (7 downto 0);
            idx:        out std_logic_vector (2 downto 0)
        );
    end component;

    -- Buffers for the datapath
    type buff is array (3 downto 0) of std_logic_vector(31 downto 0);
    signal buff1, buff2, datapath_buff : buff;
    signal idx_buff : std_logic_vector (2 downto 0);
    signal enable_buff, reset_buff : std_logic;
    signal buffer_fwd : std_logic;

    signal addr_in : std_logic_vector (7 downto 0); -- Address of the input memory
    signal idx :    std_logic_vector (2 downto 0);  -- Index of the matrix currently in the datapath

    signal max_idx, min_idx : std_logic_vector (2 downto 0);    -- Min and max determinant indexes
    signal avg_det : complex_num;            					-- Average determinant
begin

    dp : datapath
        port map (
            clk => clk,
            reset => reset_buff,
            enable => enable_buff,
            a => datapath_buff(0), b => datapath_buff(1), c => datapath_buff(2), d => datapath_buff(4),
            idx => idx_buff,
            min_idx_out => min_idx,
            max_idx_out => max_idx,
            avg_det => avg_det
        );
    
    ctrl : control
        port map (
            clk  => clk,
            start => start,
            reset => reset,
            buffer_fwd => buffer_fwd,
            addr => addr_in,
            idx => idx
        );

    process(clk, addr_in)
    begin
        -- The first buffer is addressed with the last two bits of the address, 
        --  a number between 0 and 3, and as such, representing which value of the 
        --  matrix (abcd) is in that memory position
        if clk'event and clk = '1' then
            buff1(to_integer(unsigned(addr_in(1 downto 0)))) <= dataIn;   
            if buffer_fwd = '1' then    -- If signalled to forward the buffer
                buff2 <= buff1;         -- Pass the vals in buffer 1 to buffer 2
            end if;
        end if;
    end process;

    process (clk_qt)
    begin
        if clk_qt'event and clk_qt = '1' then   -- Pass data from the circuit to the datapath buffer
            datapath_buff <= buff2;
            enable_buff <= enable;
            reset_buff <= reset;
            idx_buff <= idx;
        end if;
    end process;



end Behavioral;
