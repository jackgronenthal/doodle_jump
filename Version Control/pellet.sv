module pellet_(input logic [10:0] x_position_in, 
				  input logic [10:0] y_position_in, 
				  input logic Clk, Reset, Shoot,
				  output logic [10:0] x_position_out,
				  output logic [10:0] y_position_out);
				  
				  
parameter X_MAX = 10'd640;
parameter Y_MAX = 10'd480;
parameter X_MIN = 10'd0;
parameter Y_MIN = 10'd0;

logic [3:0] index_counter;
logic load_array_ld, Load;
logic [15:0] load_array_in, load_array_out;
logic  [15:0] PelletX [15:0][15:0];
logic  [15:0] PelletY [15:0][15:0];

register16 pelletX(.Clk(Clk), .Reset(Reset), .Load(Load), .index(index_counter), .D(), .Q(PelletX));
register16 pelletY(.Clk(Clk), .Reset(Reset), .Load(Load), .index(index_counter), .D(), .Q(PelletY));

register load_array(.Clk(Clk), .Reset(Reset), .Load(load_array_ld), .D(load_array_in), .Q(load_array_out));
register Draw_pellet(.Clk(Clk), .Reset(Rest), .Load(), .D(), .Q());




always_ff @ (posedge Clk)
begin
	if(Reset)
		begin
			index_counter <= -(4'd1); 
			Load <= 1'b0;
		//	PelletX <= {};
			PelletY <= '{default: 0};
		end
	else
		begin
			if(Shoot)
				begin
					Load <= 1'b1;
					index_counter <= index_counter + 1; 
					if(load_array_out == 0)
						begin
							load_array_in <= 15'd1;
						end
					else
						begin
							load_array_in <= load_array_in * 2;
						end
					
				end
		end 
end




endmodule 