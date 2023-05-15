`include "CalC.v"

module tb_CalC;
reg clk;
reg [5:0]cb_EX;
reg [15:0]y;

CalC dut
(
    .x(16'hxxxx), .y(y), .zx(cb_EX[5]), .nx(cb_EX[4]), .zy(cb_EX[3]), .ny(cb_EX[2]), .f(cb_EX[1]), .no(cb_EX[0])
);

localparam CLK_PERIOD = 2;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    clk     <= 0;
    cb_EX   <= #1 6'b110111;
    y       <= #1 16'h0000;
    $dumpfile("tb_CalC.vcd");
    $dumpvars(0, tb_CalC);
end

initial begin
    #4 $finish;
end

endmodule