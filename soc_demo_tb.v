module soc_demo_tb;
    reg clk=0, rst;
    wire [31:0] result;
    wire halt;
    soc_demo uut(.clk(clk), .rst(rst), .result(result), .halt(halt));
    always #5 clk = ~clk;
    initial begin
        $display("===== SoC: CPU + Accelerator =====");
        rst=1; #20 rst=0;
        repeat(20) @(posedge clk);
        $display("CPU reg R1 = %0d", uut.regs[1]);
        $display("Acc C[0]   = %0d (2*4+3*5=23)", result);
        $display("HALT       = %b", halt);
        if (result == 23 && uut.regs[1] == 23)
            $display("RESULT: PASS - SoC WORKS");
        else
            $display("RESULT: FAIL");
        $finish;
    end
endmodule
