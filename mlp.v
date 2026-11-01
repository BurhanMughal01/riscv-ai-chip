module mlp(
    input signed [7:0] x1, x2,
    output reg signed [15:0] y
);
    reg signed [15:0] h1, h2;

    always @(*) begin
        h1 = 8'sd10*x1 - 8'sd10*x2 - 16'sd5;
        h2 = -8'sd10*x1 + 8'sd10*x2 - 16'sd5;

        if (h1 < 0) h1 = 0;
        if (h2 < 0) h2 = 0;

        y = h1 + h2;
    end
endmodule
