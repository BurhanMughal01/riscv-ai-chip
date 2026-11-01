module regfile(
    input clk, we,
    input [1:0] ra, rb, wa,
    input [7:0] wd,
    output [7:0] qa, qb
);
    reg [7:0] regs [0:3];
    initial begin regs[0]=0; regs[1]=0; regs[2]=0; regs[3]=0; end
    always @(posedge clk) if (we) regs[wa] <= wd;
    assign qa = regs[ra];
    assign qb = regs[rb];
endmodule
