module soc_top(
    input clk, rst,
    output signed [31:0] acc_out,
    output [31:0] cpu_x3,
    output [31:0] cpu_mem0
);
    wire [31:0] x3, x4, mem0, pc_out;
    wire [3:0] cyc;

    rv32i_pipelined cpu(
        .clk(clk), .rst(rst),
        .pc_out(pc_out), .cyc_out(cyc),
        .x3_out(x3), .x4_out(x4), .mem0_out(mem0)
    );

    mac_optimized acc(
        .clk(clk), .rst(rst),
        .a(x3[7:0]), .b(x4[7:0]),
        .valid(cyc[0]), .clear(rst),
        .acc(acc_out),
        .zero_skipped(), .mul_active()
    );

    assign cpu_x3 = x3;
    assign cpu_mem0 = mem0;
endmodule
