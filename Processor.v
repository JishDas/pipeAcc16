//Some changes were made from the given Ichip PS, so that it could be pipelined
//x input is given from the Acc, and y input is given by the user as address(present in instruction)

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

// Mem registers
reg [9:0]EX_MEM_Add;

// halt flag
reg HLT, TAKEN_BRANCH, Wrt;
// cond = MSB - ng, LSB - zr
wire [1:0]cond;

// give those control bits to CalC.v and take outputs at clk1
CalC func (.x(Acc), .y(ID_EX_A), .zx(cb_ID[5]),
            .nx(cb_ID[4]), .zy(cb_ID[3]), .ny(cb_ID[2]),
            .f(cb_ID[1]), .no(cb_ID[0]), .ng(cond[1]),
            .zr(cond[0]), .o(EX_MEM_ALUOut));

// very simple IF stage
always @(posedge clk1) begin

    if(~HLT && ~TAKEN_BRANCH){
        IF_ID_IR    <=  ins_mem[PC];
        //NPC specially stores sequential ins
        NPC         <= PC+1;
    }   
    PC  <=  TAKEN_BRANCH ?  (ID_EX_IR[15] ? ins_mem[ins_mem[ID_EX_IR[9:0]]] : ins_mem[ID_EX_IR[9:0]]) :  NPC;
    if(TAKEN_BRANCH) TAKEN_BRANCH   <= 0;
end

// very simple ID stage
always @(posedge clk2) begin

    if(~HLT)begin
        ID_EX_IR                           <=  IF_ID_IR;

        //always prefetch the operands
        if(~ID_EX_IR[15])       ID_EX_A    <=  data_mem[ID_EX_IR[9:0]];             //direct mem access

        else                    ID_EX_A    <=  data_mem[data_mem[ID_EX_IR[9:0]]];   //indirect mem access


        //opcode assignment
        case (IF_ID_IR[14:10])
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
            5'b01101:   cb_ID  <=  6'b000010;
            5'b01110:   cb_ID  <=  6'b010011;
            5'b01111:   cb_ID  <=  6'b000111;
            5'b10000:   cb_ID  <=  6'b000000;
            5'b10001:   cb_ID  <=  6'b010101;
            5'b10010:   cb_ID  <=  6'b110000;
            5'b10011:   Wrt    <=  1;
            5'b10100:   TAKEN_BRANCH    <= 1;
            5'b10101:   TAKEN_BRANCH    <= cond[0];
            5'b10110:   TAKEN_BRANCH    <= cond[1];
            5'b10111:   HLT             <= 1;
            default:    cb_ID  <=  6'b110000;
        endcase
    end
end

// very simple EX stage
always @(posedge clk1) begin
    if(~HLT)begin
        // EX_MEM_IR   <=  IF_ID_IR; no need to do this
        cb_EX       <=  cb_ID;
        /* since inputs are being given at clock edge output will also appear at clock edge
            there is no special need to initialize it as a wire and latch it onto a reg at
            clock edge.
        */
        //  if Wrt ins, then take the store address from the instrn
        if(Wrt) EX_MEM_Add  <= (ID_EX_IR[15] ? data_mem[data_mem[ID_EX_IR[9:0]]] : data_mem[ID_EX_IR[9:0]]);
    end
end

// Acc Stage
always @(posedge clk2) begin
    if(~HLT) begin
        //write the final output to Acc
        Acc  <=  EX_MEM_ALUOut;
        //if Wrt, then store the data in the given add
        if(Wrt) data_mem[EX_MEM_Add]   <= Acc;
    end
end
    
endmodule