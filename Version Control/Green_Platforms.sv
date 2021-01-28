module Green_platform( input Clk, Reset,          // The clock indicating a new frame (~60Hz)
input logic [9:0] doodle_x, output logic [9:0] Platform_Y, input logic Frame_Clk);

parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
parameter [9:0] Progress = 9'd64;
logic [9:0] Platform_Y_Motion_in, Platform_Y_Motion, Platform_Y_Pos, Platform_Y_Pos_in;

assign Platform_Y = Platform_Y_Pos;

 
always_ff @ (posedge Clk)
if(Reset)
begin
	Platform_Y_Pos <= 10'd300;
end
else
begin
Platform_Y_Pos <= Platform_Y_Pos_in;
Platform_Y_Motion <= Platform_Y_Motion_in;
end

always_comb begin
Platform_Y_Pos_in = Platform_Y_Pos;
Platform_Y_Motion_in = Platform_Y_Motion;
if(Frame_Clk)
begin
  if(doodle_x + Progress >= Ball_X_Max)
		begin
			Platform_Y_Pos_in = (Ball_Y_Step)*10;
			Platform_Y_Pos_in = Platform_Y_Pos + Platform_Y_Motion;
		end
	end
end

endmodule
