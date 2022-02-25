-- Tomer Vaknin
-- 316266048

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity valid_final is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;
	valid_sm	:in std_logic;
	valid_rx	:in std_logic;
	
	valid		:out std_logic
	);
end entity valid_final;

architecture arc_valid_final of valid_final is

-- Block to calc' RX valid AND SM valid,
-- both required for alid mov_x, mov_y

begin

valid_process: process(clk, rst_n)
begin
	if (rst_n = '0') then
		valid	<=	'0';
		
	elsif falling_edge(clk) then
		valid	<=	valid_sm AND valid_rx;
	end if;

end process;
end architecture arc_valid_final;