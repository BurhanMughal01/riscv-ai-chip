module alu_formal;
    reg [7:0] a, b;
    reg [2:0] op;
    wire [7:0] y;
    wire zero;
    alu dut(.a(a), .b(b), .op(op), .y(y), .zero(zero));
    always @(*) begin
        case(op)
            3'd0: assert(y == a + b);
            3'd1: assert(y == a - b);
            3'd2: assert(y == (a & b));
            3'd3: assert(y == (a | b));
            3'd4: assert(y == ~a);
            3'd5: assert(y == a + 8'd1);
            3'd6: assert(y == b);
            default: assert(y == a);
        endcase
        assert(zero == (y == 8'd0));
    end
endmodule
