module map(	input logic CLK, Reset,
				input logic [10:0] Doodle_X, Doodle_Y,
				output logic [10:0][0:31] map_y_data ,
				output logic Game_Action);

// ******************************************** //
//			      Instantiating Logic
// ******************************************** //

logic [31:0] map_DISPLAY_CELL;
//logic [10:0] map_x_data [0:31];
logic  [10:0][0:31] map_y_data_ ;

//assign map_y_data = map_y_data_;

parameter default_y_data = {10'd20, 10'd20, 10'd20, 10'd20, 10'd20, 10'd20, 10'd20, 10'd20,
									 10'd140, 10'd140, 10'd140, 10'd140, 10'd140, 10'd140, 10'd140, 10'd140,
									 10'd260, 10'd260, 10'd260, 10'd260, 10'd260, 10'd260, 10'd260, 10'd260,
									 10'd380, 10'd380, 10'd380, 10'd380, 10'd380, 10'd380, 10'd380, 10'd380};
	
always_ff @ (posedge CLK)
	begin
		if(Reset)
			begin
				map_DISPLAY_CELL <= 32'd0;
				map_y_data_ <= default_y_data;
			end
		else
			begin
				
			end
	end
	
endmodule 