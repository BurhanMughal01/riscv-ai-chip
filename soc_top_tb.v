module soc_top_tb;
    reg clk=0, rst;
    wire signed [31:0] acc_out;
    wire [31:0] cpu_x3, cpu_mem0;

    soc_top uut(.clk(clk), .rst(rst),
        .acc_out(acc_out), .cpu_x3(cpu_x3), .cpu_mem0(cpu_mem0));

    always #5 clk = ~clk;

    initial begin
        $display("===== SoC: CPU + MAC =====");
        rst=1; #20 rst=0;
        repeat(30) @(posedge clk);
        $display("CPU x3 = %0d", cpu_x3);
        $display("CPU mem[0] = %0d", cpu_mem0);
        $display("MAC acc = %0d", acc_out);
        if (cpu_x3 == 8 && cpu_mem0 == 8)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
        $finish;
    end
endmodule
