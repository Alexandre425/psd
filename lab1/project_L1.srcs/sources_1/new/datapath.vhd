library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
 port ( a : in std_logic_vector (7 downto 0);
        oper : in std_logic_vector (1 downto 0);
        clk: in std_logic;
        a_out, res : out std_logic_vector (7 downto 0));
end datapath;

architecture behavioral of datapath is
 signal unsg_add, unsg_multip : unsigned(7 downto 0);
 signal logic_or, rtr , res_alu, reg1, reg2 : std_logic_vector (7 downto 0);

begin
 
-- ALU
--Operations    
with oper select
    res_alu <=  std_logic_vector(unsg_add) when "00",
                std_logic_vector(unsg_multip) when "01",
                logic_or when "10",
                rtr when others;
                
                unsg_add <= unsigned(reg1)+ unsigned(reg2);
                unsg_multip <= unsigned(reg1)* unsigned(reg2);
                logic_or <= reg1 or reg2;
                rtr <= reg2(0) & reg2(7 downto 1); 
                
-- Registers                
process(clk)
begin
    if (clk'event and clk = '1') then
        reg1 <= a;
        reg2 <= res_alu;
    end if;
  end process;
  
res <= reg2;
a_out <= a;  
    
    
end behavioral;