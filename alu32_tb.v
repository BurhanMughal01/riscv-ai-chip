module alu32_tb;
    reg  [31:0] a, b;
    reg  [3:0]  op;
    wire [31:0] y;
    wire        zero;

    alu32 uut(.a(a), .b(b), .op(op), .y(y), .zero(zero));

    initial begin
        $display("===== ALU32 TEST =====");

        a = 32'd100; b = 32'd50;
        op = 4'd0; #1; $display("ADD  100 + 50 = %0d", y);
        op = 4'd1; #1; $display("SUB  100 - 50 = %0d", y);
        op = 4'd2; #1; $display("AND  100 & 50 = %0d", y);
        op = 4'd3; #1; $display("OR   100 | 50 = %0d", y);
        op = 4'd4; #1; $display("XOR  100 ^ 50 = %0d", y);

        a = 32'd5; b = 32'd3;
        op = 4'd5; #1; $display("SLL  5 << 3   = %0d", y);
        op = 4'd6; #1; $display("SRL  5 >> 3   = %0d", y);

        a = 32'd10; b = 32'd20;
        op = 4'd8; #1; $display("SLT  (10<20)  = %0d", y);

        a = 32'd10; b = 32'd10;
        op = 4'd1; #1;
        $display("ZERO flag (10-10 should be 1): %b", zero);

        $display("===== DONE =====");
        $finish;
    end
endmodule
