module game_controller(input logic 	Clk,
												Reset,
							  input logic 	[3:0] KEY,
							  input logic 	[15:0] SW,
							  output logic [2:0] color_mapper,
							  output logic reset_game,
							  output logic [15:0] Settings_INPUT_out_,
														 Settings_COLOR_out_,
							  input logic [9:0] doodle_y
							  );
// Output State Definitions //
// Color_mapper:
// 3'b000 --> Welcome (escape)
// 3'b001 --> Welcome (settings)
// 3'b010 --> Game
// 3'b011 --> Death
// 3'b100 --> Settings_INPUT
// 3'b101 --> Settings_COLOR


// ******************************************** //
//			     Instantiating Logic
// ******************************************** //

logic LD_Settings_INPUT, LD_Settings_COLOR, Change_Color, Settings_INPUT_in_Flag, LD_Settings_INPUT_Flag, Switched_INPUT_mode;
logic [15:0] Settings_INPUT_in, Settings_INPUT_out, Settings_COLOR_out, Settings_COLOR_in;

logic [1:0] Color_Index;

parameter KEYBOARD = 1'b0;
parameter ACCELEROMETER = 1'b1;
parameter YELLOW = 1'b0;

assign Settings_INPUT_out_ = Settings_INPUT_out;
assign Settings_COLOR_out_ = Settings_COLOR_out;

// ******************************************** //
//			      Game Controller FSM
// ******************************************** //

enum logic [3:0] {Welcome_ESCAPE,
									Welcome_SETTINGS,
									Game,
									Game_setup,
									Death,
									Settings_INPUT,
									Settings_COLOR}
									State, Next_state;

always_ff @ (posedge Clk)
begin
	if(Reset)
		begin
			State <= Welcome_ESCAPE;
			Settings_INPUT_in = KEYBOARD;
			LD_Settings_INPUT = 1'b1;
			Settings_COLOR_in = YELLOW;
			LD_Settings_COLOR = 1'b1;
		end
	else
		begin
			State <= Next_state;
			if(~KEY[3])
				begin
					if(Switched_INPUT_mode)
						begin
							Switched_INPUT_mode <= 1'b0;
							Settings_INPUT_in <= ~Settings_INPUT_out;
							LD_Settings_INPUT <= 1'b1;
						end
				end
			else
				Switched_INPUT_mode = 1'b1;
		end
end

always_ff @ (posedge Clk)
begin
	if(Reset)
		begin
			Color_Index <= 2'b00;
		end
	else if(Change_Color)
		begin
			Color_Index <= Color_Index + 1; // Increment to next color in color array
		end
	else
		begin
			Color_Index <= Color_Index; // Maintain current value
		end
end

always_comb
begin
	Next_state = State;
	color_mapper = 3'b000;
	Settings_INPUT_in_Flag = 1'b0;
	unique case (State)
		Welcome_ESCAPE:
		begin
			//color_mapper = 3'b000;
			if(~KEY[1]) // Temporary enter key ADD ENTER KEY HERE
				Next_state = Welcome_SETTINGS;
			else if(~KEY[3])
				Next_state = Game_setup;
			else
				Next_state = Welcome_ESCAPE;
		end

		Welcome_SETTINGS:
		begin
			if(~KEY[2])
				Next_state = Welcome_ESCAPE;
			else if(~KEY[3])
				Next_state = Settings_INPUT;
			else
				Next_state = Welcome_SETTINGS;
		end

		Game_setup:
			Next_state = Game;
			
		Game:
		begin
			if(SW[2])
				Next_state = Death;
			else if(doodle_y >= 10'd480 && doodle_y < 10'd490 && ~SW[15])
				Next_state = Death;
			else
				Next_state = Game;
		end

		Death:
		begin
			if(SW[3])
				Next_state = Welcome_ESCAPE;
			else
				Next_state = Death;
		end

		Settings_COLOR:
		begin
			if(~KEY[2])
				Next_state = Settings_INPUT;
			else if(SW[3])
				Next_state = Welcome_ESCAPE;
			else 
				Next_state = Settings_COLOR;
		end

		Settings_INPUT:
		begin
			if(~KEY[1])
				Next_state = Settings_COLOR;
			else if(SW[3])
				Next_state = Welcome_ESCAPE;
			else
				Next_state = Settings_INPUT;
		end

		default:
			Next_state = Welcome_ESCAPE;
	endcase

	case (State)
		Welcome_ESCAPE:
		begin
			color_mapper = 3'b000;
			reset_game = 1'b0;
			Change_Color = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
		end

		Welcome_SETTINGS:
		begin
			color_mapper = 3'b001;
			reset_game = 1'b0;
			Change_Color = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
		end

		Game_setup:
		begin
			reset_game = 1'b1;
			Change_Color = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
			color_mapper = 3'b010;
		end

		Game:
		begin
			color_mapper = 3'b010;
			reset_game = 1'b0;
			Change_Color = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
		end

		Death:
		begin
			color_mapper = 3'b011;
			reset_game = 1'b0;
			Change_Color = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
		end


		Settings_COLOR:
		begin
		
		if(~KEY[3])
			Change_Color = 1'b1; 
		else
			Change_Color = 1'b0;
			
			color_mapper = 3'b101;
			reset_game = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
		end

		Settings_INPUT:
		begin
			if(~KEY[3])
				Settings_INPUT_in_Flag = 1'b1;//~Settings_INPUT_out;
			else
				Settings_INPUT_in_Flag = 1'b0;
			color_mapper = 3'b100;
			reset_game = 1'b0;
			Change_Color = 1'b0;
		end

		default:
		begin
			color_mapper = 3'b000;
			reset_game = 1'b0;
			Change_Color = 1'b0;
			Settings_INPUT_in_Flag = 1'b0;
		end
	endcase
end



register Settings_INPUT_current(.Clk(Clk), .Reset(Reset), .Load(LD_Settings_INPUT), .D(Settings_INPUT_in), .Q(Settings_INPUT_out));
register Settings_COLOR_current(.Clk(Clk), .Reset(Reset), .Load(LD_Settings_COLOR), .D(Settings_COLOR_in), .Q(Settings_COLOR_out));

endmodule
