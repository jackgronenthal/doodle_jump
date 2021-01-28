module register(input logic Clk, Reset, Load, input logic [15:0] D, output logic [15:0] Q);

always_ff @ (posedge Clk) begin
	if(Reset) begin 
		Q <= 16'h0000;
		end
	else
		if(Load)
			Q <= D;
end 
endmodule

module register16(input logic Clk, Reset, Load, input logic [3:0] index, input logic [15:0] D [0:15], output logic [15:0] Q [15:0][15:0]);
	
	logic D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15;
	logic Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15;
	
	register r0(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 0)), .D(D0), .Q(Q0));
	register r1(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 1)), .D(D1), .Q(Q1));
	register r2(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 2)), .D(D2), .Q(Q2));
	register r3(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 3)), .D(D3), .Q(Q3));
	register r4(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 4)), .D(D4), .Q(Q4));
	register r5(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 5)), .D(D5), .Q(Q5));
	register r6(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 6)), .D(D6), .Q(Q6));
	register r7(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 7)), .D(D7), .Q(Q7));
	register r8(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 8)), .D(D8), .Q(Q8));
	register r9(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 9)), .D(D9), .Q(Q9));
	register r10(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 10)), .D(D10), .Q(Q10));
	register r11(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 11)), .D(D11), .Q(Q11));
	register r12(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 12)), .D(D12), .Q(Q12));
	register r13(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 13)), .D(D13), .Q(Q13));
	register r14(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 14)), .D(D14), .Q(Q14));
	register r15(.Clk(Clk), .Reset(Reset), .Load(Load && (index == 15)), .D(D15), .Q(Q15));
	
	logic [15:0] output_data [15:0] [15:0];
	assign Q = output_data;
	
	assign output_data[0] = Q0;
	assign output_data[1] = Q1;
	assign output_data[2] = Q2;
	assign output_data[3] = Q3;
	assign output_data[4] = Q4;
	assign output_data[5] = Q5;
	assign output_data[6] = Q6;
	assign output_data[7] = Q7;
	assign output_data[8] = Q8;
	assign output_data[9] = Q9;
	assign output_data[10] = Q10;
	assign output_data[11] = Q11;
	assign output_data[12] = Q12;
	assign output_data[13] = Q13;
	assign output_data[14] = Q14;
	assign output_data[15] = Q15;
	
endmodule

