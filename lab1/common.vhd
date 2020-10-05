library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package common is
    type alu_operation is (ALU_ADD, ALU_MULT, ALU_OR, ALU_RTR);
    constant DISP_ENT: std_logic := '0';
    constant DISP_RES: std_logic := '1';   
end common;