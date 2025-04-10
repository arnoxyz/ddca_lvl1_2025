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
  constant CLK_SNES_CC : integer := CLK_FREQ / CLK_OUT_FREQ; --clock cycles to wait to gen clk_out_freq from the clk_freq (for snes_clk)

	type fsm_state_t is (START, IDLE, READ_INPUT, WAIT_NEXT_POLL);
	type fsm_state_reg_t is record
		state : fsm_state_t;
    ctrl_state_internal : std_ulogic_vector(11 downto 0); --snes_ctrl_state_t; 
    snes_clk : std_ulogic;
    snes_latch : std_ulogic;
    --Counter for the data from the snes_controller:
    --counts from 0=B, to 11=R for data and then to 12-15='1' = data will be checked but not saved) 
    --[B=0,Y=1,SE=2,ST=3,up=4,down=5,left=6,right=7,A=8,X=9,L=10,R=11,'1'=12,'1'=13,'1'=14,'1'=15]
    data_cnt : unsigned(3 downto 0); 
    --Used to generate the output clk snes_clk
    clk_cnt : unsigned(log2c(CLK_FREQ) downto 0 );
	end record;

	constant STATE_REG_NULL : fsm_state_reg_t := (state => START, ctrl_state_internal => (others => '0'), snes_clk=>'0', snes_latch=>'0', others => (others => '0'));
	signal s, s_nxt : fsm_state_reg_t;


begin
	comb : process(all) is 
    variable local_data : std_ulogic;
	begin 
    s_nxt <= s;
    ctrl_state <= to_snes_ctrl_state(s.ctrl_state_internal);
    snes_clk   <= s.snes_clk;
    snes_latch <= s.snes_latch;
    
    case s.state is 
      when START =>
        --pull latch 
        s_nxt.clk_cnt <= s.clk_cnt + 1;

        if to_integer(s.clk_cnt) = 0 then 
          s_nxt.snes_latch <= '1';
        elsif s.clk_cnt = CLK_SNES_CC / 2 then 
          s_nxt.snes_latch <= '0';
        elsif s.clk_cnt = CLK_SNES_CC -1 then 
          s_nxt.state <= READ_INPUT;
          s_nxt.clk_cnt <= (others=>'0');
        end if;
      when READ_INPUT =>
        --now start pulling data from the controller by inserting clk
        s_nxt.clk_cnt <= s.clk_cnt +1;

        if to_integer(s.clk_cnt) = 0 then 
          s_nxt.snes_clk <= '1';
        elsif s.clk_cnt = CLK_SNES_CC / 2 then 
          s_nxt.snes_clk <= '0';
        elsif s.clk_cnt = CLK_SNES_CC -1 then 
          if s.data_cnt < 11 then 
            --get the data 
            s_nxt.ctrl_state_internal(to_integer(s.data_cnt)) <= snes_data;
          else
            --TODO: insert real error handling here, check if data is '1' else => ERROR
            if snes_data /= '1' then 
              report "ERROR";
            end if;
          end if;
          s_nxt.clk_cnt <= (others=>'0');
          s_nxt.data_cnt <= s.data_cnt + 1;
        end if;

        if s.data_cnt > 15 then 
          s_nxt.state <= WAIT_NEXT_POLL;
          s_nxt.clk_cnt <= (others=>'0');
          s_nxt.data_cnt <= (others=>'0');
        end if;
      when WAIT_NEXT_POLL =>
      when IDLE =>
    end case;
	end process;

	sync : process(clk, res_n) is 
	begin 
		if res_n = '0' then 
			s <= STATE_REG_NULL;
		elsif rising_edge(clk) then 
			s <= s_nxt;
		end if;
	end process;
end architecture;
