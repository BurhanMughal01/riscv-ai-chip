module digit_classifier(
    input signed [3:0] p0, p1, p2, p3,
    output reg signed [15:0] score_1
);
    reg signed [15:0] h0, h1, h2, h3;
    always @(*) begin
        h0 = p0*2 + p1*3 + p2*2 + p3*3 - 8;
        h1 = p0*(-2) + p1*3 + p2*(-2) + p3*3 - 4;
        h2 = p0*1 + p1*1 + p2*1 + p3*1 - 6;
        h3 = p0*2 + p1*(-1) + p2*2 + p3*(-1) + 2;
        if (h0 < 0) h0 = 0;
        if (h1 < 0) h1 = 0;
        if (h2 < 0) h2 = 0;
        if (h3 < 0) h3 = 0;
        score_1 = h0*3 + h1*(-2) + h2*2 + h3*4 - 10;
    end
endmodule
