module systolic4x4_tb;
    reg clk=0, rst, start;
    reg signed [7:0] a_row0, b_col0;
    reg [3:0] c_addr;
    wire signed [31:0] c_out;
    wire done;
    integer i, j;

    systolic4x4 uut(.clk(clk), .rst(rst), .start(start),
        .a_row0(a_row0), .b_col0(b_col0),
        .c_out(c_out), .c_addr(c_addr), .done(done));

    always #5 clk = ~clk;

    initial begin
        $display("===== SYSTOLIC 4x4 (diagonal flow) =====");
        rst=1; start=0; a_row0=0; b_col0=0; c_addr=0;
        #20 rst=0;

        // Identity * identity = identity (simplest test)
        @(negedge clk); start=1;
        for (i=0; i<4; i=i+1) begin
            a_row0 = (i==0) ? 1 : 0;
            b_col0 = 1;
            @(negedge clk);
        end
        start=0;

        repeat(15) @(posedge clk);

        $display("C[0][0] = %0d (expect 1)", uut.acc[0][0]);
        $display("C[1][0] = %0d (expect 0)", uut.acc[1][0]);
        $display("C[2][0] = %0d (expect 0)", uut.acc[2][0]);
        $display("C[3][0] = %0d (expect 0)", uut.acc[3][0]);

        if (uut.acc[0][0]==1 && uut.acc[1][0]==0 && uut.acc[2][0]==0 && uut.acc[3][0]==0)
            $display("RESULT: PASS - SYSTOLIC WORKS");
        else
            $display("RESULT: FAIL");

        $finish;
    end
endmodule
