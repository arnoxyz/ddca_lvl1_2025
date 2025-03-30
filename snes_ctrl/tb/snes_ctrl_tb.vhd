library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_util_pkg.all;
use work.snes_ctrl_pkg.all;

entity snes_ctrl_tb is
end entity;

architecture bench of snes_ctrl_tb is
	signal clk   : std_ulogic;
	signal res_n : std_ulogic;
	signal snes_clk   : std_ulogic;
	signal snes_latch : std_ulogic;
	signal snes_data  : std_ulogic;
	signal ctrl_state : snes_ctrl_state_t;

	shared variable rnd : random_t;
begin

	uut : snes_ctrl
	generic map (
		CLK_FREQ        => 50_000_000,
		CLK_OUT_FREQ    => 100_000,
		REFRESH_TIMEOUT => 1000
	)
	port map (
		clk        => clk,
		res_n      => res_n,
		snes_clk   => snes_clk,
		snes_latch => snes_latch,
		snes_data  => snes_data,
		ctrl_state => ctrl_state
	);

	-- Stimulus process
	stimulus: process
		procedure generate_snes_data_input(buttons : snes_ctrl_state_t) is
		begin
			-- wait for the falling edge on the snes_latch signal to start transmission
			wait until falling_edge(snes_latch);

			-- TODO: Create waveform for snes_data
		end procedure;
	begin
		report "Simulation start";

		-- TODO: Check your design

		-- Example for generating random input data
		generate_snes_data_input(to_snes_ctrl_state(rnd.gen_sulv_01(12)));

		report "Simulation end";
		-- End simulation
		wait;
	end process;
end architecture;

