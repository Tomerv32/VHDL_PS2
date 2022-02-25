-- Tomer Vaknin
-- 316266048

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity state_machine is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;

	done_s		:in std_logic;
	cnt_11		:in std_logic_vector(2 downto 0);
	
	
	start		:out std_logic;
	B			:out std_logic_vector(2 downto 0);
	valid_sm	:out std_logic
	);
end entity state_machine;

architecture arc_state_machine of state_machine is

	-- State machine control lines are explained on the attached file
	-- Separate INPUT/OUTPUT processes for convenient read

	-- State machine type and signal
	type state is (idle, tx, byte_1, byte_2, byte_3, valid_send);
	signal st	:state;
	
	begin

	-- State machine - INPUT
	input_process: process(clk, rst_n)	 
	begin
		
		-- Reset - return to Idle
		if(rst_n = '0') then
			st			<=	idle;
		
		elsif falling_edge(clk) then
		-- Always save current state
		st <= st;

			case st is
				when idle =>
					st <= tx;
					
				when tx =>
					if (done_s = '1') then
						st <= byte_1;
					end if;
					
				when byte_1 =>
					if (cnt_11 = "001") then
						st <= byte_2;
					end if;
					
				when byte_2 =>
					if (cnt_11 = "010") then
						st <= byte_3;
					end if;
					
				when byte_3 =>
					if (cnt_11 = "100") then
						st <= valid_send;
					end if;
					
				when valid_send =>
					st <= byte_1;
					
				when others	=>
					st <= idle;
			end case;
		end if;
	end process;		


	-- State machine - OUTPUT
	output_process: process(clk, rst_n)
	begin
		if(rst_n = '0') then
			start		<=	'0';
			B			<= (others => '0');
		    valid_sm	<=	'0';
		
		elsif falling_edge(clk) then
			-- Always reset values
			start		<=	'0';
			B			<= (others => '0');
			valid_sm	<=	'0';
		
			case st is			
				when tx =>
					start	<=	'1';
					
				when byte_1 =>
					b(0)	<=	'1';
					
				when byte_2 =>
					b(1)	<=	'1';
					
				when byte_3 =>
					b(2)	<=	'1';
					
				when valid_send =>
					valid_sm	<= '1';
					
				when others	=>
					
			end case;
		end if;
	end process;	
end architecture arc_state_machine;
