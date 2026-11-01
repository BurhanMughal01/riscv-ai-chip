module mac_optimized_tb;
    reg clk=0, rst, valid, clear;
    reg signed [7:0] a, b;
    wire signed [31:0] acc;
    wire zero_skipped, mul_active;

    mac_optimized uut(.clk(clk), .rst(rst), .a(a), .b(b),
        .valid(valid), .clear(clear), .acc(acc),
        .zero_skipped(zero_skipped), .mul_active(mul_active));

    always #5 clk = ~clk;

    initial begin
        $display("===== OPTIMIZED MAC =====");
        rst=1; valid=0; clear=0; a=0; b=0;
        #20 rst=0;

        // Non-zero: 5*3
        @(negedge clk); a=5; b=3; valid=1;
        @(negedge clk); valid=0;
        repeat(3) @(posedge clk);
        $display("5*3: acc=%0d skipped=%b active=%b (expect 15,0,1)",
                 acc, zero_skipped, mul_active);

        // Zero input: 0*7 = skip
        @(negedge clk); a=0; b=7; valid=1;
        @(negedge clk); valid=0;
        repeat(3) @(posedge clk);
        $display("0*7: acc=%0d skipped=%b active=%b (expect 15,1,0)",
                 acc, zero_skipped, mul_active);

        // Non-zero: 4*2
        @(negedge clk); a=4; b=2; valid=1;
        @(negedge clk); valid=0;
        repeat(3) @(posedge clk);
        $display("4*2: acc=%0d skipped=%b active=%b (expect 23,0,1)",
                 acc, zero_skipped, mul_active);

        // Back-to-back (pipelined) — 3 cycles mein 3 MACs
        @(negedge clk); a=1; b=10; valid=1;
        @(negedge clk); a=2; b=10;
        @(negedge clk); a=3; b=10;
        @(negedge clk); valid=0;
        repeat(4) @(posedge clk);
        $display("Pipelined 3 MACs: acc=%0d (expect 83)", acc);

        if (acc == 83)
            $display("RESULT: PASS - OPTIMIZED MAC WORKS");
        else
            $display("RESULT: FAIL");

        $finish;
    end
endmodule
