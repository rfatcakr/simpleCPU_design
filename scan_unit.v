`timescale 1ns / 1ps

module scan_unit(clk_s, rst_s, sseg_s, anode_s, sout_s);

	input clk_s, rst_s;
	input [31:0] sseg_s;
	output [7:0] sout_s;
	output  [3:0] anode_s;
	
	reg [7:0] sout_s;
	reg [3:0] anode_s;
	reg [14:0] cntr;
	
	always @(posedge clk_s) begin
			if(rst_s) begin
				cntr<=15'd0;
				sout_s <= 8'b11111111;
			end else begin
				cntr <= cntr +1;
			   if (cntr>15'd24000 && cntr<15'd31000)begin
					sout_s<=sseg_s[31:24];
					anode_s<=4'b0111;
				end
				else if (cntr>15'd16000 && cntr<15'd23000)begin
					sout_s<=sseg_s[23:16];
					anode_s<=4'b1011;
				end
				else if (cntr>15'd8000 && cntr<15'd15000)begin
					sout_s<=sseg_s[15:8];
					anode_s<=4'b1101;
				end
				else if (cntr>15'b0 && cntr<15'd7000)begin
					sout_s<=sseg_s[7:0];
					anode_s<=4'b1110;
				end
			end		
   end

endmodule

