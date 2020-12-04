library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;
use work.common.all;


entity circuit is
    port (
        clk        : in  std_logic;
        clk_hl     : in  std_logic;
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
            det :           out complex_num;
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
            write_avg : out std_logic;
            enable:		out std_logic;
            buffer_fwd: out std_logic;
            addr :      out std_logic_vector (7 downto 0);
            idx:        out std_logic_vector (2 downto 0)
        );
    end component;

    -- Buffers for the datapath
    type buff is array (3 downto 0) of std_logic_vector(31 downto 0);
    signal buff1, buff2, datapath_buff : buff;
    signal avg_det_buff : complex_num;
    signal idx_buff1, idx_buff2 : std_logic_vector (2 downto 0);
    signal enable_buff1, enable_buff2, reset_buff : std_logic;
    signal write_avg_buff1, write_avg_buff2 : std_logic;
    signal buffer_fwd : std_logic;

    signal enable, write_avg: std_logic;
    signal addr_in : std_logic_vector (7 downto 0); -- Address of the input memory
    signal idx :    std_logic_vector (2 downto 0);  -- Index of the matrix currently in the datapath

    signal max_idx, min_idx : std_logic_vector (2 downto 0);    -- Min and max determinant indexes
    signal det      : complex_num;  -- Determinant
    signal avg_det  : complex_num;  -- Average determinant
    signal mem_val  : complex_num;  -- Which of the above two to write to memory

    signal out_addr_counter : std_logic;    -- Manages which value (R or I) gets sent out
begin

    dp : datapath
        port map (
            clk => clk_qt,          -- The connection between the buffer and the inputs seems out of sync, but
            reset => reset_buff,    --  it is necessary as the address being output by the control unit is
            enable => enable_buff2, --  the address of the thing that is going to be loaded plus one
            a => datapath_buff(1), b => datapath_buff(2), c => datapath_buff(3), d => datapath_buff(0),
            idx => idx_buff2,
            det => det,
            min_idx_out => min_idx,
            max_idx_out => max_idx,
            avg_det => avg_det
        );

    -- Put the index of the min and max registers on the LEDs
    -- This is probably the worst way ever of doing this, I hope the compiler fixes it
    -- I can't figure out how to encode it in one hot lol
    with min_idx select statusLeds (15 downto 8) <=
        "10000000" when "000",
        "01000000" when "001",
        "00100000" when "010",
        "00010000" when "011",
        "00001000" when "100",
        "00000100" when "101",
        "00000010" when "110",
        "00000001" when others;
    with max_idx select statusLeds (7 downto 0) <=
        "10000000" when "000",
        "01000000" when "001",
        "00100000" when "010",
        "00010000" when "011",
        "00001000" when "100",
        "00000100" when "101",
        "00000010" when "110",
        "00000001" when others;
        
    ctrl : control
        port map (
            clk  => clk,
            start => start,
            enable => enable,
            write_avg => write_avg,
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
                idx_buff1 <= idx;
                buff2 <= buff1;         -- Pass the vals in buffer 1 to buffer 2
            end if;
        end if;
    end process;

    process (clk_qt)
    begin
        if clk_qt'event and clk_qt = '1' then   -- Pass data from the circuit to the datapath buffer
            datapath_buff <= buff2;
            enable_buff1 <= enable;
            enable_buff2 <= enable_buff1;
            write_avg_buff1 <= write_avg;
            write_avg_buff2 <= write_avg_buff1;
            reset_buff <= reset;
            idx_buff2 <= idx_buff1;
            avg_det_buff <= avg_det;
        end if;
    end process;
    
    process(clk_hl, reset)
    begin
        if clk_hl'event and clk_hl = '1' then
            if reset = '1' then
                out_addr_counter <= '0';
            else
                out_addr_counter <= out_addr_counter xor '1';   -- Toggle the bit
            end if;
        end if;
    end process;

    -- Write them to different positions of memory
    -- Equivalent to multiplying by 2 and adding 1 for I, 0 for R
    with write_avg_buff2 select addrOut <=
        "0000" & idx_buff2 & out_addr_counter when '0',
        "0001000" & out_addr_counter when others;
    -- Alternate sending the R or I parts of the determinant every 2 cycles
    with write_avg_buff2 select mem_val <=
        det when '0',
        avg_det_buff when others;
    with out_addr_counter select dataOut <= -- I dunno how to do this conversion
        mem_val(0) when '0',
        mem_val(1) when others;

    addrIn <= addr_in;
    weOut <= enable_buff2;



end Behavioral;
