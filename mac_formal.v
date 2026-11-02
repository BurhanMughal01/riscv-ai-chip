module mac_formal;
    reg clk, rst, valid, clear;
    reg signed [7:0] a, b;
    wire signed [31:0] acc;
    mac_int8 dut(.clk(clk), .rst(rst), .a(a), .b(b),
        .valid(valid), .clear(clear), .acc(acc));
    reg signed [31:0] prev_acc = 0;
    reg first_cycle = 1;
    always @(posedge clk) begin
        if (!first_cycle && !rst && !clear && valid) begin
            assert(acc == prev_acc + (a * b));
        end
        prev_acc <= acc;
        first_cycle <= 0;
    end
endmodule
