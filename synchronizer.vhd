-- Tomer Vaknin
-- 316266048


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity synchronizer is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;

	d_in		:in std_logic;
	
	d_out		:out std_logic
	);
end entity synchronizer;

architecture arc_synchronizer of synchronizer is
 
begin
	sync_process: process(clk, rst_n)
	begin
		if (rst_n = '0') then
			d_out <= '1';
	-- sync on rising edge, will be ready on falling edge if necessary
		elsif rising_edge(clk) then
			d_out <= d_in;
		end if;

	end process;
 
end architecture arc_synchronizer;