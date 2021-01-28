//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
              // output logic  is_ball,             // Whether current pixel belongs to ball or background

               output logic [9:0] x_position, y_position,
                input logic [2:0] direction,
					input [7:0]   keycode, 					//key input from keyboard
					output [1:0] exported_direction,
					output [31:0] _seconds,
					input [15:0] SW,
					input game_reset,
					input [2:0] welcome_mode,
					output [15:0] jumping_status_out,
					output [9:0] Ball_Y_Step_,
          output logic Frame_Clk
					//output logic jumping_status_
              );

    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    //.parameter [9:0] Ball_Y_Center = 10'd370;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    //parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
  //  parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
   // parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd64;        // Ball size
	 //parameter [2:0] init_vel = 3'd1;			 // Used for gravity
  //  parameter [2:0] accel = 3'd3;
	// logic [31:0] time_;
	 //logic [31:0] seconds;

	// assign Ball_Y_Step_ = Ball_Y_Step;

	 //assign jumping_status_ = jumping_status;

    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_X_offset; // Ball_Y_Pos, Ball_Y_Motion, Ball_Y_Step;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in; // Ball_Y_Pos_in, Ball_Y_Motion_in;
	  logic Has_Not_Offset, return_to_down0, jumping_status_load;
	  logic [1:0] exported_direction_;
	  logic [15:0] jumping_status_in;

	  //parameter [2:0] init_vel = 3'd1;
    assign x_position = Ball_X_Pos;
    assign Frame_Clk = frame_clk_rising_edge;
    //assign y_position = Ball_Y_Pos;

    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers

//	 //for gravity
//	 always_ff @ (posedge Clk)
//    begin
//    time_ = time_ + 1;
//	 if(time_ == 50000000)
//		seconds = seconds + 1;
//    end



// ----------------------------------------//
//														 //
//					FSM for Jumping				 //
//														 //
// ----------------------------------------//

