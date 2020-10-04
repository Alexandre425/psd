library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
 port ( ent : in std_logic_vector (7 downto 0); --Dados de entrada
        slct : in std_logic_vector (1 downto 0); --Sele��o da opera��o a realizar na ALU
        clk,rst: in std_logic; --Clock e reset
        ent_out, res : out std_logic_vector (7 downto 0) --Dados de entrada e sa�da do registo 2, ambos sinais a representar no display de 7 segmentos; Sa�da do registo 2 
       ); 
end datapath;

architecture behavioral of datapath is
 signal unsg_add, unsg_multip : unsigned(7 downto 0); -- Sinais das duas opera��es aritm�ticas em representa��o sem sinal
 signal logic_or, rtr , res_alu, reg1, reg2 : std_logic_vector (7 downto 0); -- Sinais que resultam das opera��es : Or e rotate right; Resultado da ALU; Sa�das dos registos

begin
 
-- ALU
with slct select --Sele��o da opera��o a realizar consoante os bits do input "oper" (MUX)
    res_alu <=  std_logic_vector(unsg_add) when "00", 
                std_logic_vector(unsg_multip) when "01",
                logic_or when "10",
                rtr when others;
                
                -- Implementa��o das opera��es a realizar na ALU
                unsg_add <= unsigned(reg1)+ unsigned(reg2);
                unsg_multip <= unsigned(reg1)* unsigned(reg2);
                logic_or <= reg1 or reg2;
                rtr <= reg2(0) & reg2(7 downto 1); 
                
-- Registers                
process(clk)
begin
    if (clk'event and clk = '1') then
        reg1 <= ent;
        reg2 <= res_alu;
    end if;
  end process;
  
res <= reg2;
ent_out <= ent;  
    
    
end behavioral;