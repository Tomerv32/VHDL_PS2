-- Tomer Vaknin
-- 316266048

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mouse_control is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;

	data_mouse	:inout std_logic;
	clk_mouse	:inout std_logic;
	
	valid		:out std_logic;
	mov_x		:out std_logic_vector(8 downto 0);
	mov_y		:out std_logic_vector(8 downto 0)
	);
end entity mouse_control;


architecture arc_mouse_control of mouse_control is

component synchronizer is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;

	d_in		:in std_logic;
	
	d_out		:out std_logic
	);
end component;

component rx_entity is
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
end component;

component tx_entity is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;
	start		:in std_logic;	-- SM control
	
	done_s		:out std_logic;	-- SM control
	clk_12		:out std_logic;
	data		:out std_logic
	);
end component;

component state_machine is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;

	done_s		:in std_logic;
	cnt_11		:in std_logic_vector(2 downto 0);
	
	
	start		:out std_logic;
	B			:out std_logic_vector(2 downto 0);
	valid_sm	:out std_logic
	);
end component;

component valid_final is
port(
	clk			:in std_logic;
	rst_n		:in std_logic;
	valid_sm	:in std_logic;
	valid_rx	:in std_logic;
	
	valid		:out std_logic
	);
end component;


-- Synced signals
signal sync_clk_mouse	:std_logic;
signal sync_data_mouse	:std_logic;

-- Inout control
signal data_tx		:std_logic;
signal clk_tx		:std_logic;

-- Rx valid
signal valid_rx			:std_logic;

-- State machine
signal start			:std_logic;
signal B				:std_logic_vector(2 downto 0);
signal valid_sm			:std_logic;

signal done_s			:std_logic;
signal cnt_11			:std_logic_vector(2 downto 0);


begin

sync_1: synchronizer
port map(

	clk	  => clk,
	rst_n => rst_n,

	d_in  => clk_mouse,

	d_out => sync_clk_mouse 
);

sync_2: synchronizer
port map(

	clk	  => clk,
	rst_n => rst_n,

	d_in  => data_mouse,

	d_out => sync_data_mouse
);

tx: tx_entity
port map(
	clk	=>	clk,
	rst_n	=>	rst_n,
	start	=>	start,

	done_s	=>	done_s,
	clk_12	=>	clk_tx,
	data	=>	data_tx	
);

rx: rx_entity
port map(
	clk			=>	clk,
	rst_n		=>	rst_n,
	B			=>	B,
	clk_12		=>	sync_clk_mouse,
	data		=>	sync_data_mouse,

	cnt_11		=>	cnt_11,
	mov_x		=>	mov_x,
	mov_y		=>	mov_y,
	valid_rx	=>	valid_rx
);

sm: state_machine
port map(
	clk			=>	clk,
	rst_n		=>	rst_n,
    
	done_s		=>	done_s,
    cnt_11		=>	cnt_11,
	
	start		=>	start,
	B			=>	B,
	valid_sm	=>	valid_sm
);

va:	valid_final
port map(
	clk			=>	clk,
	rst_n		=>	rst_n,
	valid_sm	=>	valid_sm,
	valid_rx	=>	valid_rx,

	valid		=>	valid
);

 
	-- Process to set 'Z' on INOUT ports when Tx state is done
	start_process: process(clk, rst_n)
	begin
	
		if (rst_n = '0') then
			data_mouse	<=  	data_tx;
			clk_mouse	<=		clk_tx;
		
		elsif falling_edge(clk) then
			if (start = '0') then
				data_mouse	<=	'Z';
				clk_mouse	<=	'Z';
			else
				data_mouse	<=	data_tx;
				clk_mouse	<= clk_tx;
			end if;
		end if;
		
	end process;
 
 
end architecture arc_mouse_control;