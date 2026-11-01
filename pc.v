module pc(
    input clk, rst, en,
    output reg [7:0] q
);
    always @(posedge clk or posedge rst)
        if (rst) q <= 0;
        else if (en) q <= q + 1;
endmodule
