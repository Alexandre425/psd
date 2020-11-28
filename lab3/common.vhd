library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package common is
    type complex_num is array (1 downto 0) of std_logic_vector (31 downto 0);
    constant REAL_PART :         integer := 0;
    constant IMAGINARY_PART :    integer := 1;
    
end common;
