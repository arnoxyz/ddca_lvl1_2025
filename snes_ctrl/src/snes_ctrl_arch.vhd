--SNES_CTRL: communicates with a SNES_GAMEPAD and reads the Inputs of that GAMEPAD
  --FORMAT: [B,Y,SE,ST,up,down,left,right,A,X,L,R,'1','1','1','1']

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.snes_ctrl_pkg.all;

architecture arch of snes_ctrl is
	type fsm_state_t is (IDLE, READ_INPUT, WAIT_NEXT_INPUT);
	type fsm_state_reg_t is record
		state : fsm_state_t;
    --add more regs-> coutner for the inputs (increment after each input read)
	end record;

	constant STATE_REG_NULL : fsm_state_reg_t := (state => IDLE);
	signal s, s_nxt : fsm_state_reg_t;

begin
	--sync logic
	sync : process(clk, res_n) is 
	begin 
		if res_n = '0' then 
			s <= STATE_REG_NULL;
		elsif rising_edge(clk) then 
			s <= s_nxt;
		end if;
	end process;

	--comb logic
	comb : process(all) is 
	begin 
    s_nxt <= s;
    
    case s.state is 
      when IDLE =>
      when READ_INPUT =>
      when WAIT_NEXT_INPUT =>
    end case;
	end process;
end architecture;
