module regfile32_tb;
    reg         clk, we;
    reg  [4:0]  ra1, ra2, wa;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;
    integer i;

    regfile32 uut(.clk(clk), .we(we),
                  .ra1(ra1), .ra2(ra2), .wa(wa), .wd(wd),
                  .rd1(rd1), .rd2(rd2));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("===== REGFILE32 TEST =====");

        // Write values to regs 1-5
        we = 1;
        for (i = 1; i <= 5; i = i + 1) begin
            wa = i; wd = i * 100;
            @(posedge clk); #1;
        end
        we = 0;

        // Read them back
        $display("Read regs 1-5:");
        for (i = 1; i <= 5; i = i + 1) begin
            ra1 = i; #1;
            $display("  x%0d = %0d", i, rd1);
        end

        // Test x0 always 0
        wa = 0; wd = 999; we = 1; @(posedge clk); #1; we = 0;
        ra1 = 0; #1;
        $display("x0 (should be 0, not 999): %0d", rd1);

        // Test two read ports simultaneously
        ra1 = 2; ra2 = 4; #1;
        $display("Two ports: x2=%0d, x4=%0d", rd1, rd2);

        $display("===== DONE =====");
        $finish;
    end
endmodule
