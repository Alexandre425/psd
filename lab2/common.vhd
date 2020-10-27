library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package common is
    -- Defines the signal that controls which operation the ALU performs
    type alu_operation is (ALU_ADD, ALU_SUB);
    
    -- Index of each of the registers for data/control arrays
    constant R1_IDX : integer := 0;
    constant R2_IDX : integer := 1;
    constant R3_IDX : integer := 2;
    constant R4_IDX : integer := 3;
    constant R5_IDX : integer := 4;
    constant R6_IDX : integer := 5;
end common;
