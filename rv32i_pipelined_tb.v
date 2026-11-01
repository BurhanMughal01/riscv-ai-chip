module rv32i_pipelined_tb;
    reg clk=0, rst;
    wire [31:0] pc_out, x3_out, x4_out, mem0_out;
    wire [3:0] cyc_out;

    rv32i_pipelined uut(.clk(clk), .rst(rst),
        .pc_out(pc_out), .cyc_out(cyc_out),
        .x3_out(x3_out), .x4_out(x4_out), .mem0_out(mem0_out));

    always #5 clk = ~clk;

    initial begin
        $display("===== PIPELINED RV32I CPU =====");
        rst=1; #20 rst=0;
        repeat(20) @(posedge clk);
        $display("x3 = %0d (expect 8)", x3_out);
        $display("x4 = %0d (expect 8)", x4_out);
        $display("mem[0] = %0d (expect 8)", mem0_out);
        if (x3_out==8 && x4_out==8 && mem0_out==8)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
        $finish;
    end
endmodule
