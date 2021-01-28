//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
				 input  [15:0] SW,
				output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
            inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );

	 logic [9:0] DrawX_, DrawY_, y_velocity;
	 logic [9:0] doodle_x, doodle_y;
    logic Reset_h, Clk, jump ;
	 logic [15:0] jumping_status, Counter;
	 logic [31:0] seconds;
    logic [7:0] keycode, debug_x0_coor, debug_x1_coor, debug_x2_coor, col_data;
    logic [2:0] _direction;
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
        _direction[1] <= ~(KEY[2]);
        _direction[0] <= ~(KEY[1]);
		  _direction[2] <= ~(KEY[3]);
    end

	 logic [2:0] color_mapper_control; // Controls the stage of graphics for color mapper such as welcome screen, game, or death
    logic [1:0] hpi_addr, doodle_direction;
    logic [15:0] hpi_data_in, hpi_data_out, Settings_INPUT_out, Settings_COLOR_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset, game_reset, doodle_pos, Frame_Clk, move_platforms_down;
	 logic [9:0] Y_Step;
    logic [3:0] Color;
	 logic [9:0] Platform_Y; 
	 logic [10:0][0:31] map_y_data ;
	 logic [9:0] platform_y_out0, platform_y_out1, platform_y_out2, platform_y_out3, platform_y_out4, platform_y_out5, platform_y_out6, 
					 platform_x_out0, platform_x_out1, platform_x_out2, platform_x_out3, platform_x_out4, platform_x_out5, platform_x_out6;
                            
	                                                                                                                    
	                                                                                                                   
	                                                                                                                   
                                                                                                                     
	debugging_module debug( .x_coordinate(doodle_x),                                                                                         
                          .y_coordinate(doodle_y),
                          .Clk(Clk),
                          .DrawX(DrawX_),
                          .DrawY(DrawY_),
									        .x_data_out_0(debug_x0_coor)
                          );

	game_controller controller(
                          .Clk(Clk),
                          .Reset(Reset_h),
                          .KEY(KEY),
								  .doodle_y(doodle_y),
                          .SW(SW),
                          .color_mapper(color_mapper_control),
                          .reset_game(game_reset),
								  .Settings_INPUT_out_(Settings_INPUT_out),
								  .Settings_COLOR_out_(Settings_COLOR_out)
                          //.Color(Color)
                          );

  gravity gravity(.position_y_out(doodle_y), .Clk(Clk), .Counter_(Counter), .activate_gravity(1'b1), .Frame_Clk(Frame_Clk), .Reset(Reset_h || game_reset), .SW(SW[5]), .y_velocity(y_veloticy), .jump(jump), .move_platforms_down(move_platforms_down));

    // Interface between NIOS II and EZ-OTG chip
//    hpi_io_intf hpi_io_inst(
//                            .Clk(Clk),
//                            .Reset(Reset_h),
//                            // signals connected to NIOS II
//                            .from_sw_address(hpi_addr),
//                            .from_sw_data_in(hpi_data_in),
//                            .from_sw_data_out(hpi_data_out),
//                            .from_sw_r(hpi_r),
//                            .from_sw_w(hpi_w),
//                            .from_sw_cs(hpi_cs),
//                            .from_sw_reset(hpi_reset),
//                            // signals connected to EZ-OTG chip
//                            .OTG_DATA(OTG_DATA),
//                            .OTG_ADDR(OTG_ADDR),
//                            .OTG_RD_N(OTG_RD_N),
//                            .OTG_WR_N(OTG_WR_N),
//                            .OTG_CS_N(OTG_CS_N),
//                            .OTG_RST_N(OTG_RST_N)
//    );

     // You need to make sure that the port names here match the ports in Qsys-generated codes.
//     nios_system nios_system(
//                             .clk_clk(Clk),
//                             .reset_reset_n(1'b1),    // Never reset NIOS
//                             .sdram_wire_addr(DRAM_ADDR),
//                             .sdram_wire_ba(DRAM_BA),
//                             .sdram_wire_cas_n(DRAM_CAS_N),
//                             .sdram_wire_cke(DRAM_CKE),  		 //this is annoying
//                             .sdram_wire_cs_n(DRAM_CS_N),
//                             .sdram_wire_dq(DRAM_DQ),
//                             .sdram_wire_dqm(DRAM_DQM),
//                             .sdram_wire_ras_n(DRAM_RAS_N),
//                             .sdram_wire_we_n(DRAM_WE_N),
//                             .sdram_clk_clk(DRAM_CLK),		//check pliss for clk ****************** check signal
//                             .keycode_export(keycode),
//                             .otg_hpi_address_export(hpi_addr),
//                             .otg_hpi_data_in_port(hpi_data_in),
//                             .otg_hpi_data_out_port(hpi_data_out),
//                             .otg_hpi_cs_export(hpi_cs),
//                             .otg_hpi_r_export(hpi_r),
//                             .otg_hpi_w_export(hpi_w),
//                             .otg_hpi_reset_export(hpi_reset)		//this is annoying
//    );


    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));

    // TODO: Fill in the connections for the rest of the modules
    VGA_controller vga_controller_instance(			           	.Clk(Clk),         // 50 MHz clock
																					.Reset(Reset_h),       // Active-high reset signal
																					.VGA_HS(VGA_HS),      // Horizontal sync pulse.  Active low
																					.VGA_VS(VGA_VS),      // Vertical sync pulse.  Active low
																					.VGA_CLK(VGA_CLK),     // 25 MHz VGA clock input
																					.VGA_BLANK_N(VGA_BLANK_N), // Blanking interval indicator.  Active low.
																					.VGA_SYNC_N(VGA_SYNC_N),  // Composite Sync signal.  Active low.  We don't use it in this lab,
																									// but the video DAC on the DE2 board requires an input for it.
																					.DrawX(DrawX_),       // horizontal coordinate
																					.DrawY (DrawY_) );	//this is annoying

	logic is_ball_;



    // Which signal should be frame_clk?
    ball ball_instance(
                      .Clk(Clk),               // 50 MHz clock
                      .Reset(Reset_h),         // Active-high reset signal
                      .frame_clk(VGA_VS),     //*****  // The clock indicating a new frame (~60Hz)
               				.DrawX(DrawX_),
									    .DrawY(DrawY_),          // Current pixel coordinates
										  .x_position(doodle_x),  // doodle's x position
										 // .y_position(doodle_y),  // doodle's y position
									    .keycode(keycode),
                      .jumping_status_out(jumping_status),
                      .Ball_Y_Step_(Y_Step), //.jumping_status_(jumping_status),
										  .direction(_direction),
                      .exported_direction(doodle_direction),
                      ._seconds(seconds),
                      .SW(SW),
                      .game_reset(game_reset),
                      .welcome_mode(color_mapper_control),
                      .Frame_Clk(Frame_Clk));    // Whether current pixel belongs to ball or background

							 
							 logic [3:0] why_u_no_work;
    color_mapper color_instance(  //.is_ball(is_ball_),            // Whether current pixel belongs to ball
                      .debugging_mode(SW[0]),                              //   or background (computed in ball.sv)
                      .DrawX(DrawX_),
							        .DrawY(DrawY_),       // Current pixel coordinates
										  .VGA_R(VGA_R), 	//this is annoying
										  .VGA_G(VGA_G), 	//this is annoying
										  .VGA_B(VGA_B),
                      .DoodleX_right(doodle_x),
                      .DoodleY_right(doodle_y),
                      .doodle_direction(doodle_direction),
                      .debug_x0_coor(debug_x0_coor),
                      .graphics_control(color_mapper_control),
                      .Clk(Clk),
                      .Platform_Y(Platform_Y),
							 .Settings_INPUT(Settings_INPUT_out),
							 .Settings_COLOR(Settings_COLOR_out),
							 .map_y_data(map_y_data), .Reset(Reset_h),
							 .position_y_out0(platform_y_out0), .position_x_out0(platform_x_out0),
							 .position_y_out1(platform_y_out1), .position_x_out1(platform_x_out1),
							 .position_y_out2(platform_y_out2), .position_x_out2(platform_x_out2),
							 .position_y_out3(platform_y_out3), .position_x_out3(platform_x_out3),
							 .position_y_out4(platform_y_out4), .position_x_out4(platform_x_out4),
							 .position_y_out5(platform_y_out5), .position_x_out5(platform_x_out5),
							 .position_y_out6(platform_y_out6), .position_x_out6(platform_x_out6),
							 .col_data(col_data), .weird_platforms(why_u_no_work)
							 
                      //.Color(Color)
										  ); // VGA RGB output
										  logic [3:0] num_active, pointer;

