// state machine

module state_machine(input logic Clk, Reset, Run, Bounce,
							output logic [9:0] DrawX, DrawY);


enum logic [2:0] {start_screen, game_start, bounce_up, bounce_down} state, next_state;

always_ff @ (posedge Clk)
begin
	if(Reset)
		state <= game_start;
	else
		state <= next_state;
end

always_comb
begin
	// default next state is the current state
	next_state = state;
	
	// default controls 
	