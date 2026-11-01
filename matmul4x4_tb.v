module matmul4x4_tb;
    reg clk, rst, start;
    reg signed [7:0] a_in, b_in;
    reg [3:0] a_addr, b_addr, c_addr;
    reg a_we, b_we;
    wire signed [31:0] c_out;
    wire done;

    matmul4x4 uut(.clk(clk), .rst(rst), .start(start),
                  .a_in(a_in), .b_in(b_in),
                  .a_addr(a_addr), .b_addr(b_addr), .c_addr(c_addr),
                  .a_we(a_we), .b_we(b_we),
                  .c_out(c_out), .done(done));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst=1; start=0; a_we=0; b_we=0; a_in=0; b_in=0;
        a_addr=0; b_addr=0; c_addr=0;
        #20 rst=0;

        @(negedge clk); a_we=1; a_addr=0; a_in=1;
        @(negedge clk); a_addr=1; a_in=2;
        @(negedge clk); a_addr=4; a_in=3;
        @(negedge clk); a_addr=5; a_in=4;
        @(negedge clk); a_we=0;

        @(negedge clk); b_we=1; b_addr=0; b_in=5;
        @(negedge clk); b_addr=1; b_in=6;
        @(negedge clk); b_addr=4; b_in=7;
        @(negedge clk); b_addr=5; b_in=8;
        @(negedge clk); b_we=0;

        $display("LOADED: A0=%0d A1=%0d A4=%0d A5=%0d B0=%0d B1=%0d B4=%0d B5=%0d",
            uut.A[0], uut.A[1], uut.A[4], uut.A[5],
            uut.B[0], uut.B[1], uut.B[4], uut.B[5]);

        @(negedge clk); start=1;
        @(negedge clk); start=0;

        repeat(20) @(posedge clk);

        $display("C[0]=%0d C[1]=%0d C[4]=%0d C[5]=%0d",
            uut.C[0], uut.C[1], uut.C[4], uut.C[5]);
        if (uut.C[0]==19 && uut.C[1]==22 && uut.C[4]==43 && uut.C[5]==50)
            $display("RESULT: PASS");
        else
            $display("RESULT: FAIL");
        $finish;
    end
endmodule
