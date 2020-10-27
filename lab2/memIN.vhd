-----------------------------------------------------------------------------
-- Memory generated for 'Matrix and Determinat Computation', PSD/DSD (2020/21)
-- Copyright (C) by Paulo Flores <paulo.flores@tecnico.ulisboa.pt>
-- Version: Ver. 1.0 2020-10-21
-- Command: dat2mem.pl 
-- Seed: -s 1603648783 ( dat2mem.pl  -s 1603648783 )
-- Date: Sun Oct 25 17:59:43 WET 2020
-----------------------------------------------------------------------------
library ieee;
library UNISIM;
library UNIMACRO;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;
use UNIMACRO.vcomponents.all;


entity MemIN is
	port (
		clk    : in  std_logic;
		addr   : in  std_logic_vector(9 downto 0);
		A, B, C, D, E, F : out std_logic_vector(15 downto 0)
		);
end MemIN;


architecture GEN1603648783 of MemIN is
	signal dout0,dout1,dout2: std_logic_vector(31 downto 0);
begin

  MEM_in0 : BRAM_SINGLE_MACRO
	generic map (          -- memory initialization
		BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb"
		DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6"
		WRITE_WIDTH => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
		READ_WIDTH  => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
		-- Initialize memory predefined data
		INIT_00 => X"99C160CFB7C146ECD0313B5ED3228C9628534A20BE4ED355355DC7281898127A",
		INIT_01 => X"BC7D865CBDA31C015C8C67C32B9B66444F71354E7FADC69C054F4BAC2EB87219",
		INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000"
	)
	port map (
		CLK   => clk,         -- Clock
		ADDR  => addr,        -- 9-bit Address Input, width defined by read/write port depth
		DI    => x"00000000", -- 32-bit Data Input, width defined by WRITE_WIDTH parameter
		DO    => dout0,       -- 32-bit Data Output, width defined by READ_WIDTH parameter
		EN    => '1',         -- 1-bit RAM Enable Input
		WE    => "0000",      -- Write Enable Input, width defined by write port depth
		REGCE => '0',         -- 1-bit Input, output register enable
		RST   => '0'          -- 1-bit Input reset
	);

	MEM_in1 : BRAM_SINGLE_MACRO
		generic map (          -- memory initialization
			BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb"
			DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6"
			WRITE_WIDTH => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
			READ_WIDTH  => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
			-- Initialize memory predefined data
			INIT_00 => X"1CA555770EF35B4803B61162BD191C5AF0BE49AF03DA35A6DA006E7041975F5B",
			INIT_01 => X"C29958E2E1695B6F9C0E6C70F822282F970E7125A99854B344721525742318B5",
			INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000"
		)
	port map (
		CLK   => clk,         -- Clock
		ADDR  => addr,        -- 9-bit Address Input, width defined by read/write port depth
		DI    => x"00000000", -- 32-bit Data Input, width defined by WRITE_WIDTH parameter
		DO    => dout1,       -- 32-bit Data Output, width defined by READ_WIDTH parameter
		EN    => '1',         -- 1-bit RAM Enable Input
		WE    => "0000",      -- Write Enable Input, width defined by write port depth
		REGCE => '0',         -- 1-bit Input, output register enable
		RST   => '0'          -- 1-bit Input reset
	);

 	MEM_in2 : BRAM_SINGLE_MACRO
		generic map (          -- memory initialization
			BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb"
			DEVICE => "7SERIES", -- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6"
			WRITE_WIDTH => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
			READ_WIDTH  => 32,   -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
			-- Initialize memory predefined data
			INIT_00 => X"4CE135D167715B4833579DDD5D9F11D4BDDF6DF30AB417F91F678851FCC26A72",
			INIT_01 => X"DAEA911594B031D654283C26163598AEE4C401B7B0E3BDE5476CACEC7AC4E0C3",
			INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000"
		)
	port map (
		CLK   => clk,         -- Clock
		ADDR  => addr,        -- 9-bit Address Input, width defined by read/write port depth
		DI    => x"00000000", -- 32-bit Data Input, width defined by WRITE_WIDTH parameter
		DO    => dout2,       -- 32-bit Data Output, width defined by READ_WIDTH parameter
		EN    => '1',         -- 1-bit RAM Enable Input
		WE    => "0000",      -- Write Enable Input, width defined by write port depth
		REGCE => '0',         -- 1-bit Input, output register enable
		RST   => '0'          -- 1-bit Input reset
	);

	A <= dout0(15 downto 0);
	B <= dout0(31 downto 16);

	C <= dout1(15 downto 0);
	D <= dout1(31 downto 16);

	E <= dout2(15 downto 0);
	F <= dout2(31 downto 16);

