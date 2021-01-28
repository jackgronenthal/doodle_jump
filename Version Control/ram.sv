//hi
module frame_rom_ECEB( input [17:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:174719];

			initial
			begin
				$readmemh("spritebytes/ECEB_short_pixel.txt", mem);
			end

			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end

endmodule


module frame_rom_COLOR_un(
						input [13:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:8749];

			initial
			begin
				$readmemh("spritebytes/COLOR_unselected.txt", mem);
			end

			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end

endmodule

module frame_rom_INPUT_un(
						input [13:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:8749];

			initial
			begin
				$readmemh("spritebytes/INPUT_unselected.txt", mem);
			end

			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end

endmodule

module frame_rom_INPUT_sl(
						input [13:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:8749];

			initial
			begin
				$readmemh("spritebytes/INPUT_selected.txt", mem);
			end
			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end
endmodule

module frame_rom_COLOR_sl(
						input [13:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:8749];

			initial
			begin
				$readmemh("spritebytes/COLOR_selected.txt", mem);
			end

			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end

endmodule

module frame_rom_INPUT_ACCEL(
						input [13:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:8749];

			initial
			begin
				$readmemh("spritebytes/HAND_selected.txt", mem);
			end

			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end

endmodule

module frame_rom_INPUT_KEYBOARD(
						input [13:0] read_address,
						input Clk,
						output logic [3:0] data_out);

			logic [3:0] mem [0:8749];

			initial
			begin
				$readmemh("spritebytes/KEYBOARD_selected.txt", mem);
			end

			always_ff @ (posedge Clk)
			begin
				data_out <= mem[read_address];
			end

endmodule