platforms platform_controller(.doodle_y(doodle_y), .doodle_x(doodle_x), .Clk(Clk), .Frame_Clk(Frame_Clk), .Reset(Reset_h || game_reset), .Generate(), .jump(jump),
										.position_y_out0(platform_y_out0), .position_x_out0(platform_x_out0),
								   	.position_y_out1(platform_y_out1), .position_x_out1(platform_x_out1),
								   	.position_y_out2(platform_y_out2), .position_x_out2(platform_x_out2),
								   	.position_y_out3(platform_y_out3), .position_x_out3(platform_x_out3),
								   	.position_y_out4(platform_y_out4), .position_x_out4(platform_x_out4), .move_platforms_down(move_platforms_down),
										.position_y_out5(platform_y_out5), .position_x_out5(platform_x_out5), .pointer_(pointer), 
								   	.position_y_out6(platform_y_out6), .position_x_out6(platform_x_out6), .num_active(num_active), .SW7(SW[7]), .SW8(SW[8]), .col(col_data));
//
//Green_platform platform_instance(.Clk(Clk), .Frame_Clk(Frame_Clk), .Reset(Reset_h || game_reset), .doodle_x(doodle_x), .Platform_Y(Platform_Y)
//								   		 );
											 
											 
											 
    // position_y_out6, position_x_out6, Display keycode on hex display
    HexDriver hex_inst_0 (jump, HEX0);
    HexDriver hex_inst_1 (platform_x_out4[7:4], HEX1);
	 HexDriver hex_inst_2 (platform_x_out4[9:8], HEX2);
    HexDriver hex_inst_3 (why_u_no_work[3:0], HEX3);
	 HexDriver hex_inst_4 (pointer[3:0], HEX4);
    HexDriver hex_inst_5 (col_data[3:0], HEX5);
	 HexDriver hex_inst_6 (num_active[3:0], HEX7);
	 HexDriver hex_inst_7 (col_data[7:4], HEX6);
	 

	 
map map_(.CLK(Clk), .Reset(Reset_h || game_reset), .Doodle_X(doodle_x), .Doodle_Y(doodle_y), .map_y_data(map_y_data), .Game_Action());


    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule
