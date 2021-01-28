module gravity (
                output logic [9:0] position_y_out, y_velocity,
                input logic Clk, Frame_Clk, Reset, SW, jump, activate_gravity,
					 output logic [15:0] Counter_,
					 output logic move_platforms_down
);

// ******************************************** //
//			      Instantiating Variables
// ******************************************** //
parameter [9:0] STARTING_Y_POSITION = 10'd336;
parameter [9:0] Ball_Y_Max = 10'd639;
parameter [9:0] Ball_Y_Min = 10'd0;
parameter [9:0] Sprite_Y_Size = 10'd64;
parameter [9:0] GENERATE_ELEVATION = 10'd100;


logic [9:0] Sprite_Y_Pos,
            Sprite_Y_Motion,
            Sprite_Y_Step,
            Sprite_Y_Pos_in,
            Sprite_Y_Motion_in,
				Gravity_effect;
logic [5:0] GRAVITY;
logic [9:0] Ball_Y_Step;   // The incremental velocity
logic [31:0] Counter;





// ******************************************** //
//			               Logic
// ******************************************** //

assign position_y_out = Sprite_Y_Pos;
assign Counter_ = Counter;

always_ff @ (posedge Clk)
	begin
		if(Sprite_Y_Pos <= GENERATE_ELEVATION && y_velocity >= 0)
			move_platforms_down <= 1'b1;
		else
			move_platforms_down <= 1'b0;
	end

