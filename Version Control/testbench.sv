module testbench();

timeunit 10ns;
timeprecision 1ns;

logic  			CLOCK_50;
logic  [3:0]  	KEY;          //bit 0 is set up as Reset\
logic  [15:0] 	SW;
logic  [6:0]  	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7; 
logic  [7:0]  	VGA_R,    
					VGA_G,
					VGA_B;//VGA Green
logic        	VGA_CLK,      //VGA Clock
               VGA_SYNC_N,   //VGA Sync signal
               VGA_BLANK_N,  //VGA Blank signal
					VGA_VS,       //VGA virtical sync signal
               VGA_HS;       //VGA horizontal sync signal
             // CY7C67200 Interface
wire  [15:0] OTG_DATA;     //CY7C67200 Data bus 16 Bits
logic [1:0]  OTG_ADDR;     //CY7C67200 Address 2 Bits
logic        OTG_CS_N,     //CY7C67200 Chip Select
				 OTG_RD_N,     //CY7C67200 Write
				 OTG_WR_N,     //CY7C67200 Read
				 OTG_RST_N;    //CY7C67200 Reset
logic        OTG_INT;      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
logic [12:0] DRAM_ADDR;    //SDRAM Address 13 Bits
wire  [31:0] DRAM_DQ;      //SDRAM Data 32 Bits
logic [1:0]  DRAM_BA;      //SDRAM Bank Address 2 Bits
logic [3:0]  DRAM_DQM;     //SDRAM Data Mast 4 Bits
logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
				 DRAM_CAS_N,   //SDRAM Column Address Strobe
				 DRAM_CKE,     //SDRAM Clock Enable
				 DRAM_WE_N,    //SDRAM Write Enable
			    DRAM_CS_N,    //SDRAM Chip Select
			    DRAM_CLK;     //SDRAM Clock
logic ball_clock;

lab8 tp(.*);

//always_comb begin: INTERNAL_SIGNALS
//	ball_clock = ball.frame_clk_rising_edge;
//end

always begin:Clock_generation
#1 CLOCK_50 = ~CLOCK_50;
end

always begin:VGA_CLOCK
#2 VGA_VS = ~VGA_VS;
end
//
//initial begin: INTERNAL_FORCES
//#10 force ball.frame_clk_rising_edge = 1'b1;
//end

initial begin:Signal_initialization
CLOCK_50 = 0;
VGA_VS = 0;




// TEST VECTORS

#2 KEY[0] = 1'b0;

#2 KEY[0] = 1'b1;

#2 KEY[3] = 1'b0;

//#2 KEY[3] = 1'b1;


end

endmodule  
