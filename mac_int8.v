module mac_int8(
    input clk,
    input rst,
    input signed [7:0] a,
    input signed [7:0] b,
    input valid,
    input clear,
    output reg signed [31:0] acc
);
    always @(posedge clk) begin
        if (rst || clear)
            acc <= 32'sd0;
        else if (valid)
            acc <= acc + (a * b);
    end
endmodule
