module matmul8x8_tb;
    reg clk=0, rst, start;
    reg signed [7:0] a_in, b_in;
    reg [5:0] a_addr, b_addr, c_addr;
    reg a_we, b_we;
    wire signed [31:0] c_out;
    wire done;
    integer i;

    matmul8x8 uut(.clk(clk), .rst(rst), .start(start),
        .a_in(a_in), .b_in(b_in),
        .a_addr(a_addr), .b_addr(b_addr), .c_addr(c_addr),
        .a_we(a_we), .b_we(b_we),
        .c_out(c_out), .done(done));

    always #5 clk = ~clk;

    initial begin
        $display("===== MATMUL 8x8 =====");
        rst=1; start=0; a_we=0; b_we=0;
        a_in=0; b_in=0; a_addr=0; b_addr=0; c_addr=0;
        #20 rst=0;

        @(negedge clk); a_we=1;
        for (i=0; i<8; i=i+1) begin
            a_addr=i; a_in=i+1; @(negedge clk);
        end
        a_we=0;

        @(negedge clk); b_we=1;
        for (i=0; i<8; i=i+1) begin
            b_addr=i*8; b_in=1; @(negedge clk);
        end
        b_we=0;

        @(negedge clk); start=1;
        @(negedge clk); start=0;

        repeat(30) @(posedge clk);
        $display("C[0][0] = %0d (expect 36 = 1+2+3+4+5+6+7+8)", uut.C[0]);
        if (uut.C[0] == 36) $display("RESULT: PASS");
        else $display("RESULT: FAIL");
        $finish;
    end
endmodule
