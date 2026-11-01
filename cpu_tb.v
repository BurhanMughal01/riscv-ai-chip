module cpu_tb;
    reg clk, rst;
    wire [7:0] out_val;
    wire halt;

    cpu uut(.clk(clk), .rst(rst), .out_val(out_val), .halt(halt));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);
        rst = 1;
        #20 rst = 0;
        #200;
        $display("================================");
        $display("Program: 5 + 3 = ?");
        $display("CPU output: %0d", out_val);
        $display("Halt: %b", halt);
        $display("================================");
        $finish;
    end
endmodule