//	 enum logic [4:0] {stable, up0, up1, up2, up3, up4, up5, down0, down1, down2, down3, down4, down5} State, Next_state;
//
//	 logic up_detected, jumping_status;
//
//	 always_ff @ (posedge frame_clk_rising_edge)
//	 begin
//		if(Reset | game_reset)
//		begin
//			State <= stable;
//		end
//		else
//			begin
//			State <= Next_state;
//			//jumping_status_ <= jumping_status;
//			end
//	 end
//
//	 always_comb
//	 begin
//		Next_state = State;
//
//		// default
//		//Ball_Y_Step = 10'd0;
//		jumping_status_load = 1'b0;
//		jumping_status_in = 1'b0;
//
//		unique case (State)
//			stable:
//			begin
//				jumping_status_load = 1'b1;
//				jumping_status_in = 1'b1;
//				if(direction[2] || welcome_mode == 3'b000 || welcome_mode == 3'b001) // direction[2]
//					Next_state = up0;
//				else
//					Next_state = stable;
//			end
//
//			up0:
//				begin
//				Next_state = up1;
//				jumping_status_load = 1'b1;
//				jumping_status_in = 15'd2;
//				end
//
//			up1:
//				begin
//				Next_state = up2;
//				jumping_status_load = 1'b1;
//				jumping_status_in = 15'd3;
//				end
//
//			up2:
//				Next_state = up3;
//
//			up3:
//				Next_state = up4;
//
//			up4:
//				Next_state = up5;
//
//			up5:
//				Next_state = down5;
//
//			down5:
//				Next_state = down4;
//
//			down4:
//				Next_state = down3;
//
//			down3:
//				Next_state = down2;
//
//			down2:
//				Next_state = down1;
//
//			down1:
//				Next_state = down0;
//
//			down0:
//				Next_state = stable;
//
//			default:
//				Next_state = stable;
//
//		endcase
//
//		case(State)
//			stable:
//				begin
//				Ball_Y_Step = 10'd0;
//				//jumping_status = 1'b0;
//				end
//
//			up0:
//				begin
//				Ball_Y_Step = 10'd30;
//				//jumping_status = 1'b1;
//				end
//
//			up1:
//				Ball_Y_Step = 10'd15;
//
//			up2:
//				Ball_Y_Step = 10'd8;
//
//			up3:
//				Ball_Y_Step = 10'd4;
//
//			up4:
//				Ball_Y_Step = 10'd2;
//
//			up5:
//				Ball_Y_Step = 10'd0;
//
//			down0:
//				Ball_Y_Step = -(10'd30);
//
//			down1:
//				Ball_Y_Step = -(10'd15);
//
//			down2:
//				Ball_Y_Step = -(10'd8);
//
//			down3:
//				Ball_Y_Step = -(10'd5);
//
//			down4:
//				Ball_Y_Step = -(10'd2);
//
//			down5:
//				begin
//					Ball_Y_Step = -(10'd0);
//					jumping_status_load = 1'b1;
//					jumping_status_in = 15'd6;
//				end
//
//			default:
//				Ball_Y_Step = 10'd0;
//		endcase
//	 end
//
//	 register jumping_status_reg(.Clk(Clk), .Reset(Reset), .Load(jumping_status_load), .D(jumping_status_in), .Q(jumping_status_out));

    always_ff @ (posedge Clk)
    begin
        if (Reset || game_reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
          //  Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
          //  Ball_Y_Motion <= 10'd0;

        end
        else if(welcome_mode == 3'b000) // Jump on the ESCAPE button
				Ball_X_Pos <= 10'd219;
		  else if(welcome_mode == 3'b001)
				Ball_X_Pos <= 10'd419;

		  else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            //Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
          //  Ball_Y_Motion <= Ball_Y_Motion_in;
				if(direction[1])
					begin
						exported_direction_[1] = 1'b1;
						exported_direction_[0] = 1'b0;
					end
				if(direction[0])
					begin
						exported_direction_[1] = 1'b0;
						exported_direction_[0] = 1'b1;
					end
        end
    end

	 assign exported_direction = exported_direction_;
    //////// Do not modify the always_ff blocks. ////////

    // You need to modify always_comb block. *****************************
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
      //  Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
       // Ball_Y_Motion_in = Ball_Y_Motion;

        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
         //   if( (Ball_Y_Pos + Ball_Size == 10'd400) && (Ball_X_Pos + Ball_Size <= 10'd500) && (Ball_X_Pos >= 10'd400)) //Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
				//begin
					// Ball_X_Motion_in = 10'd0;
                //B/all_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  //  2's complement.
				//end
           /// e////lse if //( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
              //  begin
					 //Ball_X_Motion_in = 10'd0;
					 //Ball_Y_Motion_in = Ball_Y_Step;
					 //end
            // TODO: Add other boundary detections and handle keypress here.

                    if( Ball_X_Pos + (Ball_Size/2) >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
                begin
					// Ball_Y_Motion_in = 10'd0;
					 //Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement.
					 Ball_X_Pos_in = 10'd0;
					 end
            else if ( Ball_X_Pos - (Ball_Size/2) <= Ball_X_Min)  // Ball is at the left edge, BOUNCE!
                begin
					 //Ball_Y_Motion_in = 10'd0;
					// Ball_X_Motion_in = Ball_X_Step;			//this is annoying
					 Ball_X_Pos_in = 10'd600;
					 end

					 else
					 begin

//					 if(direction[2]) //direction[2]		//keycode for W
//						begin
//						if(Ball_Y_Pos > Ball_Y_Min + Ball_Size)	//this is annoying
//						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
//						end



					 if(direction[1])		//keycode for A
					 begin
					 if ( Ball_X_Pos > Ball_X_Min + Ball_Size )
					 Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
					 end

//					 if(keycode == 8'h16)		//keycode for S
//					 begin
//					 Ball_X_Motion_in = 10'd0;
//					 if( Ball_Y_Pos + Ball_Size < Ball_Y_Max )	//this is annoying
//					 Ball_Y_Motion_in = Ball_Y_Step;
//					 end

					 if(direction[0])		//keycode for D
					 begin
					 if( Ball_X_Pos + Ball_Size < Ball_X_Max)	//this is annoying
					 Ball_X_Motion_in = Ball_X_Step;
					 end

           if(~direction[1] && ~direction[0])
				Ball_X_Motion_in = 9'd0;
			end


            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion + Ball_X_offset;
            //Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;	//this is annoying
				//Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;//((init_vel*seconds) + accel*((seconds)**2));
        end
//
        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ball_Y_Pos is updated using Ball_Y_Motion.
              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old?
              What is the difference between writing
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    //end

    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
//    int DistX, DistY, Size;
//    assign DistX = DrawX - Ball_X_Pos;
//    assign DistY = DrawY - Ball_Y_Pos;
//    assign Size = Ball_Size;
//    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
//            is_ball = 1'b1;
//        else
//            is_ball = 1'b0;
//        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while
//           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
//           of the 12 available multipliers on the chip! */
//    end
    end
endmodule
