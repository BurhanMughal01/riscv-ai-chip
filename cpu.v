module cpu(
    input clk, rst,
    output [7:0] out_val,
    output halt
);
    wire [7:0] pc_val, instr, qa, qb, alu_b, alu_y;
    wire we, use_imm, out_en;
    wire [1:0] wa, ra, rb, out_sel;
    wire [2:0] alu_op;
    wire [7:0] imm;
    wire zero;

    pc PC(.clk(clk), .rst(rst), .en(~halt), .q(pc_val));
    imem IMEM(.addr(pc_val), .instr(instr));
    control CTL(.instr(instr), .halt(halt), .we(we), .wa(wa), .ra(ra), .rb(rb),
                .alu_op(alu_op), .imm(imm), .use_imm(use_imm),
                .out_en(out_en), .out_sel(out_sel));

    wire [1:0] ra_final = out_en ? out_sel : ra;
    wire we_final = out_en ? 1'b0 : we;

    regfile RF(.clk(clk), .we(we_final), .ra(ra_final), .rb(rb), .wa(wa),
               .wd(alu_y), .qa(qa), .qb(qb));

    assign alu_b = use_imm ? imm : qb;
    alu ALU(.a(qa), .b(alu_b), .op(alu_op), .y(alu_y), .zero(zero));

    assign out_val = qa;
endmodule
