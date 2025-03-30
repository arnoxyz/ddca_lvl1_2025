library ieee;
use ieee.std_logic_1164.all;

use work.snes_ctrl_pkg.all;


architecture top_arch of top is
	signal ctrl_state : snes_ctrl_state_t;
begin

	snes_ctrl_inst : entity work.snes_ctrl(arch)
	port map (
		clk        => clk,
		res_n      => keys(0),
		snes_clk   => snes_clk,
		snes_latch => snes_latch,
		snes_data  => snes_data,
		ctrl_state => ctrl_state
	);

	-- TODO: Map ctrl_state to ledr

end architecture;

