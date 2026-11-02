module tiny_npu_tb;
    reg clk = 0, rst_n;
    reg [7:0] din;
    reg din_ce;
    wire [7:0] dout;
    wire dout_ce;
    integer i;

    tiny_npu dut(.clk(clk), .rst_n(rst_n), .din(din), .din_ce(din_ce),
                 .dout(dout), .dout_ce(dout_ce));
    always #5 clk = ~clk;

    reg [7:0] A[0:15], B[0:15];

    initial begin
        $display("=== TINY NPU (Tiny Tapeout ready) ===");
        A[0]=1; A[1]=2; A[2]=0; A[3]=0;
        A[4]=3; A[5]=4; A[6]=0; A[7]=0;
        A[8]=0; A[9]=0; A[10]=0; A[11]=0;
        A[12]=0; A[13]=0; A[14]=0; A[15]=0;
        B[0]=5; B[4]=7; B[8]=0; B[12]=0;
        B[1]=6; B[5]=8; B[9]=0; B[13]=0;
        B[2]=0; B[6]=0; B[10]=0; B[14]=0;
        B[3]=0; B[7]=0; B[11]=0; B[15]=0;

        rst_n = 0; din = 0; din_ce = 0;
        #20 rst_n = 1;

        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk); din = A[i]; din_ce = 1;
        end
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk); din = B[i]; din_ce = 1;
        end
        @(negedge clk); din_ce = 0;

        repeat(50) @(posedge clk);

        $display("C[0][0]=%0d (expect 19)", dut.C[0]);
        $display("C[0][1]=%0d (expect 22)", dut.C[1]);
        $display("C[1][0]=%0d (expect 43)", dut.C[4]);
        $display("C[1][1]=%0d (expect 50)", dut.C[5]);

        if (dut.C[0]==19 && dut.C[1]==22 && dut.C[4]==43 && dut.C[5]==50)
            $display("RESULT: PASS - Tiny NPU ready for silicon");
        else
            $display("RESULT: FAIL");
        $finish;
    end
endmodule
