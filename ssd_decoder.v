`timescale 1ns / 1ps

module ssd_decoder(bcd, ssd);

	input [3:0] bcd;
	output reg [7:0] ssd;
	
	always@(*) begin

		case(bcd)
			4'b0000: ssd[7:0] = 8'h03;
			4'b0001: ssd[7:0] = 8'h9F;
			4'b0010: ssd[7:0] = 8'h25;
			4'b0011: ssd[7:0] = 8'h0D;
			4'b0100: ssd[7:0] = 8'h99;
			4'b0101: ssd[7:0] = 8'h49;
			4'b0110: ssd[7:0] = 8'h41;
			4'b0111: ssd[7:0] = 8'h1F;
			4'b1000: ssd[7:0] = 8'h01;
			4'b1001: ssd[7:0] = 8'h09;
			default: ssd[7:0] = 8'hFF;
		endcase
		
	end

endmodule
