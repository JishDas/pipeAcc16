`include "Processor.v"

module tb_Processor;
reg clk1, clk2;
integer op, i;
reg [15:0]ins[0:29];
reg [15:0]data[0:29];

pipeAcc16 dut
(
    .clk1 (clk1),
    .clk2 (clk2)
);

localparam CLK_PERIOD = 6;
always #(CLK_PERIOD/2) begin
    clk1 <= ~clk1;
    #2 clk2 <= ~clk2;
end

// clock initializations
initial begin
    clk1 <= 0;
    clk2 <= 0;
    #(CLK_PERIOD*5) $finish;
    $fclose(ins);
    $fclose(data);
    $fclose(op);
end

// initialization of PC, other flags
initial begin
    dut.pipeAcc16.HLT      <= 0;
    dut.pipeAcc16.Wrt      <=  0;
    dut.pipeAcc16.TAKEN_BRANCH  <= 0;
    dut.pipeAcc16.EX_MEM_IR    <= {16{1'b0}};
    dut.pipeAcc16.PC           <= {16{1'b0}};

end

// initialization of Memory and Reg bank
initial begin
    ins = $readmemh("Program.txt", ins);
    data = $readmemh("Data.txt", data);
    op = $fopen("Output.txt", "w");

    
    $dumpfile("op.vcd");
    $dumpvars(0,tb_Processor);
end

endmodule