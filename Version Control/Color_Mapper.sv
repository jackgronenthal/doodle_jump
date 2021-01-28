//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.


module  color_mapper (
                input              is_ball,            // Whether current pixel belongs to ball
                input logic debugging_mode,                                  //   or background (computed in ball.sv)
                input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                output logic [7:0] VGA_R, VGA_G, VGA_B,
                input logic [9:0]  DoodleX_right, DoodleY_right, DoodleX_left, DoodleY_left,
					 input logic [1:0]  doodle_direction, // Doodle sprite's current location
					 input logic [7:0]  debug_x0_coor,
					 input logic [2:0]  graphics_control,
					 input logic 		  Clk,
                input logic [3:0]  Color, 
					 output logic[3:0]  weird_platforms,
                input logic [9:0]  Platform_Y,
					 input logic [15:0] Settings_INPUT,
											  Settings_COLOR,
					 input logic [10:0][0:31] map_y_data, 
					 input logic  Reset,
					 input logic [7:0] col_data, 
					 input logic [9:0] position_y_out0, position_x_out0, position_y_out1, position_x_out1, position_y_out2, position_x_out2,
											 position_y_out3, position_x_out3, position_y_out4, position_x_out4, position_y_out5, position_x_out5,
											 position_y_out6, position_x_out6
						 
                );

	 logic [7:0] Red, Green, Blue;
	 logic Draw_Debugger;
	 assign weird_platforms[0] = Draw_Platform4;
	 assign weird_platforms[1] = Draw_Platform5;
	 assign weird_platforms[2] = Draw_Platform6;
	 
 

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

    // Assign color based on is_ball signal
//    always_comb
//    begin
//        if (is_ball == 1'b1)
//        begin
//            // White ball
//            Red = 8'hff;
//            Green = 8'hff;
//            Blue = 8'hff;
//        end
//        else
//        begin
//            // Background with nice color gradient
//            Red = 8'h3f;
//            Green = 8'h00;
//            Blue = 8'h7f - {1'b0, DrawX[9:3]};
//        end
//    end

		logic doodle_on_right, doodle_on_left;
	 // logic[8:0] shape_doodle_x;	// Starting location
	 // logic[8:0] shape_doodle_y;

	// BackGround sprite

		logic[2:0] bg_data;

	// Doodle Sprite
		logic [6:0]  doodle_x_right, doodle_x_left;
		logic [6:0]  doodle_y_right, doodle_y_left;
		logic [8:0]	 welcome_screen_x, welcome_screen_y;
		logic [2:0]  doodle_data_right, doodle_data_left, doodle_data, welcome_screen_out;
		logic[10:0]  img_size = 11'd64;

		//Font Rom Logic
		logic [10:0] font_address;
		logic [7:0] font_data;
		logic Draw_Platform, Draw_Platform0, Draw_Platform1, Draw_Platform2, Draw_Platform3, Draw_Platform4, Draw_Platform5, Draw_Platform6, Draw_welcome_screen;

		logic [10:0] platform_x_start = 10'd400;
		logic [10:0] platform_y_start;
		logic [10:0] welcome_screen_start_x = 10'd120;
		logic [10:0] welcome_screen_start_y = 10'd50;
		logic [5:0]  platform_x0, platform_x1, platform_x2, platform_x3, platform_x4, platform_x5, platform_x6, platform_y0, platform_y1, platform_y2, platform_y3, platform_y4, platform_y5, platform_y6;

		// Welcome Screen Buttons
		logic [10:0] 	escape_sl_x_start = 10'd130;
		logic [8:0] 	escape_sl_y_start = 9'd370;
		logic [10:0] 	escape_un_x_start = 10'd130;
		logic [8:0] 	escape_un_y_start = 9'd370;
		logic [10:0] 	settings_sl_x_start = 10'd330;
		logic [8:0] 	settings_sl_y_start = 9'd370;
		logic [10:0] 	settings_un_x_start = 10'd330;
		logic [8:0] 	settings_un_y_start = 9'd370;
		logic [7:0] 	escape_sl_x, escape_sl_y, escape_un_x, escape_un_y, settings_sl_x, settings_sl_y, settings_un_x, settings_un_y;
		logic [2:0] 	escape_sl_out, escape_un_out, settings_sl_out, settings_un_out;
		logic [2:0] 	platform_out0, platform_out1, platform_out2, platform_out3;
		logic				Draw_escape_un, Draw_escape_sl, Draw_settings_un, Draw_settings_sl;

		// Font
		logic [7:0] Font_x, Font_y;
		logic [7:0] Font_x_start = 10'd200;
		logic [7:0] Font_y_start = 10'd200;
		logic Draw_font;

		// Settings Screen
		logic [3:0] ECEB_out, color_unselected_out, color_selected_out, Settings_INPUT_output; 
		logic [1:0] input_unselected_out, input_selected_out;
		logic [9:0] ECEB_x;
		logic [8:0] ECEB_y;
		logic [9:0] ECEB_x_start = 10'd0;
		logic [8:0] ECEB_y_start = 9'd207;
		logic Draw_ECEB, Draw_Symbol_INPUT;
		logic [17:0] ECEB_address;
		logic [9:0] input_x = 10'd130;
      logic [9:0] color_x = 10'd330;
      logic [9:0] input_y = 10'd88;
		logic Draw_INPUT_sl, Draw_INPUT_un, Draw_COLOR_sl, Draw_COLOR_un;
      logic [13:0] INPUT_sl_address, INPUT_un_address, COLOR_sl_address, COLOR_un_address;

		
		assign platform_y_start	= Platform_Y;
		assign Draw_Platform = Draw_Platform0 || Draw_Platform1 || Draw_Platform2 || Draw_Platform3 || Draw_Platform4 || Draw_Platform5 || Draw_Platform6;

// ===================================================================================================================================== //
//
//																				                  Doodle Color
//
// ===================================================================================================================================== //


	// ******************************************** //
	//			      Assinging Values
	// ******************************************** //

//  logic [15:0] color_red;
//  logic [15:0] color_green;
//  logic [15:0] color_blue;
//
//    // ~~ Yellow Doodle ~~
//    color_red[7:0] = 8'hE7;
//    color_green[7:0] = 8'hDF;
//    color_blue[7:0] =  8'h31;
//
//    // ~~ Blue Doodle ~~
//    color_red[15:8] =     8'h06;
//    color_green[15:8] =   8'h02;
//    color_blue[15:8] =    8'hFF;





