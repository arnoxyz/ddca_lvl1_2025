--SNES_CTRL: Main Goal is to get the data from the snes_controller in an easy way and save it in ctrl_state : out using the provided type snes_ctrl_state_t
/*
  Reads the Inputs of a snes gamepad 
  FORMAT: [B,Y,SE,ST,up,down,left,right,A,X,L,R,'1','1','1','1']
                ___________
               |           | 
    --clk--->  | SNES_CTRL | --- ctrl_state -->
    --res_n->  |           |
                ___________ 

Implementation details: (need to know how the snes controller works and saves its data)
  communicates with a SNES_GAMEPAD by using the signals (snes_clk, snes_latch, snes_data
     ___________                    __________________
    |           | --snes_clk-----> |                 |
    | SNES_CTRL | --snes_latch---> | SNES_Controller |
    |           | <-snes_data---   |                 |
     ___________                   ___________________


SNES_CTRL_Details:
  parallel loads all current states (each btn pressed or not)
  seriell shifts them out (internally with a shift register)
  the shifting is done by always shift 1 value on each rising_edge(clk) 
  FORMAT of the shifted data is : [B,Y,SE,ST,up,down,left,right,A,X,L,R,'1','1','1','1']
  the last 4 bits are always '1', Data word is 2 Byte long (16 bits) and the ctroller has only 12 inputs (16-12 = 4 bits)
*/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snes_ctrl_pkg.all;
use work.math_pkg.all;

entity snes_ctrl is
  generic (
    CLK_FREQ        : integer := 50_000_000; --main-clk
    CLK_OUT_FREQ    : integer := 100_000;    --clk freq for snes communication
    REFRESH_TIMEOUT : integer := 1000        --time wait to poll data again
  );
  port (
  --sync-design
    clk        : in  std_ulogic;
    res_n      : in  std_ulogic;

  --snes-ctrl-signals (communication)
    snes_clk   : out std_ulogic;
    snes_latch : out std_ulogic;
    snes_data  : in  std_ulogic;

  --the read inputs from the snes controller
    ctrl_state : out snes_ctrl_state_t
  );
end entity;

architecture arch of snes_ctrl is
	type fsm_state_t is (IDLE, READ_INPUT, WAIT_NEXT_INPUT);
	type fsm_state_reg_t is record
		state : fsm_state_t;
    ctrl_state_internal : snes_ctrl_state_t;
    read_cnt : unsigned(3 downto 0);
    clk_cnt : unsigned(log2c(CLK_FREQ) downto 0 );
	end record;

	constant STATE_REG_NULL : fsm_state_reg_t := (state => IDLE, ctrl_state_internal => SNES_CTRL_STATE_RESET_VALUE, others => (others => '0'));
	signal s, s_nxt : fsm_state_reg_t;

begin
	sync : process(clk, res_n) is 
	begin 
		if res_n = '0' then 
			s <= STATE_REG_NULL;
		elsif rising_edge(clk) then 
			s <= s_nxt;
		end if;
	end process;

	comb : process(all) is 
	begin 
    s_nxt <= s;
    ctrl_state <= s.ctrl_state_internal;
    
    case s.state is 
      when IDLE =>
      when READ_INPUT =>
      when WAIT_NEXT_INPUT =>
    end case;
	end process;
end architecture;