always_ff @ (posedge Clk)
begin
  Sprite_Y_Pos <= Sprite_Y_Pos_in;
  Sprite_Y_Motion <= Sprite_Y_Motion_in + Gravity_effect;
  if(Reset)
    begin
      Sprite_Y_Pos <= STARTING_Y_POSITION;
      Sprite_Y_Motion <= 10'd0;
		Counter <= 15'd0;
    end
  else if(SW)
	 begin
		Sprite_Y_Motion <= 10'd0;
	 end
  else if(jump && Frame_Clk)
	begin
		Sprite_Y_Motion <= -(10'd10);
	end
  else
    begin
		if(Counter >= 6000000)
			begin
				Gravity_effect <= GRAVITY;
				Counter <= 15'd0;
			end
		else
			begin
				Gravity_effect <= 1'b0;
				Counter <= Counter + 1;
			end
	end
end


always_comb
begin
	Sprite_Y_Pos_in = Sprite_Y_Pos;
	Sprite_Y_Motion_in = Sprite_Y_Motion;
	if(Frame_Clk)
	begin
//		if(jump)
//			begin
//				Sprite_Y_Motion_in = 5'd20;
//			end
		Sprite_Y_Pos_in = Sprite_Y_Pos + Sprite_Y_Motion;
	end
end

always_comb
begin
	if(activate_gravity)
		GRAVITY = 6'd3;
	else
		GRAVITY = 6'd0;
end

endmodule


module platforms ( input logic [9:0]  doodle_y, doodle_x, 
						 output logic [9:0] position_y_out0, position_x_out0,
												  position_y_out1, position_x_out1,
												  position_y_out2, position_x_out2,
												  position_y_out3, position_x_out3,
												  position_y_out4, position_x_out4,
												  position_y_out5, position_x_out5,
												  position_y_out6, position_x_out6,
						 output logic [3:0] num_active, pointer_, 
						 output logic jump, 
						 input logic Clk, Frame_Clk, Reset, Generate, SW7, SW8, move_platforms_down,
						 output logic [7:0] col);
	
   parameter [6:0] head_feet_displacement = 7'd58;
	parameter [10:0] update_offset = 11'd100;
   parameter [9:0] Initial_Y = 10'd250;
	logic [3:0] pointer;
	logic [3:0] num_active_platforms;
	logic Generation_failed, move_down_ready, move_down;
	logic [15:0] counter;
	logic [9:0] position_y_in0,
					position_y_in1,
					position_y_in2,
					position_y_in3, 
					position_y_in4, 
					position_y_in5,
					position_y_in6;
					
	logic [10:0] movement_counter;
	
	
	logic [9:0] vertical_velocity, vertical_velocity_in;
	
	assign num_active = num_active_platforms;
	assign pointer_ = pointer;
	
	always_ff @ (posedge Frame_Clk)
		begin
			if(Reset)
				begin
					movement_counter <= 10'd0;
					move_down_ready <= 1'b1;
					move_down <= 1'b0;
				end
			else if(move_platforms_down || movement_counter > 0)
				begin
					move_down <= 1'b1;
					if(move_down_ready)
						begin
							movement_counter <= 10'd120;
							move_down_ready <= 1'b0;
						end
					else
						movement_counter <= movement_counter - 1;
				end
			else
				move_down = 1'b0;
		end
	
	always_ff @ (posedge Clk)
		begin
			counter <= counter + 1;
			position_y_out0 <= position_y_in0; 
			position_y_out1 <= position_y_in1;
			position_y_out2 <= position_y_in2;
			position_y_out3 <= position_y_in3;
			position_y_out4 <= position_y_in4;
			position_y_out5 <= position_y_in5;
			position_y_out6 <= position_y_in6;
			vertical_velocity <= vertical_velocity_in;
			if(Reset || SW7)
				begin
					counter <= 16'd0;
					col <= 8'd0;
					num_active_platforms <= 4'd0;
					position_y_out0 <= 10'd0;
					position_x_out0 <= 10'd0;
					position_y_out1 <= 10'd0;
					position_x_out1 <= 10'd0;
					position_y_out2 <= 10'd0;
					position_x_out2 <= 10'd0;
					position_y_out3 <= 10'd0;
					position_x_out3 <= 10'd0;
					position_y_out4 <= 10'd0;
					position_x_out4 <= 10'd0;
					position_y_out5 <= 10'd0;
					position_x_out5 <= 10'd0;
					position_y_out6 <= 10'd0;
					position_x_out6 <= 10'd0;
					Generation_failed <= 1'b0;
					vertical_velocity <= 10'd0;
				end
			else if(move_down)
				begin
					vertical_velocity <= 1'd1;
				end
			else
				begin
					vertical_velocity <= 10'd0;
					if(Generate || Generation_failed || SW8) //doodle_y >= 10'd400)
						begin
						pointer <= counter % 8;
							if(col[pointer] == 1'b0)
								begin
									col[pointer] <= 1'b1;
									Generation_failed <= 1'b0;
									num_active_platforms <= num_active_platforms + 1;
									if(pointer == 4'd0)
										begin
											position_y_out0 <= Initial_Y;
											position_x_out0 <= 10'd0;
										end
									else if(pointer == 4'd1) // pointer == 1
										begin
											position_y_out1 <= Initial_Y;
											position_x_out1 <= 10'd80;
										end
									else if(pointer == 4'd2)
										begin
											position_y_out2 <= Initial_Y;
											position_x_out2 <= 10'd160;										
										end
									else if(pointer == 4'd3)
										begin
											position_y_out3 <= Initial_Y;
											position_x_out3 <= 10'd240;									
										end
									else if(pointer == 4'd4)
										begin
											position_y_out4 <= Initial_Y;
											position_x_out4 <= 10'd320;
										end
									else if(pointer == 4'd5)
										begin
											position_y_out5 <= Initial_Y;
											position_x_out5 <= 10'd400;									
										end
									else
										begin
											position_y_out6 <= Initial_Y;
											position_x_out6 <= 10'd480;
										end
								end
							else
								begin
									Generation_failed <= 1'b1;
								end
						end
				end
		end
		
		always_comb
			begin
				position_y_in0 = position_y_out0; 
				position_y_in1 = position_y_out1;
				position_y_in2 = position_y_out2;
				position_y_in3 = position_y_out3;
				position_y_in4 = position_y_out4;
				position_y_in5 = position_y_out5;
				position_y_in6 = position_y_out6;
				vertical_velocity_in = vertical_velocity;
			if(Frame_Clk)
				begin
					position_y_in0 = position_y_out0 + vertical_velocity; 
					position_y_in1 = position_y_out1 + vertical_velocity;
					position_y_in2 = position_y_out2 + vertical_velocity;
					position_y_in3 = position_y_out3 + vertical_velocity;
					position_y_in4 = position_y_out4 + vertical_velocity;
					position_y_in5 = position_y_out5 + vertical_velocity;
					position_y_in6 = position_y_out6 + vertical_velocity;
				end
			end

    always_ff @ (posedge Frame_Clk)
      begin
        if(doodle_x >= position_x_out0 && (doodle_x < position_x_out0 + 10'd60) && (doodle_y >= position_y_out0 + head_feet_displacement) && (doodle_y < position_y_out0 + 10'd40 + head_feet_displacement))
          jump <= 1'b0;
        else if(doodle_x + 5'd15 >= position_x_out1 && (doodle_x < position_x_out1 + 10'd60) && (doodle_y >= position_y_out1 - head_feet_displacement) && (doodle_y < position_y_out1 + 10'd40 - head_feet_displacement))
          jump <= 1'b1;
        else if(doodle_x + 5'd15 >= position_x_out2 && (doodle_x < position_x_out2 + 10'd60) && (doodle_y >= position_y_out2 - head_feet_displacement) && (doodle_y < position_y_out2 + 10'd40 - head_feet_displacement))
          jump <= 1'b1;
        else if(doodle_x + 5'd15 >= position_x_out3 && (doodle_x < position_x_out3 + 10'd60) && (doodle_y >= position_y_out3 - head_feet_displacement) && (doodle_y < position_y_out3 + 10'd40 - head_feet_displacement))
          jump <= 1'b1;
        else if(doodle_x + 5'd15 >= position_x_out4 && (doodle_x < position_x_out4 + 10'd60) && (doodle_y >= position_y_out4 - head_feet_displacement) && (doodle_y < position_y_out4 + 10'd40 - head_feet_displacement))
          jump <= 1'b1;
        else if(doodle_x + 5'd15 >= position_x_out5 && (doodle_x < position_x_out5 + 10'd60) && (doodle_y >= position_y_out5 - head_feet_displacement) && (doodle_y < position_y_out5 + 10'd40 - head_feet_displacement))
          jump <= 1'b1;
        else if(doodle_x + 5'd15 >= position_x_out6 && (doodle_x < position_x_out6 + 10'd60) && (doodle_y >= position_y_out6 - head_feet_displacement) && (doodle_y < position_y_out6 + 10'd20 - head_feet_displacement))
          jump <= 1'b1;
        else
          jump <= 1'b0;
      end
		
		

//		always_comb
//		begin
//			pointer = Clk % 8;
//		end
//						 
						 
endmodule 

				 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
						 
