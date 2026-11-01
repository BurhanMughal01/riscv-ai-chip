module alu(
    input [7:0] a, b,
    input [2:0] op,
    output reg [7:0] y,
    output zero
);
    always @(*) begin
        case(op)
            3'd0: y = a + b;
            3'd1: y = a - b;
            3'd2: y = a & b;
            3'd3: y = a | b;
            3'd4: y = ~a;
            3'd5: y = a + 1;
            3'd6: y = b;
            default: y = a;
        endcase
    end
    assign zero = (y == 8'd0);
endmodule
