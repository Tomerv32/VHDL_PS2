-- Tomer Vaknin
-- 316266048

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rx_entity is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;
	B			:in std_logic_vector(2 downto 0);	-- SM control
	clk_12		:in std_logic;
	data		:in std_logic;
	
	cnt_11		:out std_logic_vector(2 downto 0);	-- SM control
	mov_x		:out std_logic_vector(8 downto 0);
	mov_y		:out std_logic_vector(8 downto 0);
	valid_rx	:out std_logic
	);
end entity rx_entity;

architecture arc_rx_entity of rx_entity is

signal data_general	:std_logic_vector(9 downto 0);	-- Shift registers
signal data_x		:std_logic_vector(9 downto 0);
signal data_y		:std_logic_vector(9 downto 0);

signal parity_t		:std_logic_vector(2 downto 0);	-- Parity calc

signal cnt_11_s		:integer;						-- Counter
signal flag			:std_logic;						-- Start bit flag

begin

-- Block to receive and handle data from mouse (TB)

-- Valid result is only relevant when state machine state = valid,
-- after Byte_3 state.
-- Calc' relevant data directly - Overflows and parity bits

valid_rx	<=	parity_t(0) AND parity_t(1) AND parity_t(2)
		AND (NOT data_general(7))  AND (NOT data_general(6));

-- Sign bit + data byte
mov_x		<=	data_general(4) & data_x(7 downto 0);	-- sign bit + data
mov_y		<=	data_general(5) & data_y(7 downto 0);

receive_process: process(clk_12, rst_n)
begin
	if(rst_n = '0') then
		cnt_11			<=	(others	=> '0');
		cnt_11_s		<=	0;
		parity_t		<=	(others	=> '0');
		data_general	<=	(others	=> '0');
		data_x			<=	(others	=> '0');
		data_y			<=	(others	=> '0');
		flag 			<= 	'0';
		

	elsif falling_edge(clk_12) then
		cnt_11 <= (others	=> '0');
		case B is
			when "001"	=>
				-- Start bit won't enter the shift register.
				if (data = '0' AND flag = '0') then
					flag	<=	'1';
					parity_t	<=	(others	=> '0');
				end if;
				
				if (flag = '1') then
					-- Calc parity using TFF, includes stop bit and parity bit
					-- '1' means parity bit is correct
					if (data = '1') then
						parity_t(0)	<=	NOT parity_t(0);
					end if;
					
					-- Shift register to store incoming data
					data_general	<=	data & data_general(9 downto 1);
					-- Counter to stop after 10 bits (Ignoring start bit)
					cnt_11_s	<=	cnt_11_s + 1;
					
				end if;
				
			when "010"	=>
				if (data = '0' AND flag = '0') then		-- Start bit
					flag	<=	'1';
				end if;
			
				if (flag = '1') then
					if (data = '1') then
						parity_t(1)	<=	NOT parity_t(1);
					end if;
					
					data_x		<=	data & data_x(9 downto 1);
					cnt_11_s	<=	cnt_11_s + 1;
				end if;

				
			when "100"	=>
				if (data = '0' AND flag = '0') then		-- Start bit
					flag	<=	'1';
				end if;
			
				if (flag = '1') then
					if (data = '1') then
						parity_t(2)	<=	NOT parity_t(2);
					end if;
					data_y		<=	data & data_y(9 downto 1);
					cnt_11_s	<=	cnt_11_s + 1;
				end if;

			when others	=>
			
		end case;

		-- Packet and. State machine control lines and counter reset.
		if (cnt_11_s = 9) then
			cnt_11		<=	B and "111"; 
			cnt_11_s	<=	0;
			flag 		<= 	'0';
		end if;
		
	end if;

end process;

end architecture arc_rx_entity;