`timescale 1ns / 1ps

module top(clk,rst, switch, anode, sseg);
	input [2:0] switch;
	input clk, rst;
	output [7:0] sseg;
	output [3:0] anode;
	
	wire [31:0] data_fromRAM1;
	reg wrEn1;
	reg [9:0] addr_toRAM1;
	reg [31:0] data_toRAM1;
	
	wire [31:0] data_fromRAM2;

	wire wrEn;
	wire [9:0] addr_toRAM;
	wire [12:0] data_toRAM;
	
	wire [7:0] digit1;
	wire [7:0] digit2;
	wire [7:0] digit3;
	wire [7:0] digit4;
	wire [12:0] binary;
	wire [15:0] decimal;
	
memory m (
  .clka(clk), // input clka
  .wea(wrEn1), // input [0 : 0] wea
  .addra(addr_toRAM1), // input [9 : 0] addra
  .dina(data_toRAM1), // input [31 : 0] dina
  .douta(data_fromRAM1), // output [31 : 0] douta
 
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(10'd101), // input [9 : 0] addrb
  .dinb(0), // input [31 : 0] dinb
  .doutb(data_fromRAM2) // output [31 : 0] doutb
);

assign binary = data_fromRAM2;
	
	SimpleCPU CPU( clk, rst, data_fromRAM1, wrEn, addr_toRAM, data_toRAM );
	
	binary2bcd bcd_converter(clk, rst, binary, decimal);

	
	ssd_decoder ssd1(decimal[3:0], digit1);	
	
	ssd_decoder ssd2(decimal[7:4], digit2);	
	
	ssd_decoder ssd3(decimal[11:8], digit3);	
	
	ssd_decoder ssd4(decimal[15:12], digit4);	
	
	
	scan_unit int_scan_unit( 
						 .clk_s(clk), 
						 .rst_s(rst),
						 .sseg_s({ digit4, digit3, digit2, digit1 }), 
						 .anode_s(anode[3:0]), 
						 .sout_s(sseg[7:0]));
						 
always @(posedge clk) begin
      if(rst) begin 
         addr_toRAM1 <= 10'd1022;
         data_toRAM1 <= switch[2:0];
			wrEn1 <= 1'b1;
      end
		else begin 
			wrEn1 <= wrEn;
			addr_toRAM1<=addr_toRAM; //CPU address
			data_toRAM1<=data_toRAM; // data from CPU
		end
end
endmodule
