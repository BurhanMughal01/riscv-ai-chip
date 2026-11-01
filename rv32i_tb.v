module rv32i_tb;
    reg clk, rst;
    wire [31:0] pc_out, instr_out;

    rv32i_cpu uut(.clk(clk), .rst(rst),
                  .pc_out(pc_out), .instr_out(instr_out));

    initial clk = 0;
    always #5 clk = ~clk;

    integer cycle_count;
    initial cycle_count = 0;

    always @(posedge clk) begin
        if (!rst && cycle_count < 10) begin
            $display("cycle %0d: pc=0x%0h instr=0x%0h | x1=%0d x2=%0d x3=%0d",
                     cycle_count, pc_out, instr_out,
                     uut.regs[1], uut.regs[2], uut.regs[3]);
        end
        cycle_count = cycle_count + 1;
    end

    initial begin
        $dumpfile("rv32i.vcd");
        $dumpvars(0, rv32i_tb);

        rst = 1;
        #20 rst = 0;

        repeat (20) @(posedge clk);

        $display("");
        $display("========================================");
        $display("  RV32I SINGLE-CYCLE CPU TEST");
        $display("  Program: 5 + 3 -> store -> load");
        $display("========================================");
        $display("  x1 (expect 5) = %0d", uut.regs[1]);
        $display("  x2 (expect 3) = %0d", uut.regs[2]);
        $display("  x3 (expect 8) = %0d", uut.regs[3]);
        $display("  x4 (expect 8) = %0d", uut.regs[4]);
        $display("  mem[0] (expect 8) = %0d", uut.dmem[0]);
        $display("  pc = %0d", pc_out);
        $display("========================================");

        if (uut.regs[1] == 32'd5 && uut.regs[2] == 32'd3 &&
            uut.regs[3] == 32'd8 && uut.regs[4] == 32'd8 &&
            uut.dmem[0] == 32'd8)
            $display("  RESULT: PASS - RV32I CPU WORKS!");
        else
            $display("  RESULT: FAIL");
        $display("========================================");

        $finish;
    end
endmodule
