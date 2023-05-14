`timescale 1ns/1ns
`include "CalC.v"

// only implement the IF stage for 0 output
module pipeAcc16(
    clk1, clk2, rst
);

input clk1, clk2, rst;

// Memory
parameter l_ins = 401, l_tot = 1024;
reg [15:0] ins_mem[l_ins-1:0];
reg [15:0] data_mem[l_tot-l_ins-1:0];
reg [5:0] cb_ID, cb_EX;

// IF stage registers
reg [15:0] PC, IF_ID_IR;

// ID stage registers
reg [15:0]  ID_EX_IR, ID_EX_A;

// EX stage registers
reg [15:0]  EX_MEM_IR;     //output reg since ALU is completely a combinational device in our design
reg [15:0]  Acc;
wire [15:0] EX_MEM_ALUOut;

// Mem parameters
integer data_ptr;

// halt flag
reg HLT;
// cond = MSB - ng, LSB - zr
wire [1:0]cond;

// give those control bits to CalC.v and take outputs at clk1
CalC func (.x(Acc), .y(ID_EX_A), .zx(cb_EX[5]),
            .nx(cb_EX[4]), .zy(cb_EX[3]), .ny(cb_EX[2]),
            .f(cb_EX[1]), .no(cb_EX[0]), .clk(clk1), .ng(cond[1]),
            .zr(cond[0]), .o(EX_MEM_ALUOut));

// very simple IF stage
always @(posedge clk1) begin

    data_ptr        <=  data_ptr+1;
    if(~HLT) begin
        IF_ID_IR    <=  ins_mem[PC];
        // if(ID_EX_type == BRANCH)
        // PC          <=  
        PC          <=  PC+1;
    end    
end

// very simple ID stage
always @(posedge clk2) begin

    if(~HLT)begin
        ID_EX_IR   <=  IF_ID_IR;

        if(~ID_EX_IR)   ID_EX_A    <=  data_mem[ID_EX_IR[9:0]];             //direct mem access

        else            ID_EX_A    <=  data_mem[data_mem[ID_EX_IR[9:0]]];   //indirect mem access

        case (ID_EX_IR[14:10])
            5'b00000:   cb_ID  <=  6'b101010;
            5'b00001:   cb_ID  <=  6'b111111;
            5'b00010:   cb_ID  <=  6'b111010;
            5'b00011:   cb_ID  <=  6'b001100;
            5'b00100:   cb_ID  <=  6'b110000;
            5'b00101:   cb_ID  <=  6'b001101;
            5'b00110:   cb_ID  <=  6'b110001;
            5'b00111:   cb_ID  <=  6'b001111;
            5'b01000:   cb_ID  <=  6'b110011;
            5'b01001:   cb_ID  <=  6'b011111;
            5'b01010:   cb_ID  <=  6'b110111;
            5'b01011:   cb_ID  <=  6'b001110;
            5'b01100:   cb_ID  <=  6'b110010;
            default:    cb_ID  <=  6'b110000;
        endcase
    end
end

// very simple EX stage
always @(posedge clk1) begin
    if(~HLT)begin
        cb_EX       <=  cb_ID;
        EX_MEM_IR   <=  ID_EX_IR;
        /* since inpurs are being given at clock edge output will also appear at clock edge
            there is no special need to initialize it as a wire and latch it onto a reg at
            clock edge.
        */
    end
end

// Mem Stage
always @(posedge clk2) begin
    Acc  <=  EX_MEM_ALUOut;
    
end
    
endmodule