library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_util_pkg.all;
use work.snes_ctrl_pkg.all;

entity snes_ctrl_tb is
end entity;

architecture bench of snes_ctrl_tb is
	constant CLK_FREQ        : integer := 50_000_000;
	constant CLK_OUT_FREQ    : integer := 100_000;
	constant REFRESH_TIMEOUT : integer := 1000;
  constant CLK_PERIOD      : time    := 1 sec / CLK_FREQ;

	signal clk   : std_ulogic := '0';
	signal res_n : std_ulogic := '0';
	signal snes_clk   : std_ulogic;
	signal snes_latch : std_ulogic;
	signal snes_data  : std_ulogic;
	signal ctrl_state : snes_ctrl_state_t;

  signal clk_stop : std_ulogic := '0';

	shared variable rnd : random_t;
begin
	-- Stimulus process
	stimulus: process
		procedure generate_snes_data_input(buttons : snes_ctrl_state_t) is
		begin
			-- wait for the falling edge on the snes_latch signal to start transmission
			wait until falling_edge(snes_latch);

			-- transmitt data
      for a in 0 to 11 loop
        snes_data <= not to_sulv(buttons)(a);
        wait until rising_edge(snes_clk);
        report to_string(to_sulv(buttons)(a));
      end loop;
        
			-- transmitt the last 4 bits that are always '1' (so not '1' = '0')
      snes_data <= '0';
      wait until rising_edge(snes_clk);
      snes_data <= '0';
      wait until rising_edge(snes_clk);
      snes_data <= '0';
      wait until rising_edge(snes_clk);
      snes_data <= '0';
      wait until rising_edge(snes_clk);
		end procedure;
	begin
		report "Simulation start";
		-- Example for generating random input data
    res_n <= '0';
    wait for 3*CLK_PERIOD;
    res_n <= '1';
    wait for 3*CLK_PERIOD;

		generate_snes_data_input(to_snes_ctrl_state(rnd.gen_sulv_01(12)));

    clk_stop <= '1';
		report "Simulation end";
		-- End simulation
		wait;
	end process;

  gen_clk : process is 
  begin 
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;

    if clk_stop = '1' then 
      wait;
    end if;
  end process;

	uut : snes_ctrl
	generic map (
		CLK_FREQ        => CLK_FREQ,
		CLK_OUT_FREQ    => CLK_OUT_FREQ,
		REFRESH_TIMEOUT => REFRESH_TIMEOUT
	)
	port map (
		clk        => clk,
		res_n      => res_n,
		snes_clk   => snes_clk,
		snes_latch => snes_latch,
		snes_data  => snes_data,
		ctrl_state => ctrl_state
	);

end architecture;
