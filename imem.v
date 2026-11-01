module imem(
    input [7:0] addr,
    output reg [7:0] instr
);
    always @(*) begin
        case(addr[3:0])
            4'd0: instr = 8'h15;
            4'd1: instr = 8'h23;
            4'd2: instr = 8'h51;
            4'd3: instr = 8'h60;
            4'd4: instr = 8'h80;
            default: instr = 8'h00;
        endcase
    end
endmodule