// ===================================================================================================================================== //
//
//																				                  SPRITE MODULES
//
// ===================================================================================================================================== //

	// ******************************************** //
	//				Module Instantiations
	// ******************************************** //

				// ~~ DOODLE ~~
					 doodle_right doodle_char_right(.doodle_x(doodle_x_right), .doodle_y(doodle_y_right), .doodle_color_out(doodle_data_right));
					 doodle_left doodle_char_left(.doodle_x((doodle_x_right)), .doodle_y((doodle_y_right+10'd10)), .doodle_color_out(doodle_data_left));

				// ~~ GRAPHIC SCREENS ~~
					 background bg(.back_x(DrawX%10), .back_y(DrawY%10), .back_color_out(bg_data));
					 welcome_screen welcome_graphic(.welcome_screen_x(welcome_screen_x), .welcome_screen_y(welcome_screen_y), .welcome_screen_out(welcome_screen_out));
					 //ECEB eceb_graphic(.ECEB_x(ECEB_x), .ECEB_y(ECEB_y), .ECEB_out(ECEB_out));
					 frame_rom_ECEB ECEB(.read_address(ECEB_address), .Clk(Clk), .data_out(ECEB_out));
				// ~~ PLATFORMS ~~
					 platform platform_0 (.platform_x(platform_x0), .platform_y(platform_y0), .platform_color_out(platform_out0));
					 platform platform_1 (.platform_x(platform_x1), .platform_y(platform_y1), .platform_color_out(platform_out1));
					 platform platform_2 (.platform_x(platform_x2), .platform_y(platform_y2), .platform_color_out(platform_out2));
					 platform platform_3 (.platform_x(platform_x3), .platform_y(platform_y3), .platform_color_out(platform_out3));
					 platform platform_4 (.platform_x(platform_x4), .platform_y(platform_y4), .platform_color_out(platform_out4));
					 platform platform_5 (.platform_x(platform_x5), .platform_y(platform_y5), .platform_color_out(platform_out5));
					 platform platform_6 (.platform_x(platform_x6), .platform_y(platform_y6), .platform_color_out(platform_out6));
					 
					 
					 
				// ~~ UTILITIES ~~
					 font_rom fonts(.addr(((Font_y) + 5'd16*(7'd65))), .data(font_data));

				// ~~ Welcome Screen Graphics ~~
					 settings_unselected settings_unselected(.settings_un_x(settings_un_x), .settings_un_y(settings_un_y), .settings_un_out(settings_un_out));
					 settings_selected settings_selected(.settings_sl_x(settings_sl_x), .settings_sl_y(settings_sl_y), .settings_sl_out(settings_sl_out));
					 escape_unselected escape_unselected(.escape_un_x(escape_un_x), .escape_un_y(escape_un_y), .escape_un_out(escape_un_out));
					 escape_selected escape_selected(.escape_sl_x(escape_sl_x), .escape_sl_y(escape_sl_y), .escape_sl_out(escape_sl_out));

			  // ~~ Settings Screen Graphics ~~
				 frame_rom_COLOR_un color_unselected(.read_address(COLOR_un_address), .Clk(Clk), .data_out(color_unselected_out));
				 frame_rom_COLOR_sl color_selected(.read_address(COLOR_sl_address), .Clk(Clk), .data_out(color_selected_out));
				 frame_rom_INPUT_un input_unselected(.read_address(INPUT_un_address), .Clk(Clk), .data_out(input_unselected_out));
				 frame_rom_INPUT_sl input_selected(.read_address(INPUT_sl_address), .Clk(Clk), .data_out(input_selected_out));
				 frame_rom_INPUT_ACCEL input_accel(.read_address(INPUT_sl_address), .Clk(Clk), .data_out(INPUT_accel_out));
				 frame_rom_INPUT_KEYBOARD input_keyboard(.read_address(INPUT_sl_address), .Clk(Clk), .data_out(INPUT_keyboard_out));
	
	// ******************************************** //
	//				   Conditional Logic
	// ******************************************** //

			// ~~ Welcome Screen ~~
					 always_comb
					 begin
						if(DrawX >= welcome_screen_start_x && DrawX < (welcome_screen_start_x + 10'd400) && DrawY >= welcome_screen_start_y && DrawY < (welcome_screen_start_y + 10'd200))
							begin
								Draw_welcome_screen = 1'b1;
								welcome_screen_x = DrawX - welcome_screen_start_x;
								welcome_screen_y = DrawY - welcome_screen_start_y;
							end
						else
							begin
								Draw_welcome_screen = 1'b0;
								welcome_screen_x = 10'b0;
								welcome_screen_y = 10'b0;
							end

					 end

			// ~~ Platform ~~
					 always_comb
					 begin:Printing_Platform0
						if(DrawX >= position_x_out0 && DrawX < (position_x_out0 + 10'd60) && (DrawY >= position_y_out0) && (DrawY < (position_y_out0+10'd20)))
						begin
							Draw_Platform0 = 1'b1 && col_data[0];
							platform_x0 = DrawX - position_x_out0;
							platform_y0 = DrawY - position_y_out0;
						end
					else
						begin
							Draw_Platform0 =   1'b0; // Set default values for when the platform is not being displayed.
							platform_x0 =      5'b0;
							platform_y0 =      5'b0;
						end
					 end
					 
					 always_comb
					 begin:Printing_Platform1
						if(DrawX >= position_x_out1 && DrawX < (position_x_out1 + 10'd60) && DrawY >= position_y_out1 && DrawY < (position_y_out1+10'd20))
						begin
							Draw_Platform1 = 1'b1 && col_data[1];
							platform_x1 = DrawX - position_x_out1;
							platform_y1 = DrawY - position_y_out1;
						end
					else
						begin
							Draw_Platform1 =   1'b0; // Set default values for when the platform is not being displayed.
							platform_x1 =      5'b0;
							platform_y1 =      5'b0;
						end
					 end
					 
					
					always_comb
					 begin:Printing_Platform2
						if(DrawX >= position_x_out2 && DrawX < (position_x_out2 + 10'd60) && (DrawY >= position_y_out2) && (DrawY < (position_y_out2+10'd20)))
						begin
							Draw_Platform2 = 1'b1 && col_data[2];
							platform_x2 = DrawX - position_x_out2;
							platform_y2 = DrawY - position_y_out2;
						end
					else
						begin
							Draw_Platform2 =   1'b0; // Set default values for when the platform is not being displayed.
							platform_x2 =      5'b0;
							platform_y2 =      5'b0;
						end
					 end
					 
					 always_comb
					 begin:Printing_Platform3
						if(DrawX >= position_x_out3 && DrawX < (position_x_out3 + 10'd60) && DrawY >= position_y_out3 && DrawY < (position_y_out3+10'd20))
						begin
							Draw_Platform3 = 1'b1 && col_data[3];
							platform_x3 = DrawX - position_x_out3;
							platform_y3 = DrawY - position_y_out3;
						end
					else
						begin
							Draw_Platform3 =   1'b0; // Set default values for when the platform is not being displayed.
							platform_x3 =      5'b0;
							platform_y3 =      5'b0;
						end
					 end

           always_comb
           begin:Printing_Platform4
            if(DrawX >= position_x_out4 && DrawX < (position_x_out4 + 10'd60) && DrawY >= position_y_out4 && DrawY < (position_y_out4+10'd20))
            begin
              Draw_Platform4 = 1'b1 && col_data[4];
              platform_x4 = DrawX - position_x_out4;
              platform_y4 = DrawY - position_y_out4;
            end
          else
            begin
              Draw_Platform4 =   1'b0; // Set default values for when the platform is not being displayed.
              platform_x4 =      5'b0;
              platform_y4 =      5'b0;
            end
           end

           always_comb
           begin:Printing_Platform5
            if(DrawX >= position_x_out5 && DrawX < (position_x_out5 + 10'd60) && DrawY >= position_y_out5 && DrawY < (position_y_out5+10'd20))
            begin
              Draw_Platform5 = 1'b1 && col_data[5];
              platform_x5 = DrawX - position_x_out5;
              platform_y5 = DrawY - position_y_out5;
            end
          else
            begin
              Draw_Platform5 =   1'b0; // Set default values for when the platform is not being displayed.
              platform_x5 =      5'b0;
              platform_y5 =      5'b0;
            end
           end

           always_comb
           begin:Printing_Platform6
            if(DrawX >= position_x_out6 && DrawX < (position_x_out6 + 10'd60) && DrawY >= position_y_out6 && DrawY < (position_y_out6+10'd20))
            begin
              Draw_Platform6 = 1'b1 && col_data[6];
              platform_x6 = DrawX - position_x_out6;
              platform_y6 = DrawY - position_y_out6;
            end
          else
            begin
              Draw_Platform6 =   1'b0; // Set default values for when the platform is not being displayed.
              platform_x6 =      5'b0;
              platform_y6 =      5'b0;
            end
           end
					 
					 
					 
					 
			// ~~ Doodle ~~
					 always_comb
					 begin:Printing_Doodle

						if(((DrawX >= DoodleX_right) && (DrawX < DoodleX_right + img_size) && (DrawY >= DoodleY_right) && (DrawY < DoodleY_right + img_size)))
						begin
							doodle_on_right = 1'b1;
							doodle_x_right = DrawX - DoodleX_right;
							doodle_y_right = DrawY - DoodleY_right;

						end

						else
						begin
						doodle_on_right = 1'b0;
						doodle_x_right = 5'h0;
						doodle_y_right = 5'h0;

						end

					 end

			// ~~ Pellet ~~

			// ~~ Escape (Selected)

					always_comb
					begin:Printing_escape_selected
						if((DrawX >= escape_sl_x_start) && (DrawX < escape_sl_x_start + 8'd175) && (DrawY >= escape_sl_y_start) && (DrawY < escape_sl_y_start + 7'd50))
							begin
								escape_sl_x = DrawX - escape_sl_x_start;
								escape_sl_y = DrawY - escape_sl_y_start;
								Draw_escape_sl = 1'b1;
							end
						else
							begin
								escape_sl_x = 8'd0;
								escape_sl_y = 8'd0;
								Draw_escape_sl = 1'b0;
							end
					end

			// ~~ Escape (Unselected)

				always_comb
					begin:Printing_escape_unselected
						if((DrawX >= escape_un_x_start) && (DrawX < escape_un_x_start + 8'd175) && (DrawY >= escape_un_y_start) && (DrawY < escape_un_y_start + 7'd50))
							begin
								escape_un_x = DrawX - escape_un_x_start;
								escape_un_y = DrawY - escape_un_y_start;
								Draw_escape_un = 1'b1;
							end
						else
							begin
								escape_un_x = 8'd0;
								escape_un_y = 8'd0;
								Draw_escape_un = 1'b0;
							end
					end

			// ~~ Settings (Selected)
				always_comb
					begin:Printing_settings_selected
						if((DrawX >= settings_sl_x_start) && (DrawX < settings_sl_x_start + 8'd175) && (DrawY >= settings_sl_y_start) && (DrawY < settings_sl_y_start + 7'd50))
							begin
								Draw_settings_sl = 1'b1;
								settings_sl_x = DrawX - settings_sl_x_start;
								settings_sl_y = DrawY - settings_sl_y_start;
							end
						else
							begin
								Draw_settings_sl = 1'b0;
								settings_sl_x = 8'd0;
								settings_sl_y = 8'd0;
							end
					end

			// ~~ Settings (Unselected)
				always_comb
					begin:Printing_settings_unselected
						if((DrawX >= settings_un_x_start) && (DrawX < settings_un_x_start + 8'd175) && (DrawY >= settings_un_y_start) && (DrawY < settings_un_y_start + 7'd50))
							begin
								Draw_settings_un = 1'b1;
								settings_un_x = DrawX - settings_un_x_start;
								settings_un_y = DrawY - settings_un_y_start;
							end
						else
							begin
								Draw_settings_un = 1'b0;
								settings_un_x = 8'd0;
								settings_un_y = 8'd0;
							end
					end

			// ~~ Font
				always_comb
					begin:Font
						if((DrawX >= Font_x_start) && (DrawX < Font_x_start + 8'd8) && (DrawY >= Font_y_start) && (DrawY < Font_y_start + 7'd16))
							begin
								Draw_font = 1'b1;
								Font_x = DrawX - Font_x_start;
								Font_y = DrawY - Font_y_start;
							end
						else
							begin
								Draw_font = 1'b0;
								Font_x = 8'd0;
								Font_y = 8'd0;
							end
					end

			// ~~ ECEB ~~
				always_comb
				begin:printing_ECEB
					if((DrawX >= ECEB_x_start) && (DrawX < ECEB_x_start + 10'd640) && (DrawY >= ECEB_y_start) && (DrawY < ECEB_y_start + 9'd273))
						begin
							Draw_ECEB = 1'b1;
							ECEB_address = (DrawX - ECEB_x_start) + ((DrawY - ECEB_y_start)*10'd640);
							//ECEB_y = DrawY - ECEB_y_start;
						end
					else
						begin
							Draw_ECEB = 1'b0;
							//ECEB_x = 10'd0;
							//ECEB_y = 9'd0;
							ECEB_address = 18'd0;
						end
				end

      // ~~ INPUT (Selected) ~~
      always_comb
      begin:printing_INPUT_selected
        if((DrawX >= input_x) && (DrawX < input_x + 10'd175) && (DrawY >= input_y) && (DrawY < input_y + 9'd50))
          begin
            Draw_INPUT_sl = 1'b1;
            INPUT_sl_address = (DrawX - input_x) + ((DrawY - input_y)*10'd175);
          end
        else
          begin
            Draw_INPUT_sl = 1'b0;
            INPUT_sl_address = 18'd0;
          end
      end

      // ~~ INPUT (Unselected) ~~
      always_comb
      begin:printing_INPUT_unselected
        if((DrawX >= input_x) && (DrawX < input_x + 10'd175) && (DrawY >= input_y) && (DrawY < input_y + 9'd50))
          begin
            Draw_INPUT_un = 1'b1;
            INPUT_un_address = (DrawX - input_x) + ((DrawY - input_y)*10'd175);
          end
        else
          begin
            Draw_INPUT_un = 1'b0;
            INPUT_un_address = 18'd0;
          end
      end

      // ~~ Color (Selected) ~~
      always_comb
      begin:printing_COLOR_selected
        if((DrawX >= color_x) && (DrawX < color_x + 10'd175) && (DrawY >= input_y) && (DrawY < input_y + 9'd50))
          begin
            Draw_COLOR_sl = 1'b1;
            COLOR_sl_address = (DrawX - color_x) + ((DrawY - input_y)*10'd175);
          end
        else
          begin
            Draw_COLOR_sl = 1'b0;
            COLOR_sl_address = 18'd0;
          end
      end

      // ~~ Color (Selected) ~~
      always_comb
      begin:printing_COLOR_unselected
        if((DrawX >= color_x) && (DrawX < color_x + 10'd175) && (DrawY >= input_y) && (DrawY < input_y + 9'd50))
          begin
            Draw_COLOR_un = 1'b1;
            COLOR_un_address = (DrawX - color_x) + ((DrawY - input_y)*10'd175);
          end
        else
          begin
            Draw_COLOR_un = 1'b0;
            COLOR_un_address = 18'd0;
          end
      end
		
		// ~~ Show Symbol ~~
		always_comb
		begin:for_input
			if((DrawX >= input_x + 10'd15) && (DrawX < input_x + 10'd160) && (DrawY >= input_y+10'd11) && (DrawY < input_y + 10'd39))
				Draw_Symbol_INPUT = 1'b1;
			else
				Draw_Symbol_INPUT = 1'b0;
		end
		
		always_comb
		begin:assigning_proper_value_to_be_outputted
			if(Settings_INPUT)
				Settings_INPUT_output = INPUT_keyboard_out;
			else
				Settings_INPUT_output = INPUT_accel_out;
		end
		
	// ******************************************** //
	//				   	MAP LOGIC 
	// ******************************************** //

				
	// ******************************************** //
	//				   Doodle Direction Logic
	// ******************************************** //

					 always_comb
					 begin
						if(doodle_direction[1])
							doodle_data = doodle_data_left;
						else if(doodle_direction[0])
							doodle_data = doodle_data_right;
						else
							begin
							doodle_data = doodle_data_left;
							end
					 end


// ===================================================================================================================================== //
//
//																				Printing to Screen
//
// ===================================================================================================================================== //

	// ******************************************** //
	//				   Color Dictionary
	// ******************************************** //

			// Yellow
			parameter YELLOW_R = 8'hE7;
			parameter YELLOW_G = 8'hDF;
			parameter YELLOW_B = 8'h31;

			// Green
			parameter GREEN_R = 8'h55;
			parameter GREEN_G = 8'h8F;
			parameter GREEN_B = 8'h40;

			// Black
			parameter BLACK = 8'h00;

			// White
			parameter WHITE = 8'hFF;

			// Peach
			parameter PEACH_R = 8'hF9;
			parameter PEACH_G = 8'hC5;
			parameter PEACH_B = 8'hAF;

			// Offwhite
			parameter OFFWHITE_R = 8'hF7;
			parameter OFFWHITE_G = 8'hF3;
			parameter OFFWHITE_B = 8'hF1;

			// Orange
			parameter ORANGE_R = 8'hF4;
			parameter ORANGE_G = 8'h63;
			parameter ORANGE_B = 8'h0A;

			// Maroon
			parameter MAROON_R = 8'hAE;
			parameter MAROON_G = 8'h02;
			parameter MAROON_B = 8'h00;

			// Gray
			parameter GRAY_R = 8'h2A;
			parameter GRAY_G = 8'h32;
			parameter GRAY_B = 8'h3F;

			// Blue (Background for ECEB photo)
			parameter BLUE_R = 8'h06;
			parameter BLUE_G = 8'h02;
			parameter BLUE_B = 8'hFF;

			// Dark Orange/Maroon
			parameter ORANGE_MAROON_R = 8'h81;
			parameter ORANGE_MAROON_G = 8'h47;
			parameter ORANGE_MAROON_B = 8'h3B;

			// Dark Brown
			parameter DARKBROWN_R = 8'h52;
			parameter DARKBROWN_G = 8'h22;
			parameter DARKBROWN_B = 8'h22;

			// Blue Gray
			parameter BLUE_GRAY_R = 8'h6D;
			parameter BLUE_GRAY_G = 8'h7F;
			parameter BLUE_GRAY_B = 8'h81;

			// Dark Green
			parameter DARK_GREEN_R = 8'h47;
			parameter DARK_GREEN_G = 8'h4D;
			parameter DARK_GREEN_B = 8'h31;

			// Light Gray
			parameter LIGHT_GRAY_R = 8'h7A;
			parameter LIGHT_GRAY_G = 8'h8C;
			parameter LIGHT_GRAY_B = 8'hA2;

			// Shark
			parameter SHARK_R = 8'h33;
			parameter SHARK_G = 8'h48;
			parameter SHARK_B = 8'h4B;

			// Accorn
			parameter ACCORN_R = 8'h67;
			parameter ACCORN_G = 8'h4D;
			parameter ACCORN_B = 8'h50;

			// Urine
			parameter URINE_R = 8'hCE;
			parameter URINE_G = 8'h9C;
			parameter URINE_B = 8'h5F;



	// ******************************************** //
	//				   Printing Logic
	// ******************************************** //


			 always_comb
						 begin:RGB_Display
				case(debugging_mode)
					1'b0:
					begin
						case(graphics_control)
						3'b000: // Welcome Screen (escape)
						begin
							if(Draw_escape_sl)
								begin
								case(escape_sl_out)
									3'h0:
									begin
										Red = 	ORANGE_R;
										Green = 	ORANGE_G;
										Blue = 	ORANGE_B;
									end

									3'h1:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end

									3'h2:
									begin
										Red = 	BLACK;
										Green = 	BLACK;
										Blue =	BLACK;
									end

									default:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end
								endcase
								end
							else if(Draw_settings_un)
							begin
								case(settings_un_out)
									3'h0:
									begin
										Red = 	ORANGE_R;
										Green = 	ORANGE_G;
										Blue = 	ORANGE_B;
									end

									3'h1:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end

									3'h2:
									begin
										Red = 	BLACK;
										Green = 	BLACK;
										Blue =	BLACK;
									end

									default:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end
								endcase
								end
								//marker
								else if(doodle_on_right)
								begin
								case(doodle_data)
												3'h0:
													begin
													if(Draw_Platform)
													begin
														case(platform_out0)

															3'h0: // red background
															begin


															case(bg_data)

																3'h0: // Unused
																begin
																	Red = 	8'hF7; // color_array_red[signal] , 0th == red, 1st == purple
																	Green = 	8'hF3;
																	Blue = 	8'hF1;
																end

																3'h1: // White
																begin
																	Red = 	WHITE;
																	Green = 	WHITE;
																	Blue = 	WHITE;
																end

																3'h2: // Peach
																begin
																	Red = 	PEACH_R;
																	Green = 	PEACH_G;
																	Blue = 	PEACH_B;
																end

																default: // Offwhite
																begin
																Red = 	OFFWHITE_R;
																Green = 	OFFWHITE_G;
																Blue = 	OFFWHITE_B;
																end

													endcase
												end


										3'h1:
										begin
											Red = 	GREEN_R;
											Green = 	GREEN_G;
											Blue = 	GREEN_B;
										end

										3'h2:
										begin
											Red = 	WHITE;
											Green =  WHITE;
											Blue = 	WHITE;
										end

										3'h3:
										begin
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase
															end
															else
																case(bg_data)

																	3'h0: // Unused
																	begin
																		Red = 	8'hF7;
																		Green = 	8'hF3;
																		Blue = 	8'hF1;
																	end

																	3'h1: // White
																	begin
																		Red = 	WHITE;
																		Green = 	WHITE;
																		Blue = 	WHITE;
																	end

																	3'h2: // Peach
																	begin
																		Red = 	PEACH_R;
																		Green = 	PEACH_G;
																		Blue = 	PEACH_B;
																	end

																	default: // Offwhite
																	begin
																	Red = 	OFFWHITE_R;
																	Green = 	OFFWHITE_G;
																	Blue = 	OFFWHITE_B;
																	end

															endcase
														end


													3'h1: // Yellow
													begin
													Red = 	YELLOW_R; //color_red[color];
													Green = 	YELLOW_G; //color_green[color];
													Blue = 	YELLOW_B; //color_blue[color];
													end


													3'h2: // Green
													begin
													Red = 	GREEN_R;
													Green = 	GREEN_G;
													Blue = 	GREEN_B;
													end


													3'h3: // Black
													begin
													Red = 	BLACK;
													Green = 	BLACK;
													Blue = 	BLACK;
													end

													default:
													begin
													Red = 	BLACK;
													Green = 	BLACK;
													Blue = 	WHITE;
													end

												endcase
												end
							// marker
							else
								begin
									case(welcome_screen_out)
										3'h0:
										begin
												case(bg_data)

													3'h0: // Unused
													begin
														Red = 	8'hF7;
														Green = 	8'hF3;
														Blue = 	8'hF1;
													end

													3'h1: // White
													begin
														Red = 	WHITE;
														Green = 	WHITE;
														Blue = 	WHITE;
													end

													3'h2: // Peach
													begin
														Red = 	PEACH_R;
														Green = 	PEACH_G;
														Blue = 	PEACH_B;
													end

													default: // Offwhite
													begin
													Red = 	OFFWHITE_R;
													Green = 	OFFWHITE_G;
													Blue = 	OFFWHITE_B;
													end

											endcase

										end

										3'h1: // Orange
										begin
											Red = 	ORANGE_R;
											Green = 	ORANGE_G;
											Blue = 	ORANGE_B;
										end

										3'h2: // Maroon
										begin
											Red = 	MAROON_R;
											Green = 	MAROON_G;
											Blue =	MAROON_B;
										end

										3'h3: // White
										begin
											Red = 	WHITE;
											Green =	WHITE;
											Blue = 	WHITE;
										end

										3'h4: // Gray
										begin
											Red = 	GRAY_R;
											Green =	GRAY_G;
											Blue =	GRAY_B;
										end

										default:
										begin
											Red = 	WHITE;
											Green =	WHITE;
											Blue = 	WHITE;
										end
									endcase
								end
						end

						3'b001: // Welcome Screen (settings)
						begin
							if(Draw_settings_sl)
								begin
								case(settings_sl_out)
									3'h0:
									begin
										Red = 	ORANGE_R;
										Green = 	ORANGE_G;
										Blue = 	ORANGE_B;
									end

									3'h1:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end

									3'h2:
									begin
										Red = 	BLACK;
										Green = 	BLACK;
										Blue =	BLACK;
									end

									default:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end
								endcase
								end
							else if(Draw_escape_un)
							begin
								case(escape_un_out)
									3'h0:
									begin
										Red = 	ORANGE_R;
										Green = 	ORANGE_G;
										Blue = 	ORANGE_B;
									end

									3'h1:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end

									3'h2:
									begin
										Red = 	BLACK;
										Green = 	BLACK;
										Blue =	BLACK;
									end

									default:
									begin
										Red = 	WHITE;
										Green = 	WHITE;
										Blue = 	WHITE;
									end
								endcase
								end
							else
								begin
									case(welcome_screen_out)
										3'h0:
										begin
												case(bg_data)

													3'h0: // Unused
													begin
														Red = 	8'hF7;
														Green = 	8'hF3;
														Blue = 	8'hF1;
													end

													3'h1: // White
													begin
														Red = 	WHITE;
														Green = 	WHITE;
														Blue = 	WHITE;
													end

													3'h2: // Peach
													begin
														Red = 	PEACH_R;
														Green = 	PEACH_G;
														Blue = 	PEACH_B;
													end

													default: // Offwhite
													begin
													Red = 	OFFWHITE_R;
													Green = 	OFFWHITE_G;
													Blue = 	OFFWHITE_B;
													end

											endcase

										end

										3'h1: // Orange
										begin
											Red = 	ORANGE_R;
											Green = 	ORANGE_G;
											Blue = 	ORANGE_B;
										end

										3'h2: // Maroon
										begin
											Red = 	MAROON_R;
											Green = 	MAROON_G;
											Blue =	MAROON_B;
										end

										3'h3: // White
										begin
											Red = 	WHITE;
											Green =	WHITE;
											Blue = 	WHITE;
										end

										3'h4: // Gray
										begin
											Red = 	GRAY_R;
											Green =	GRAY_G;
											Blue =	GRAY_B;
										end

										default:
										begin
											Red = 	WHITE;
											Green =	WHITE;
											Blue = 	WHITE;
										end
									endcase
								end
						end

						3'b010: // Game Screen
						begin
if(doodle_on_right == 1'b1 || graphics_control == 3'b000 || graphics_control == 3'b001) // If doodle is on
							begin //{
							case(doodle_data) //{
												3'h0: 
												// START
													begin //{ 
													if(Draw_Platform) 
														begin //{
															if(Draw_Platform0) 
																begin //{
																	case(platform_out0) //{ // Start of Platform 1

																		3'h0:  // red background 
																			begin //{
																			case(bg_data) //{

																				3'h0: // Unused
																				begin
																					Red = 	8'hF7;
																					Green = 	8'hF3;
																					Blue = 	8'hF1;
																				end

																				3'h1: // White
																				begin
																					Red = 	WHITE;
																					Green = 	WHITE;
																					Blue = 	WHITE;
																				end

																				3'h2: // Peach
																				begin
																					Red = 	PEACH_R;
																					Green = 	PEACH_G;
																					Blue = 	PEACH_B;
																				end

																				default: // Offwhite
																				begin
																				Red = 	OFFWHITE_R;
																				Green = 	OFFWHITE_G;
																				Blue = 	OFFWHITE_B;
																				end
																				

																		endcase //}
																		end //}


																	3'h1:
																	begin 
																		Red = 	GREEN_R;
																		Green = 	GREEN_G;
																		Blue = 	GREEN_B;
																	end

																	3'h2:
																	begin
																		Red = 	WHITE;
																		Green =  WHITE;
																		Blue = 	WHITE;
																	end

																	3'h3:
																	begin
																		Red = 	BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end

																	default:
																	begin
																		Red =		BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end
																endcase //}
															end// }
															
															if(Draw_Platform3) 
																begin //{
																	case(platform_out3) //{ // Start of Platform 1

																		3'h0:  // red background 
																			begin //{
																			case(bg_data) //{

																				3'h0: // Unused
																				begin
																					Red = 	8'hF7;
																					Green = 	8'hF3;
																					Blue = 	8'hF1;
																				end

																				3'h1: // White
																				begin
																					Red = 	WHITE;
																					Green = 	WHITE;
																					Blue = 	WHITE;
																				end

																				3'h2: // Peach
																				begin
																					Red = 	PEACH_R;
																					Green = 	PEACH_G;
																					Blue = 	PEACH_B;
																				end

																				default: // Offwhite
																				begin
																				Red = 	OFFWHITE_R;
																				Green = 	OFFWHITE_G;
																				Blue = 	OFFWHITE_B;
																				end
																				

																		endcase //}
																		end //}


																	3'h1:
																	begin 
																		Red = 	GREEN_R;
																		Green = 	GREEN_G;
																		Blue = 	GREEN_B;
																	end

																	3'h2:
																	begin
																		Red = 	WHITE;
																		Green =  WHITE;
																		Blue = 	WHITE;
																	end

																	3'h3:
																	begin
																		Red = 	BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end

																	default:
																	begin
																		Red =		BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end
																endcase //}
															end// }
															
															else if(Draw_Platform1)
															begin //{
																	case(platform_out1) //{ // Start of Platform 1

																		3'h0:  // red background 
																			begin //{
																			case(bg_data) //{

																				3'h0: // Unused
																				begin
																					Red = 	8'hF7;
																					Green = 	8'hF3;
																					Blue = 	8'hF1;
																				end

																				3'h1: // White
																				begin
																					Red = 	WHITE;
																					Green = 	WHITE;
																					Blue = 	WHITE;
																				end

																				3'h2: // Peach
																				begin
																					Red = 	PEACH_R;
																					Green = 	PEACH_G;
																					Blue = 	PEACH_B;
																				end

																				default: // Offwhite
																				begin
																				Red = 	OFFWHITE_R;
																				Green = 	OFFWHITE_G;
																				Blue = 	OFFWHITE_B;
																				end
																				

																		endcase //}
																		end //}


																	3'h1:
																	begin 
																		Red = 	GREEN_R;
																		Green = 	GREEN_G;
																		Blue = 	GREEN_B;
																	end

																	3'h2:
																	begin
																		Red = 	WHITE;
																		Green =  WHITE;
																		Blue = 	WHITE;
																	end

																	3'h3:
																	begin
																		Red = 	BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end

																	default:
																	begin
																		Red =		BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end
																endcase //}
															end// }
															else if(Draw_Platform2)
															begin //{
																	case(platform_out2) //{ // Start of Platform 1

																		3'h0:  // red background 
																			begin //{
																			case(bg_data) //{

																				3'h0: // Unused
																				begin
																					Red = 	8'hF7;
																					Green = 	8'hF3;
																					Blue = 	8'hF1;
																				end

																				3'h1: // White
																				begin
																					Red = 	WHITE;
																					Green = 	WHITE;
																					Blue = 	WHITE;
																				end

																				3'h2: // Peach
																				begin
																					Red = 	PEACH_R;
																					Green = 	PEACH_G;
																					Blue = 	PEACH_B;
																				end

																				default: // Offwhite
																				begin
																				Red = 	OFFWHITE_R;
																				Green = 	OFFWHITE_G;
																				Blue = 	OFFWHITE_B;
																				end
																				

																		endcase //}
																		end //}


																	3'h1:
																	begin 
																		Red = 	GREEN_R;
																		Green = 	GREEN_G;
																		Blue = 	GREEN_B;
																	end

																	3'h2:
																	begin
																		Red = 	WHITE;
																		Green =  WHITE;
																		Blue = 	WHITE;
																	end

																	3'h3:
																	begin
																		Red = 	BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end

																	default:
																	begin
																		Red =		BLACK;
																		Green = 	BLACK;
																		Blue = 	BLACK;
																	end
																endcase //}
															end// }
										
								 // End of platform 1
									
													else //{
														begin
                            case(bg_data) //{

                              3'h0: // Unused
                              begin
                                Red = 	8'hF7;
                                Green = 	8'hF3;
                                Blue = 	8'hF1;
                              end

                              3'h1: // White
                              begin
                                Red = 	WHITE;
                                Green = 	WHITE;
                                Blue = 	WHITE;
                              end

                              3'h2: // Peach
                              begin
                                Red = 	PEACH_R;
                                Green = 	PEACH_G;
                                Blue = 	PEACH_B;
                              end

                              default: // Offwhite
                              begin
                              Red = 	OFFWHITE_R;
                              Green = 	OFFWHITE_G;
                              Blue = 	OFFWHITE_B;
                              end
                              

                          endcase //}
														end //}
											end //}
                        else 
                          begin
                            case(bg_data) //{

																				3'h0: // Unused
																				begin
																					Red = 	8'hF7;
																					Green = 	8'hF3;
																					Blue = 	8'hF1;
																				end

																				3'h1: // White
																				begin
																					Red = 	WHITE;
																					Green = 	WHITE;
																					Blue = 	WHITE;
																				end

																				3'h2: // Peach
																				begin
																					Red = 	PEACH_R;
																					Green = 	PEACH_G;
																					Blue = 	PEACH_B;
																				end

																				default: // Offwhite
																				begin
																				Red = 	OFFWHITE_R;
																				Green = 	OFFWHITE_G;
																				Blue = 	OFFWHITE_B;
																				end
																				

																		endcase //}
                          end
											end

										3'h1:
										begin
											Red = 	YELLOW_R;
											Green = 	YELLOW_G;
											Blue = 	YELLOW_B;
										end

										3'h2:
										begin
											Red = 	GREEN_R;
											Green =  GREEN_G;
											Blue = 	GREEN_B;
										end


										3'h3:
										begin 
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
												
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase// }
															end //}
															
								// fix up to here 
								else if(Draw_Platform) 
									begin
										if(Draw_Platform0)
											begin
												case(platform_out0) // Start of Platform 1

													3'h0: // red background
														begin


																case(bg_data)

																	3'h0: // Unused
																	begin
																		Red = 	8'hF7;
																		Green = 	8'hF3;
																		Blue = 	8'hF1;
																	end

																	3'h1: // White
																	begin
																		Red = 	WHITE;
																		Green = 	WHITE;
																		Blue = 	WHITE;
																	end

																	3'h2: // Peach
																	begin
																		Red = 	PEACH_R;
																		Green = 	PEACH_G;
																		Blue = 	PEACH_B;
																	end

																	default: // Offwhite
																	begin
																	Red = 	OFFWHITE_R;
																	Green = 	OFFWHITE_G;
																	Blue = 	OFFWHITE_B;
																	end

															endcase
														end


										3'h1:
										begin
											Red = 	GREEN_R;
											Green = 	GREEN_G;
											Blue = 	GREEN_B;
										end

										3'h2:
										begin
											Red = 	WHITE;
											Green =  WHITE;
											Blue = 	WHITE;
										end

										3'h3:
										begin
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase
											end
										
								 // End of platform 1
									else if(Draw_Platform1)
										begin
											case(platform_out1) // Start of Platform 1

												3'h0: // red background
													begin


																case(bg_data)

																	3'h0: // Unused
																	begin
																		Red = 	8'hF7;
																		Green = 	8'hF3;
																		Blue = 	8'hF1;
																	end

																	3'h1: // White
																	begin
																		Red = 	WHITE;
																		Green = 	WHITE;
																		Blue = 	WHITE;
																	end

																	3'h2: // Peach
																	begin
																		Red = 	PEACH_R;
																		Green = 	PEACH_G;
																		Blue = 	PEACH_B;
																	end

																	default: // Offwhite
																	begin
																	Red = 	OFFWHITE_R;
																	Green = 	OFFWHITE_G;
																	Blue = 	OFFWHITE_B;
																	end

															endcase
														end


										3'h1:
										begin
											Red = 	GREEN_R;
											Green = 	GREEN_G;
											Blue = 	GREEN_B;
										end

										3'h2:
										begin
											Red = 	WHITE;
											Green =  WHITE;
											Blue = 	WHITE;
										end

										3'h3:
										begin
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase
										end
									else if(Draw_Platform2)
										begin
											case(platform_out2) // Start of Platform 1

										3'h0: // red background
										begin


																case(bg_data)

																	3'h0: // Unused
																	begin
																		Red = 	8'hF7;
																		Green = 	8'hF3;
																		Blue = 	8'hF1;
																	end

																	3'h1: // White
																	begin
																		Red = 	WHITE;
																		Green = 	WHITE;
																		Blue = 	WHITE;
																	end

																	3'h2: // Peach
																	begin
																		Red = 	PEACH_R;
																		Green = 	PEACH_G;
																		Blue = 	PEACH_B;
																	end

																	default: // Offwhite
																	begin
																	Red = 	OFFWHITE_R;
																	Green = 	OFFWHITE_G;
																	Blue = 	OFFWHITE_B;
																	end

															endcase
														end


										3'h1:
										begin
											Red = 	GREEN_R;
											Green = 	GREEN_G;
											Blue = 	GREEN_B;
										end

										3'h2:
										begin
											Red = 	WHITE;
											Green =  WHITE;
											Blue = 	WHITE;
										end

										3'h3:
										begin
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase
										end
								else if(Draw_Platform3)
									begin
										case(platform_out3) // Start of Platform 1

										3'h0: // red background
										begin


																case(bg_data)

																	3'h0: // Unused
																	begin
																		Red = 	8'hF7;
																		Green = 	8'hF3;
																		Blue = 	8'hF1;
																	end

																	3'h1: // White
																	begin
																		Red = 	WHITE;
																		Green = 	WHITE;
																		Blue = 	WHITE;
																	end

																	3'h2: // Peach
																	begin
																		Red = 	PEACH_R;
																		Green = 	PEACH_G;
																		Blue = 	PEACH_B;
																	end

																	default: // Offwhite
																	begin
																	Red = 	OFFWHITE_R;
																	Green = 	OFFWHITE_G;
																	Blue = 	OFFWHITE_B;
																	end

															endcase
														end


										3'h1:
										begin
											Red = 	GREEN_R;
											Green = 	GREEN_G;
											Blue = 	GREEN_B;
										end

										3'h2:
										begin
											Red = 	WHITE;
											Green =  WHITE;
											Blue = 	WHITE;
										end

										3'h3:
										begin
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase
									end
									else if(Draw_Platform4)
										begin
											case(platform_out4) // Start of Platform 1

										3'h0: // red background
										begin


																case(bg_data)

																	3'h0: // Unused
																	begin
																		Red = 	8'hF7;
																		Green = 	8'hF3;
																		Blue = 	8'hF1;
																	end

																	3'h1: // White
																	begin
																		Red = 	WHITE;
																		Green = 	WHITE;
																		Blue = 	WHITE;
																	end

																	3'h2: // Peach
																	begin
																		Red = 	PEACH_R;
																		Green = 	PEACH_G;
																		Blue = 	PEACH_B;
																	end

																	default: // Offwhite
																	begin
																	Red = 	OFFWHITE_R;
																	Green = 	OFFWHITE_G;
																	Blue = 	OFFWHITE_B;
																	end

															endcase
														end


										3'h1:
										begin
											Red = 	GREEN_R;
											Green = 	GREEN_G;
											Blue = 	GREEN_B;
										end

										3'h2:
										begin
											Red = 	WHITE;
											Green =  WHITE;
											Blue = 	WHITE;
										end

										3'h3:
										begin
											Red = 	BLACK;
											Green = 	BLACK;
											Blue = 	BLACK;
										end

										default:
										begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
										end
									endcase
										end

                    else if(Draw_Platform5)
    									begin
    										case(platform_out5) // Start of Platform 1
    
    										3'h0: // red background
    										begin
    
    
    																case(bg_data)
    
    																	3'h0: // Unused
    																	begin
    																		Red = 	8'hF7;
    																		Green = 	8'hF3;
    																		Blue = 	8'hF1;
    																	end
    
    																	3'h1: // White
    																	begin
    																		Red = 	WHITE;
    																		Green = 	WHITE;
    																		Blue = 	WHITE;
    																	end
    
    																	3'h2: // Peach
    																	begin
    																		Red = 	PEACH_R;
    																		Green = 	PEACH_G;
    																		Blue = 	PEACH_B;
    																	end
    
    																	default: // Offwhite
    																	begin
    																	Red = 	OFFWHITE_R;
    																	Green = 	OFFWHITE_G;
    																	Blue = 	OFFWHITE_B;
    																	end
    
    															endcase
    														end
    
    
    										3'h1:
    										begin
    											Red = 	GREEN_R;
    											Green = 	GREEN_G;
    											Blue = 	GREEN_B;
    										end
    
    										3'h2:
    										begin
    											Red = 	WHITE;
    											Green =  WHITE;
    											Blue = 	WHITE;
    										end
    
    										3'h3:
    										begin
    											Red = 	BLACK;
    											Green = 	BLACK;
    											Blue = 	BLACK;
    										end
    
    										default:
    										begin
    											Red =		WHITE;
    											Green = 	WHITE;
    											Blue = 	WHITE;
    										end
    									endcase
    									end

                      else if(Draw_Platform6)
      									begin
      										case(platform_out6) // Start of Platform 1
      
      										3'h0: // red background
      										begin
      
      
      																case(bg_data)
      
      																	3'h0: // Unused
      																	begin
      																		Red = 	8'hF7;
      																		Green = 	8'hF3;
      																		Blue = 	8'hF1;
      																	end
      
      																	3'h1: // White
      																	begin
      																		Red = 	WHITE;
      																		Green = 	WHITE;
      																		Blue = 	WHITE;
      																	end
      
      																	3'h2: // Peach
      																	begin
      																		Red = 	PEACH_R;
      																		Green = 	PEACH_G;
      																		Blue = 	PEACH_B;
      																	end
      
      																	default: // Offwhite
      																	begin
      																	Red = 	OFFWHITE_R;
      																	Green = 	OFFWHITE_G;
      																	Blue = 	OFFWHITE_B;
      																	end
      
      															endcase
      														end
      
      
      										3'h1:
      										begin
      											Red = 	GREEN_R;
      											Green = 	GREEN_G;
      											Blue = 	GREEN_B;
      										end
      
      										3'h2:
      										begin
      											Red = 	WHITE;
      											Green =  WHITE;
      											Blue = 	WHITE;
      										end
      
      										3'h3:
      										begin
      											Red = 	BLACK;
      											Green = 	BLACK;
      											Blue = 	BLACK;
      										end
      
      										default:
      										begin
      											Red =		WHITE;
      											Green = 	WHITE;
      											Blue = 	WHITE;
      										end
      									endcase
      									end



                    // ULTIMATE ELSE 
										else
											begin
											Red =		WHITE;
											Green = 	WHITE;
											Blue = 	WHITE;
											end
											
											end
											else
												begin:print_background
										//		Red = 8'h00;
										//		Green = 8'h00;
										//		Blue = 8'h00;
														case(bg_data)

															3'h0: // Unused
															begin
																Red = 	8'hFF;
																Green = 	8'hF3;
																Blue = 	8'hF1;
															end

															3'h1: // White
															begin
																Red = 	WHITE;
																Green = 	WHITE;
																Blue = 	WHITE;
															end

															3'h2: // Peach
															begin
																Red = 	PEACH_R;
																Green = 	PEACH_G;
																Blue = 	PEACH_B;
															end

															default:
															begin
															Red = 	8'hF7;
															Green = 	8'hF3;
															Blue = 	8'hF1;
															end
													 endcase
												end
							end
						3'b011: // Death Screen
						begin
							Red = WHITE;
							Green = BLACK;
							Blue = BLACK;
						end

						3'b100: // Settings_INPUT
						begin
						if(Draw_ECEB)
							begin
								case(ECEB_out)
									4'h0: // background
									begin
										case(bg_data)
													3'h0: // Unused
													begin
														Red = 	8'hF7;
														Green = 	8'hF3;
														Blue = 	8'hF1;
													end

													3'h1: // White
													begin
														Red = 	WHITE;
														Green = 	WHITE;
														Blue = 	WHITE;
													end

													3'h2: // Peach
													begin
														Red = 	PEACH_R;
														Green = 	PEACH_G;
														Blue = 	PEACH_B;
													end

													default: // Offwhite
													begin
													Red = 	OFFWHITE_R;
													Green = 	OFFWHITE_G;
													Blue = 	OFFWHITE_B;
													end
											endcase
										end
									4'h1:
									begin
										Red = 	ORANGE_MAROON_R;
										Green =	ORANGE_MAROON_G;
										Blue = 	ORANGE_MAROON_B;

									end

									4'h2:
									begin
										Red =		DARKBROWN_R;
										Green = 	DARKBROWN_G;
										Blue = 	DARKBROWN_B;
									end

									4'h3:
									begin
										Red =		BLUE_GRAY_R;
										Green =	BLUE_GRAY_G;
										Blue =	BLUE_GRAY_B;
									end

									4'h4:
									begin
										Red =		DARK_GREEN_R;
										Green =	DARK_GREEN_G;
										Blue =	DARK_GREEN_B;
									end

									4'h5:
									begin
										Red =		LIGHT_GRAY_R;
										Green =	LIGHT_GRAY_G;
										Blue = 	LIGHT_GRAY_B;
									end

									4'h6:
									begin
										Red = 	SHARK_R;
										Green =	SHARK_G;
										Blue =	SHARK_B;
									end

									4'h7:
									begin
										Red =		ACCORN_R;
										Green = 	ACCORN_G;
										Blue =	ACCORN_B;
									end

									4'h8:
									begin
										Red =		URINE_R;
										Green =	URINE_G;
										Blue =	URINE_B;
									end

									default:
									begin
										Red = 	WHITE;
										Green =	WHITE;
										Blue = 	WHITE;
									end
								endcase
							end
						else if(Draw_INPUT_sl)
              begin
                case(input_selected_out)
                  2'h0:
                    begin
                      Red =     ORANGE_R;
                      Blue =    ORANGE_B;
                      Green =   ORANGE_G;
                    end
                  2'h1:
                    begin
                      Red =     BLACK;
                      Green =   BLACK;
                      Blue =    BLACK;
                    end
                  2'h2:
                    begin
                      Red =     WHITE;
                      Green =   WHITE;
                      Blue =    WHITE;
                    end

                  default:
                    begin
                      Red =     BLACK;
                      Green =   BLACK;
                      Blue =    BLACK;
                    end
						 endcase
              end
            else if(Draw_COLOR_un)
              begin
              case(color_unselected_out)
                2'h0:
                  begin
                    Red =     ORANGE_R;
                    Blue =    ORANGE_B;
                    Green =   ORANGE_G;
                  end
                2'h1:
                  begin
                    Red =     BLACK;
                    Green =   BLACK;
                    Blue =    BLACK;
                  end
                2'h2:
                  begin
                    Red =     WHITE;
                    Green =   WHITE;
                    Blue =    WHITE;
                  end

                default:
                  begin
                    Red =     WHITE;
                    Green =   WHITE;
                    Blue =    WHITE;
                  end
                endcase
              end
            else // Draw Background
						begin
							case(bg_data)

															3'h0: // Unused
															begin
																Red = 	8'hFF;
																Green = 	8'hF3;
																Blue = 	8'hF1;
															end

															3'h1: // White
															begin
																Red = 	WHITE;
																Green = 	WHITE;
																Blue = 	WHITE;
															end

															3'h2: // Peach
															begin
																Red = 	PEACH_R;
																Green = 	PEACH_G;
																Blue = 	PEACH_B;
															end

															default:
															begin
															Red = 	8'hF7;
															Green = 	8'hF3;
															Blue = 	8'hF1;
															end
													 endcase
							end
					end
          3'b101: // Settings (COLOR )
            begin
              if(Draw_COLOR_sl)
                begin
						if(Draw_Symbol_INPUT)
							begin
								case(Settings_INPUT_output)
									 2'h0:
									  begin
										 Red =     ORANGE_R;
										 Blue =    ORANGE_B;
										 Green =   ORANGE_G;
									  end
									2'h1:
									  begin
										 Red =     BLACK;
										 Green =   BLACK;
										 Blue =    BLACK;
									  end
									2'h2:
									  begin
										 Red =     WHITE;
										 Green =   WHITE;
										 Blue =    WHITE;
									  end

									default:
									  begin
										 Red =     BLACK;
										 Green =   BLACK;
										 Blue =    BLACK;
									  end
									endcase
							end
						else
							begin
                  case(color_selected_out)
                    3'h0:
                    begin
                      Red = 8'hFF;
                      Green = 8'h00;
                      Blue = 8'hB1;
                    end

                    3'h1:
                    begin
                      Red = 8'hFF;
                      Green = 8'hFF;
                      Blue = 8'hFF;

                    end

                    3'h2:
                    begin
                      Red = 8'h00;
                      Green = 8'h00;
                      Blue = 8'h00;
                    end

                    3'h3:
                    begin
                      Red = 8'h04;
                      Green = 8'h00;
                      Blue = 8'hFF;
                    end

                    3'h4:
                    begin
                      Red = 8'h00;
                      Green = 8'hFE;
                      Blue = 8'hFF;
                    end

                    3'h5:
                    begin
                      Red = 8'h00;
                      Green = 8'hFF;
                      Blue = 8'h25;
                    end

                    3'h6:
                    begin
                      Red = 8'hFF;
                      Green = 8'hEC;
                      Blue = 8'h00;
                    end

                    default:
                    begin
                      Red = WHITE;
                      Green = WHITE;
                      Blue = WHITE;
                    end
                  endcase
                end
					 end
              else if(Draw_INPUT_un)
              begin
              case(input_unselected_out)
              2'h0:
                begin
                  Red =     ORANGE_R;
                  Blue =    ORANGE_B;
                  Green =   ORANGE_G;
                end
              2'h1:
                begin
                  Red =     BLACK;
                  Green =   BLACK;
                  Blue =    BLACK;
                end
              2'h2:
                begin
                  Red =     WHITE;
                  Green =   WHITE;
                  Blue =    WHITE;
                end

              default:
                begin
                  Red =     WHITE;
                  Green =   WHITE;
                  Blue =    WHITE;
                end
              endcase

              end
              else if(Draw_ECEB)
  							begin
  								case(ECEB_out)
  									4'h0: // background
  									begin
  										case(bg_data)
  													3'h0: // Unused
  													begin
  														Red = 	8'hF7;
  														Green = 	8'hF3;
  														Blue = 	8'hF1;
  													end

  													3'h1: // White
  													begin
  														Red = 	WHITE;
  														Green = 	WHITE;
  														Blue = 	WHITE;
  													end

  													3'h2: // Peach
  													begin
  														Red = 	PEACH_R;
  														Green = 	PEACH_G;
  														Blue = 	PEACH_B;
  													end

  													default: // Offwhite
  													begin
  													Red = 	OFFWHITE_R;
  													Green = 	OFFWHITE_G;
  													Blue = 	OFFWHITE_B;
  													end
  											endcase
  										end
  									4'h1:
  									begin
  										Red = 	ORANGE_MAROON_R;
  										Green =	ORANGE_MAROON_G;
  										Blue = 	ORANGE_MAROON_B;

  									end

  									4'h2:
  									begin
  										Red =		DARKBROWN_R;
  										Green = 	DARKBROWN_G;
  										Blue = 	DARKBROWN_B;
  									end

  									4'h3:
  									begin
  										Red =		BLUE_GRAY_R;
  										Green =	BLUE_GRAY_G;
  										Blue =	BLUE_GRAY_B;
  									end

  									4'h4:
  									begin
  										Red =		DARK_GREEN_R;
  										Green =	DARK_GREEN_G;
  										Blue =	DARK_GREEN_B;
  									end

  									4'h5:
  									begin
  										Red =		LIGHT_GRAY_R;
  										Green =	LIGHT_GRAY_G;
  										Blue = 	LIGHT_GRAY_B;
  									end

  									4'h6:
  									begin
  										Red = 	SHARK_R;
  										Green =	SHARK_G;
  										Blue =	SHARK_B;
  									end

  									4'h7:
  									begin
  										Red =		ACCORN_R;
  										Green = 	ACCORN_G;
  										Blue =	ACCORN_B;
  									end

  									4'h8:
  									begin
  										Red =		URINE_R;
  										Green =	URINE_G;
  										Blue =	URINE_B;
  									end

  									default:
  									begin
  										Red = 	WHITE;
  										Green =	WHITE;
  										Blue = 	WHITE;
  									end
  								endcase
  							end
              else
              begin
                case(bg_data)
                      3'h0: // Unused
                      begin
                        Red = 	8'hF7;
                        Green = 	8'hF3;
                        Blue = 	8'hF1;
                      end

                      3'h1: // White
                      begin
                        Red = 	WHITE;
                        Green = 	WHITE;
                        Blue = 	WHITE;
                      end

                      3'h2: // Peach
                      begin
                        Red = 	PEACH_R;
                        Green = 	PEACH_G;
                        Blue = 	PEACH_B;
                      end

                      default: // Offwhite
                      begin
                      Red = 	OFFWHITE_R;
                      Green = 	OFFWHITE_G;
                      Blue = 	OFFWHITE_B;
                      end
                  endcase
                end
						end

							default:
							begin
								Red = 	GREEN_R;
								Green = 	GREEN_G;
								Blue = 	GREEN_B;
							end
							endcase
					end

					1'b1: // change else statement whenever normal printing routine changes
					begin
						if(DrawY >= 10'd4 && DrawY <= 10'd20)
						begin
							if(DrawX >= 5'd25 && DrawX <= 6'd33)
								begin
									case(font_data % (DrawX-5'd25))
										1'b0:
											begin
												Red = 	BLACK;
												Blue = 	BLACK;
												Green =	BLACK;
											end

										1'b1:
											begin
												Red = 	WHITE;
												Blue =	WHITE;
												Green = 	WHITE;
											end

										default:
											begin
												Red = 	BLACK;
												Blue = 	BLACK;
												Green =	BLACK;
											end
										endcase

								end
							else
								begin
									Red = 	BLACK;
									Blue = 	BLACK;
									Green =	BLACK;
								end

						end
						else
						begin
							if(doodle_on_right == 1'b1)
						begin
							case(doodle_data)

													3'h0:
														begin

															case(bg_data)

																3'h0: // Unused
																begin
																	Red = 	8'hF7;
																	Green = 	8'hF3;
																	Blue = 	8'hF1;
																end

																3'h1: // White
																begin
																	Red = 	WHITE;
																	Green = 	WHITE;
																	Blue = 	WHITE;
																end

																3'h2: // Peach
																begin
																	Red = 	PEACH_R;
																	Green = 	PEACH_G;
																	Blue = 	PEACH_B;
																end

																default: // Offwhite
																begin
																Red = 	OFFWHITE_R;
																Green = 	OFFWHITE_G;
																Blue = 	OFFWHITE_B;
																end

														endcase
													end


												3'h1: // Yellow
												begin
												Red = 	YELLOW_R;
												Green = 	YELLOW_G;
												Blue = 	YELLOW_B;
												end


												3'h2: // Green
												begin
												Red = 	GREEN_R;
												Green = 	GREEN_G;
												Blue = 	GREEN_B;
												end


												3'h3: // Black
												begin
												Red = 	BLACK;
												Green = 	BLACK;
												Blue = 	BLACK;
												end

												default:
												begin
												Red = 	BLACK;
												Green = 	BLACK;
												Blue = 	WHITE;
												end

											endcase
											end

										else
											begin
									//		Red = 8'h00;
									//		Green = 8'h00;
									//		Blue = 8'h00;
													case(bg_data)

														3'h0: // Unused
														begin
															Red = 	8'hFF;
															Green = 	8'hF3;
															Blue = 	8'hF1;
														end

														3'h1: // White
														begin
															Red = 	WHITE;
															Green = 	WHITE;
															Blue = 	WHITE;
														end

														3'h2: // Peach
														begin
															Red = 	PEACH_R;
															Green = 	PEACH_G;
															Blue = 	PEACH_B;
														end

														default:
														begin
														Red = 	8'hF7;
														Green = 	8'hF3;
														Blue = 	8'hF1;
														end
												 endcase
											end
						end
					end


		endcase
	end

endmodule
