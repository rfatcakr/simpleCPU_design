`timescale 1ns / 1ps

module SimpleCPU(clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM);

parameter SIZE = 10;

input clk, rst;
input wire [31:0] data_fromRAM;
output reg wrEn;
output reg [SIZE-1:0] addr_toRAM;
output reg [31:0] data_toRAM;

`define STATE0 0
`define STATE1 1
`define STATE2 2
`define STATE3 3
`define STATE4 4
`define STATE5 5

reg [7:0] currentState, nextState;
reg [SIZE-1:0] cnt, cntNext;
reg [31:0] instructionWord, instructionWordNext;
reg [31:0] regA, regANext;
reg [31:0] regB, regBNext;
reg [24:0] slowdown;
reg [SIZE-1:0] addr_toRAM_Next;
reg [31:0] data_toRAM_Next;
reg wrEn_Next;

always@(posedge clk) begin
	if(rst || slowdown == 25'd5000000)
		slowdown <= 25'd0;
	else
		slowdown <= slowdown + 1'b1;
end

always@(posedge clk) begin
    if(rst) begin
        currentState <= `STATE0;
        cnt <= 0;
        instructionWord <= 0;
        regA <= 0;
        regB <= 0;
        addr_toRAM <= 0;
        data_toRAM <= 0;
        wrEn <= 0;
    end

    else if(slowdown == 25'd5000000) begin
            currentState <= nextState;
            cnt <= cntNext;
            instructionWord <= instructionWordNext;
            regA <= regANext;
            regB <= regBNext;
            addr_toRAM <= addr_toRAM_Next;
            data_toRAM <= data_toRAM_Next;
            wrEn <= wrEn_Next;
    end
end

always@(*) begin // default values

    nextState = `STATE0;
    cntNext = cnt;
    instructionWordNext = instructionWord;
    regANext = regA; // regA
    regBNext = regB;  // regB
    wrEn_Next = wrEn;
    addr_toRAM_Next = addr_toRAM;
    data_toRAM_Next = data_toRAM;
  
   case(currentState)  
        `STATE0: begin
        wrEn_Next = 0;
        addr_toRAM_Next = 0;
        data_toRAM_Next = 0;
        cntNext = 0;
        instructionWordNext = 0;
        regANext = 0;
        regBNext = 0;
        nextState = `STATE1;
        end
  
        `STATE1: begin
		  wrEn_Next = 0;
        addr_toRAM_Next = cnt;
        cntNext = cnt + 1;
        nextState = `STATE2;
        end
  
        `STATE2: begin
        if(data_fromRAM [31:29] == 3'b101 &&(~data_fromRAM[28])) begin
            addr_toRAM_Next = data_fromRAM[13:0];
            instructionWordNext = data_fromRAM;
        end      
        else begin
            addr_toRAM_Next = data_fromRAM[27:14];
            instructionWordNext = data_fromRAM;
        end      
        nextState = `STATE3;
        end
      
        `STATE3: begin // 1 bit control
        regANext = data_fromRAM;
      if (instructionWord [31:29] == 3'b101 && (instructionWord[28])) begin
            addr_toRAM_Next = instructionWord [13:0];
         nextState = `STATE4;
      end
      
        else if(instructionWord [31:29] == 3'b101 &&(~instructionWord[28])) begin
            addr_toRAM_Next = data_fromRAM;
         nextState = `STATE4;
        end      
      else if(~instructionWord[28]) begin
            addr_toRAM_Next = instructionWord [13:0];
         nextState = `STATE4;
      end      
        else if (instructionWord [31:29] == 3'b011) begin
            addr_toRAM_Next = instructionWord [13:0];
         nextState = `STATE4;
        end      
        else begin
        nextState = `STATE5;
      end
        end
      
        `STATE4: begin
        regBNext = data_fromRAM;
        nextState = `STATE5;
        end
      
        `STATE5: begin
        case(instructionWord[31:28])
        {3'b000,1'b0}: begin // operation ADD
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regA + regB);
        end

        {3'b000,1'b1}: begin // operation ADDi
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regA + instructionWord[13:0]);
        end
      {3'b001,1'b0}: begin // operation NAND
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = ~(regA & regB);
        end
      {3'b001,1'b1}: begin // operation NANDi
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = ~(regA & instructionWord[13:0]);
        end
      {3'b011 , 1'b1}:begin // operation LTi
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regA < instructionWord[13:0]);
        end
      {3'b100,1'b0}:begin // operation CP
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = regB;
        end
      {3'b100, 1'b1}: begin // operation CPi  
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = instructionWord[13:0];
        end
      {3'b101, 1'b0}: begin // operation CPI
            wrEn_Next = 1;
         addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = regB;
        end
      {3'b101,1'b1}: begin // operation CPIi
            wrEn_Next = 1;
         addr_toRAM_Next = regA;
            data_toRAM_Next = regB;
      end
        {3'b110,1'b0}:begin // operation BZJ
            cntNext = (regB == 0) ? regA : (cnt);  
      end
      {3'b110,1'b1}:begin // operation BZJi
            cntNext = regA + instructionWord[13:0];
        end
        {3'b111, 1'b0}: begin // operation MUL
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regA * regB);  
        end
        {3'b010, 1'b0}: begin // operation SRL
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regB < 32) ? ((regA) >> (regB)) : ((regA) << ((regB) - 32));
        end
        {3'b010, 1'b1}: begin // operation SRLi
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (instructionWord[13:0] < 32) ? ((regA) >> instructionWord[13:0]) : ((regA) << (instructionWord[13:0] - 32));  
        end
        {3'b011, 1'b0}: begin // operation LT
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regA < regB);
        end
        {3'b111, 1'b1}: begin // operation MULi
            wrEn_Next = 1;
            addr_toRAM_Next = instructionWord[27:14];
            data_toRAM_Next = (regA * instructionWord[13:0]);  
        end
        endcase
        nextState= `STATE1;
    end
    endcase
end

endmodule

