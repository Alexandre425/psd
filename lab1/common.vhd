library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package common is
    -- Defines the signal that controls which operation the ALU performs
    type alu_operation is (ALU_ADD, ALU_MULT, ALU_OR, ALU_RTR);
    
    -- Which value is sent to the display by the datapath
    constant DISP_ENT: std_logic := '0';    -- The input
    constant DISP_RES: std_logic := '1';    -- The result (in register 2)
    
    -- Which bit corresponds to which register in enable signal
    constant REG1_BIT: integer := 0;
    constant REG2_BIT: integer := 1;
end common;