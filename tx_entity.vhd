-- Tomer Vaknin
-- 316266048

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tx_entity is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;
	start		:in std_logic;	-- SM control
	
	done_s		:out std_logic;	-- SM control
	clk_12		:out std_logic;
	data		:out std_logic
	);
end entity tx_entity;

architecture arc_tx_entity of tx_entity is

signal clk_12_s	:std_logic;
signal cnt		:std_logic_vector(11 downto 0);

signal data_s	:std_logic_vector(10 downto 0);
signal cnt_send	:integer;

begin

-- Sending 0xF6 - Mouse initialization
-- Cyclic shift register and int counter
data_p: process(clk_12_s, rst_n)
begin
	if(rst_n = '0') then
		data_s		<= "00110111101";	-- Start, 0xF6 (LSB FIRST), parity, stop bit
		data		<= '1';
		done_s		<= '0';
		cnt_send	<= 0;

	elsif falling_edge(clk_12_s) then
		data		<= '1';
		done_s		<= '0';
		
		if (start = '1') then
			data 	<= data_s(10);
			data_s 	<= data_s(9 downto 0) & data_s(10);
			cnt_send <= cnt_send + 1;
		end if;

		if (cnt_send = 10) then
			cnt_send 	<= 0;
			done_s		<= '1';
		end if;
		
	end if;
end process;


-- Creating 10-16.7kHz clock
-- 50MHz/2^13 Clock, simple implementation with freq. divider - counter
-- clk_12 =~12.207kHz

-- Counter MSB, flip every 2^11 falling_edge(clk)
clk_12_s <= cnt(11);

-- Counter process
clk_12_p: process(clk, rst_n)
begin
	if(rst_n = '0') then
		cnt	<= (others => '0');
		
	elsif falling_edge(clk) then
		-- Overflow --> MSB = 0
		cnt <= cnt + 1;	
		
	end if;
end process;

-- Clock process
clk_p: process(clk, rst_n)
begin
	if(rst_n = '0') then
			clk_12 <= '1';
	elsif falling_edge(clk) then
			clk_12 <= 'Z';
		if (start = '1') then
			clk_12 <= cnt(11);
		end if;
	end if;
end process;
end architecture arc_tx_entity;