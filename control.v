module control(
    input [7:0] instr,
    output reg halt, we,
    output reg [1:0] wa, ra, rb, out_sel,
    output reg [2:0] alu_op,
    output reg [7:0] imm,
    output reg use_imm, out_en
);
    wire [3:0] op = instr[7:4];
    wire [3:0] arg = instr[3:0];
    always @(*) begin
        halt=0; we=0; wa=0; ra=0; rb=0;
        alu_op=0; imm=0; use_imm=0; out_en=0; out_sel=0;
        case(op)
            4'h1: begin we=1; wa=0; imm={4'b0,arg}; use_imm=1; alu_op=3'd6; end
            4'h2: begin we=1; wa=1; imm={4'b0,arg}; use_imm=1; alu_op=3'd6; end
            4'h3: begin we=1; wa=2; imm={4'b0,arg}; use_imm=1; alu_op=3'd6; end
            4'h4: begin we=1; wa=3; imm={4'b0,arg}; use_imm=1; alu_op=3'd6; end
            4'h5: begin we=1; wa=arg[3:2]; ra=arg[3:2]; rb=arg[1:0]; alu_op=3'd0; end
            4'h6: begin out_en=1; out_sel=arg[1:0]; end
            4'h7: begin we=1; wa=arg[3:2]; ra=arg[3:2]; rb=arg[1:0]; alu_op=3'd1; end
            4'h8: begin halt=1; end
        endcase
    end
endmodule
