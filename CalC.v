`timescale 1ns / 1ns

module CalC(input [15:0]x, 
            input [15:0]y,
            input zx,nx,zy,ny,f,no,
            output reg ng,zr,
            output reg [15:0]o);
            
            wire [15:0]x1;
            wire [15:0]y1;
            wire [16:0]f1;
            wire [16:0]f2;
            assign x1 = ~x&{16{nx}}|{16{nx&zx}}|{16{~nx&~zx}}&x;
            assign y1 = ~y&{16{ny}}|{16{ny&zy}}|{16{~ny&~zy}}&y;
            assign f1[16:0] =f?(x1+y1):(x1&y1);
            assign f2[16:0] =no?~f1:f1;

            always @(*) begin
                ng <= f2[16];
                zr <= (f2=={16{1'b0}});           
                o <= f2[15:0];
            end
endmodule