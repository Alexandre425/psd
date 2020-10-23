library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package common is
    -- Defines the signal that controls which operation the ALU performs
    type alu_operation is (ALU_ADD, ALU_SUB);
end common;