end GEN1603648783;

--- Mat:  0 --------------------------------------------------------------  0
-- Inp A=  4730 (0x127A)  B=  6296 (0x1898)  C= 24411 (0x5F5B)
--     D= 16791 (0x4197)  E= 27250 (0x6A72)  F=  -830 (0xFCC2)
-- Res m11=   128892500 (0x07AEBE54)        m12=    -5220950 (0xFFB055AA)
--     m21=  1122754500 (0x42EBDFC4)        m22=    -1265218 (0xFFECB1BE)
--- Det -771053008 (0xD20AAA30)
--- Mat:  1 --------------------------------------------------------------  1
-- Inp A=-14552 (0xC728)  B= 13661 (0x355D)  C= 28272 (0x6E70)
--     D= -9728 (0xDA00)  E=-30639 (0x8851)  F=  8039 (0x1F67)
-- Res m11=   445858728 (0x1A9343A8)        m12=   109806227 (0x068B8293)
--     m21=  -568169616 (0xDE226B70)        m22=    27473738 (0x01A3374A)
--- Det 267392320 (0x0FF01540)
--- Mat:  2 --------------------------------------------------------------  2
-- Inp A=-11435 (0xD355)  B=-16818 (0xBE4E)  C= 13734 (0x35A6)
--     D=   986 (0x03DA)  E=  6137 (0x17F9)  F=  2740 (0x0AB4)
-- Res m11=   -70176595 (0xFBD130AD)        m12=   -46092755 (0xFD40AE2D)
--     m21=    90336640 (0x05626D80)        m22=   -11505610 (0xFF507036)
--- Det 1942074622 (0x73C1B4FE)
--- Mat:  3 --------------------------------------------------------------  3
-- Inp A= 18976 (0x4A20)  B= 10323 (0x2853)  C= 18863 (0x49AF)
--     D= -3906 (0xF0BE)  E= 28147 (0x6DF3)  F=-16929 (0xBDDF)
-- Res m11=   534117472 (0x1FD5FC60)        m12=  -174739091 (0xF595B16D)
--     m21=   420994679 (0x1917DE77)        m22=   -43674560 (0xFD659440)
--- Det -1895196587 (0x8F099855)
--- Mat:  4 --------------------------------------------------------------  4
-- Inp A=-29546 (0x8C96)  B=-11486 (0xD322)  C=  7258 (0x1C5A)
--     D=-17127 (0xBD19)  E=  4564 (0x11D4)  F= 23967 (0x5D9F)
-- Res m11=  -134847944 (0xF7F66238)        m12=  -275314508 (0xEF9708B4)
--     m21=   -45042116 (0xFD50B63C)        m22=   -68831110 (0xFBE5B87A)
--- Det -498791296 (0xE2450C80)
--- Mat:  5 --------------------------------------------------------------  5
-- Inp A= 15198 (0x3B5E)  B=-12239 (0xD031)  C=  4450 (0x1162)
--     D=   950 (0x03B6)  E=-25123 (0x9DDD)  F= 13143 (0x3357)
-- Res m11=  -381819354 (0xE93DE626)        m12=  -160841979 (0xF669BF05)
--     m21=  -135664200 (0xF7E9EDB8)        m22=   -40208895 (0xFD9A7601)
--- Det -1043759730 (0xC1C97D8E)
--- Mat:  6 --------------------------------------------------------------  6
-- Inp A= 18156 (0x46EC)  B=-18495 (0xB7C1)  C= 23368 (0x5B48)
--     D=  3827 (0x0EF3)  E= 23368 (0x5B48)  F= 26481 (0x6771)
-- Res m11=   424269408 (0x1949D660)        m12=  -489747939 (0xE2CF0A1D)
--     m21=   635492760 (0x25E0D998)        m22=  -122414329 (0xF8B41B07)
--- Det 20997736 (0x01406668)
--- Mat:  7 --------------------------------------------------------------  7
-- Inp A= 24783 (0x60CF)  B=-26175 (0x99C1)  C= 21879 (0x5577)
--     D=  7333 (0x1CA5)  E= 13777 (0x35D1)  F= 19681 (0x4CE1)
-- Res m11=   341435391 (0x1459E3FF)        m12=  -515125392 (0xE14BCF70)
--     m21=   402453724 (0x17FCF4DC)        m22=  -128758332 (0xF8534DC4)
--- Det 1895185916 (0x70F63DFC)
--- Mat:  8 --------------------------------------------------------------  8
-- Inp A= 29209 (0x7219)  B= 11960 (0x2EB8)  C=  6325 (0x18B5)
--     D= 29731 (0x7423)  E= -7997 (0xE0C3)  F= 31428 (0x7AC4)
-- Res m11=  -233584373 (0xF213C90B)        m12=   375908089 (0x1667E6F9)
--     m21=  -288339832 (0xEED04888)        m22=    94005776 (0x059A6A10)
--- Det 832594536 (0x31A06268)
--- Mat:  9 --------------------------------------------------------------  9
-- Inp A= 19372 (0x4BAC)  B=  1359 (0x054F)  C=  5413 (0x1525)
--     D= 17522 (0x4472)  E=-21268 (0xACEC)  F= 18284 (0x476C)
-- Res m11=  -412003696 (0xE7715290)        m12=    24867328 (0x017B7200)
--     m21=  -487781580 (0xE2ED0B34)        m22=     6234924 (0x005F232C)
--- Det -1002784576 (0xC43AB8C0)
--- Mat: 10 -------------------------------------------------------------- 10
-- Inp A=-14692 (0xC69C)  B= 32685 (0x7FAD)  C= 21683 (0x54B3)
--     D=-22120 (0xA998)  E=-16923 (0xBDE5)  F=-20253 (0xB0E3)
-- Res m11=   248632716 (0x0ED1D58C)        m12=  -661983997 (0xD88AED03)
--     m21=     7395351 (0x0070D817)        m22=  -165492764 (0xF622C7E4)
--- Det -692833941 (0xD6B4316B)
--- Mat: 11 -------------------------------------------------------------- 11
-- Inp A= 13646 (0x354E)  B= 20337 (0x4F71)  C= 28965 (0x7125)
--     D=-26866 (0x970E)  E=   439 (0x01B7)  F= -6972 (0xE4C4)
-- Res m11=     5990594 (0x005B68C2)        m12=  -141775918 (0xF78CABD2)
--     m21=      921461 (0x000E0F75)        m22=   -35445292 (0xFDE325D4)
--- Det 1493497262 (0x5904F5AE)
--- Mat: 12 -------------------------------------------------------------- 12
-- Inp A= 26180 (0x6644)  B= 11163 (0x2B9B)  C= 10287 (0x282F)
--     D= -2014 (0xF822)  E=-26450 (0x98AE)  F=  5685 (0x1635)
-- Res m11=  -692461000 (0xD6B9E238)        m12=    63487835 (0x03C8BF5B)
--     m21=  -218820850 (0xF2F50F0E)        m22=    15873686 (0x00F23696)
--- Det -1085632298 (0xBF4A90D6)
--- Mat: 13 -------------------------------------------------------------- 13
-- Inp A= 26563 (0x67C3)  B= 23692 (0x5C8C)  C= 27760 (0x6C70)
--     D=-25586 (0x9C0E)  E= 15398 (0x3C26)  F= 21544 (0x5428)
-- Res m11=   409017074 (0x18611AF2)        m12=   510447011 (0x1E6CCDA3)
--     m21=    33475252 (0x01FECAB4)        m22=   127607286 (0x079B21F6)
--- Det -154017296 (0xF6D1E1F0)
--- Mat: 14 -------------------------------------------------------------- 14
-- Inp A=  7169 (0x1C01)  B=-16989 (0xBDA3)  C= 23407 (0x5B6F)
--     D= -7831 (0xE169)  E= 12758 (0x31D6)  F=-27472 (0x94B0)
-- Res m11=    91462102 (0x057399D6)        m12=   466728977 (0x1BD1B811)
--     m21=   198718608 (0x0BD83490)        m22=   116696028 (0x06F4A3DC)
--- Det -1517258664 (0xA5907858)
--- Mat: 15 -------------------------------------------------------------- 15
-- Inp A=-31140 (0x865C)  B=-17283 (0xBC7D)  C= 22754 (0x58E2)
--     D=-15719 (0xC299)  E=-28395 (0x9115)  F= -9494 (0xDAEA)
-- Res m11=   884220300 (0x34B4218C)        m12=   164053662 (0x09C7429E)
--     m21=  -199758825 (0xF417EC17)        m22=    41028235 (0x02720A8B)
--- Det -1997337902 (0x88F30AD2)


