module mac_int8_tb;
    reg clk, rst, clear, valid;
    reg signed [7:0] a, b;
    wire signed [31:0] acc;

    mac_int8 uut(.clk(clk), .rst(rst), .clear(clear),
                 .a(a), .b(b), .valid(valid), .acc(acc));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("===== INT8 MAC UNIT TEST =====");
        rst = 1; clear = 0; valid = 0;
        a = 0; b = 0;
        #20 rst = 0;

        // Test 1: 5 * 3
        valid = 1; a = 8'sd5; b = 8'sd3;
        @(posedge clk); #1;
        $display("After 5*3:        acc = %0d  (expect 15)", acc);

        // Test 2: + 4 * 2
        a = 8'sd4; b = 8'sd2;
        @(posedge clk); #1;
        $display("After + 4*2:      acc = %0d  (expect 23)", acc);

        // Test 3: + 2 * 7
        a = 8'sd2; b = 8'sd7;
        @(posedge clk); #1;
        $display("After + 2*7:      acc = %0d  (expect 37)", acc);

        // Test 4: Negative: -3 * 5
        a = -8'sd3; b = 8'sd5;
        @(posedge clk); #1;
        $display("After + (-3)*5:   acc = %0d  (expect 22)", acc);

        // Test 5: Clear
        clear = 1;
        @(posedge clk); #1;
        clear = 0;
        $display("After clear:      acc = %0d  (expect 0)", acc);

        // Test 6: Invalid input (should not accumulate)
        valid = 0; a = 8'sd100; b = 8'sd100;
        @(posedge clk); #1;
        $display("After invalid:    acc = %0d  (expect 0)", acc);

        $display("===== DONE =====");
        $finish;
    end
endmodule
