library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.snes_ctrl_pkg.all;

--Short Overview how the Snes-Gamepad works: (parrallel-in/ serial-out shift register)

--Start: parallel load
--1.) latch='1' => gamepad loads each button state in the shift reg
--2.) after each rising_edge(clk) outputs the data of each btn state

--DATA_FORMAT:
--two byte = 16 bit wide shift reg
--Output Btns: (last four are always 1s)
--[B,Y,SE,ST,up,down,left,right,A,X,L,R,'1','1','1','1']
--Example Output:
--[0,1,1,0,0,0,0,1,1,0,0,0,'1','1','1','1']


--TODO: now write a module snes_cntrl taht communicates with the snes_gamepad and gets the data from the gamepad
--TODO: study the SNEW Controller Package
	--use snes_ctrl_state_t record for the data + 4bit for '1' at the end
	--reset the values with: SNES_CTRL_STATE_RESET_VALUE
	--Use Conversion Functions:
	--to_sulv(snes_ctrl_state_t) return std_ulogic_vector, 12bit std_ulogic_vector
	--to_snes_ctrl_state(std_ulogic_vector) return snes_ctrl_state_t

--Generic Values that must be consider
	--CLK_FREQ        : integer := 50_000_000; --MAIN CLOCK
	--CLK_OUT_FREQ    : integer := 100_000; --Generated clk that is send to SNES_GAMEPAD
	--REFRESH_TIMEOUT : integer := 1000 --TODO??? wait time to get the data? or what is this

--SNES_CTRL
--clk 
--res_n
--ctrl_state (current received SNES_GAMEPAD state?)


--Communication with the SNES_GAMEPAD:
--START: send latch impulse to gamepad
--[ SNES_CTRL ] ----> snes_latch='1' ----> [ SNES_GAMEPAD ]

--Send snes_clk signal to gamepad and get the Gamepad data on rising_edge(snes_clk)
--[ SNES_CTRL ] ----> snes_clk  -----> [ SNES_GAMEPAD ]
--[ SNES_CTRL ] <---- snes_data <----- [ SNES_GAMEPAD ]




architecture arch of snes_ctrl is
	-- TODO: Declare signals, subprograms, constants and types as needed
begin

	-- TODO: Implement

end architecture;
