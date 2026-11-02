module npu_32x32_tb;
    reg clk=0, rst, start, load_we;
    reg signed [7:0] load_a, load_b;
    reg [9:0] load_idx;
    reg signed [31:0] bias_val;
    wire signed [31:0] result;
    wire done;
    integer i;

    npu_32x32_top uut(.clk(clk), .rst(rst), .start(start),
        .load_a(load_a), .load_b(load_b), .load_idx(load_idx),
        .load_we(load_we), .bias_val(bias_val),
        .result(result), .done(done));

    always #5 clk = ~clk;

    initial begin
        $display("===== NPU 32x32 =====");
        rst=1; start=0; load_we=0; load_idx=0;
        load_a=0; load_b=0; bias_val=0;
        #20 rst=0;

        // Loop 1: A[0..31]=1, B[0]=1
        for (i=0; i<32; i=i+1) begin
            @(negedge clk);
            load_idx = i; load_a = 1; load_b = (i==0) ? 1 : 0; load_we = 1;
        end
        // Loop 2: B[32..992]=1 (A ko chhoro, i=1 se shuru)
        for (i=1; i<32; i=i+1) begin
            @(negedge clk);
            load_idx = i*32; load_a = 0; load_b = 1; load_we = 1;
        end
        @(negedge clk); load_we = 0;

        bias_val = 32'sd5;
        @(negedge clk); start = 1;
        @(negedge clk); start = 0;

        repeat(60) @(posedge clk);

        $display("C[0] = %0d (expect 32 + 5 = 37)", uut.C[0]);
        if (uut.C[0] == 32'd37)
            $display("RESULT: PASS - 32x32 NPU works");
        else
            $display("RESULT: FAIL - got %0d", uut.C[0]);
        $finish;
    end
endmodule
