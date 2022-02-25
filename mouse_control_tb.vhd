-- Tomer Vaknin
-- 316266048

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mouse_control_tb is
end;

architecture arc_mouse_control_tb of mouse_control_tb is

	component mouse_control
	port(
		clk			:in std_logic;
		rst_n		:in std_logic;
		
		data_mouse	:inout std_logic;
		clk_mouse	:inout std_logic;
		
		valid		:out std_logic;
		mov_x		:out std_logic_vector(8 downto 0);
		mov_y		:out std_logic_vector(8 downto 0)
		);
	end component;

	-- In
	signal clk			:std_logic:= '0';
	signal rst_n		:std_logic:= '0';
	-- Inout
	signal data_mouse_s	:std_logic:= '1';
	signal clk_mouse_s	:std_logic:= '1';
	signal clk_12		:std_logic:= '1';
	-- Out
	signal valid		:std_logic:= '0';
	signal mov_x		:std_logic_vector(8 downto 0):= "000000000";
	signal mov_y		:std_logic_vector(8 downto 0):= "000000000";

	-- Clock processes
	constant clock_period: time := 20 ns;
	constant clock_period_12: time := 81.92 us;	-- T of: 50MHz/2^12 =~12.207kHz
	signal stop_the_clock_12: boolean:=true;
	
	-- Mouse TX
	signal data_send	:std_logic_vector(10 downto 0):= "00000000000";
	signal data_send_s	:std_logic := '1';	-- serial communication bit signal
	signal send_flag	:boolean := false;  -- true = send data, false = receive data


begin

	uut: mouse_control
	port map ( 
		clk        => clk,
		rst_n      => rst_n,
		data_mouse => data_send_s,
		clk_mouse  => clk_mouse_s,
		valid      => valid,
		mov_x      => mov_x,
		mov_y      => mov_y
		);


	-- Initialization - reset
	rst_n	<=	'1' after 50 ns;


	-- Process to receive 0xF6 data
	receive_process: process
	begin
		wait until falling_edge(clk);
		if (send_flag = true) then
			clk_mouse_s <=	clk_12;
			data_send_s	<=	data_mouse_s;
		else
			clk_mouse_s <=	'Z';
			data_send_s	<=	'Z';
		end if;
	end process;	


	-- Process to send data, simulating a PS2 mouse
	send_process: process
	begin

		wait for 1.5 ms;
		send_flag 	<= 	true;
		
		-- Data change at least 5us, maximum 25us, before falling_edge(clk_12)
		-- delays should be = n*T (**n is Natural) + 0.5*T (**Sync is Rising Edge triggered) - [19.56,39.56]us (**T/2 - [5,25]us)
		-- T = clock_period_12 = 81.92us = 1/(50MHz/4096) = 1/12.207kHz
		
		------------------------------------------------------------
		-- 1st Data - 3 bytes in PS2 Protocol
		-- Valid data. Valid is expected to be '1' at the end.


		-- Enable clk_12. '1' when the communication line isn't used
		stop_the_clock_12	<=	false;

		wait for clock_period_12*3;

		-- First packet is "general data"
		data_send	<=	"00001110011";

		wait for clock_period_12;

		-- using a loop to send data in serial communication
		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- X data
		data_send	<=	"01101101101";
		
		-- Some wait to simulate a real-life situation.
		-- delay is calculated as explained above.
		wait for 179.8 us;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- Y data
		data_send	<=	"00010010001";
		
		wait for 179.8 us;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		stop_the_clock_12 	<= true;
		------------------------------------------------------------

		wait for 1 ms;

		------------------------------------------------------------
		-- 2nd Data
		-- Data with overflow. Valid is expected to stay '0'

		stop_the_clock_12	<= false;

		wait for clock_period_12*3;

		-- General data
		data_send	<=	"00001001001";

		wait for clock_period_12;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- X data
		data_send	<=	"01111100101";

		wait for 189.8 us;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- Y data
		data_send	<=	"00111000011";
		
		wait for 189.8  us;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		stop_the_clock_12 	<= true;
		------------------------------------------------------------

		wait for 1 ms;

		------------------------------------------------------------
		-- 3rd Data
		-- Valid data. Valid is expected to be '1' at the end.
		-- Testing different delay times between packets

		stop_the_clock_12	<= false;

		wait for clock_period_12*3;

		-- General data
		data_send	<=	"01001010011";

		wait for clock_period_12;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- X data
		data_send	<=	"01111111101";

		wait for 199.8 us;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		-- Y data
		data_send	<=	"01000000101";
		
		wait for 199.8 us;

		for i in 10 downto 0 loop
			data_mouse_s	<=	data_send(i);
			wait until rising_edge(clk_12);
		end loop;

		stop_the_clock_12 	<= true;
		------------------------------------------------------------
		wait;
	end process;
	
	
	-- 50MHz clock
	clock_50: process
	begin
		wait for clock_period / 2;
		clk	<= (NOT clk);
	end process;
  
  
	-- ~12.207kHz clock - data sending
	clock_12: process
	begin
		wait for clock_period_12 / 2;
		if(stop_the_clock_12 = true) then
			clk_12	<= '1';
		else
			clk_12	<= (NOT clk_12);
		end if;
	end process;

end architecture arc_mouse_control_tb;