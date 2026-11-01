module mlp_tb;
    reg signed [7:0] x1, x2;
    wire signed [15:0] y;
    mlp uut(.x1(x1), .x2(x2), .y(y));

    initial begin
        $display("===== XOR MLP TEST =====");

        x1=0; x2=0; #1;
        $display("0 XOR 0 = %0d (expect 0)", y > 0);

        x1=0; x2=1; #1;
        $display("0 XOR 1 = %0d (expect 1)", y > 0);

        x1=1; x2=0; #1;
        $display("1 XOR 0 = %0d (expect 1)", y > 0);

        x1=1; x2=1; #1;
        $display("1 XOR 1 = %0d (expect 0)", y > 0);

        $display("===== DONE =====");
        $finish;
    end
endmodule
