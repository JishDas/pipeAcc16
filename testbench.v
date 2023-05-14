`include "Processor.v"

module tb_Processor;
reg clk1, clk2;
integer fd, i;

pipeAcc16 dut
(
    .clk1 (clk1),
    .clk2 (clk2)
);

localparam CLK_PERIOD = 2;
always #(CLK_PERIOD/2) begin
    clk1 <= ~clk1;
    #1 clk2 <= ~clk2;
end

// clock initializations
initial begin
    clk1 <= 0;
    clk2 <= 0;
    #20 $finish;
end

// initialization of PC, other flags
initial begin
    dut.pipeAcc16.HLT      <= 0;
    dut.pipeAcc16.data_ptr <= -1;
    // dut.pipeAcc16.TAKEN_BRANCH <= 0;
    dut.pipeAcc16.EX_MEM_IR    <= {16{1'b0}};
    dut.pipeAcc16.PC           <= {16{1'b0}};

end

// initialization of Memory and Reg bank
initial begin
    dut.ins_mem[0]  <= 16'h2800;
    dut.data_mem[0] <= 16'h0000;

    fd = $fopen("tst.txt", "w");
    // $fstrobe(fd, $time, dut.pipeAcc16.Reg[1]);
    $fstrobe(fd, $time, dut.pipeAcc16.Acc);
    
    $dumpfile("op.vcd");
    $dumpvars(0,tb_Processor);
end

endmodule