module debugging_module(input logic [9:0] x_coordinate, y_coordinate, DrawX, DrawY,
								input logic Clk,
								output logic [7:0] x_data_out_2, x_data_out_1, x_data_out_0);
								
// X coordinate: has max 640
logic [2:0] digits = 3'd0;
logic [9:0] x_coordinate_calc;
logic [10:0] x_coor_values;


always_ff @ (posedge Clk)
begin

	digits[0] <= x_coordinate % 10;
	digits[1] <= x_coordinate % 100;
	digits[2] <= x_coordinate % 1000;

end





//always_comb
//begin
//		digits[0] = x_coordinate%10;
//		digits[1] = (x_coordinate%100) - digits[0];
//		digits[2] = (x_coordinate%1000) - digits[2];
//		
//end


//
//always_ff @ (posedge Clk)
//begin
//	x_coordinate_calc <= x_coordinate;
//	digits[0] <= x_coordinate_calc%10;
////	x_coordinate_calc <= x_coordinate_calc - digits[0];
////	digits[1] <= x_coordinate_calc%100;
////	x_coordinate_calc <= x_coordinate_calc - digits[1];
////	digits[2] <= x_coordinate_calc % 1000;
////	// Get Reduce to be less than 10.
////	digits[1] <= digits[1] / 10;
////	digits[2] <= digits[2] / 100;
////
////	// Find the values as their hex representation
////	x_coor_values[2] <= 16*48 + digits[2];
////	x_coor_values[1] <= 16*48 + digits[1];
////	x_coor_values[0] <= 16*48 + digits[0];
//end

assign x_data_out_0 = digits[0];

//font_rom font_module_2(.addr(x_coor_values[2] + (DrawY%16)), .data(x_data_out_2));
font_rom font_module_1(.addr(x_coor_values[1] + (DrawY%16)), .data(x_data_out_1));
//font_rom font_module_0(.addr(x_coor_values[0] + (DrawY%16)), .data(x_data_out_0));


endmodule 
