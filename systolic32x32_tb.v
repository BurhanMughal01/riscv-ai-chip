module systolic32x32_tb;
    reg clk=0, rst, start;
    reg signed [7:0] a_row, b_col;
    reg [4:0] c_row, c_col;
    wire signed [31:0] c_out;
    wire done;
    integer i;

    systolic32x32 uut(.clk(clk), .rst(rst), .start(start),
        .a_row(a_row), .b_col(b_col),
        .c_row(c_row), .c_col(c_col),
        .c_out(c_out), .done(done));

    always #5 clk = ~clk;

    initial begin
        $display("===== SYSTOLIC 32x32 (1024 MACs) =====");
        rst=1; start=0; a_row=0; b_col=0; c_row=0; c_col=0;
        #20 rst=0;

        @(negedge clk); start=1;
        for (i=0; i<32; i=i+1) begin
            a_row = (i==0) ? 1 : 0;
            b_col = 1;
            @(negedge clk);
        end
        start=0;
        repeat(35) @(posedge clk);

        $display("acc[0][0] = %0d (expect 1)", uut.acc[0][0]);
        $display("acc[1][0] = %0d (expect 0)", uut.acc[1][0]);
        if (uut.acc[0][0]==1 && uut.acc[1][0]==0)
            $display("RESULT: PASS - 32x32 WORKS");
        else
            $display("RESULT: FAIL");
        $finish;
    end
endmodule
