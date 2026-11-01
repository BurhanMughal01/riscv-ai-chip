module rv32i_cpu(
    input clk,
    input rst,
    output [31:0] pc_out,
    output [31:0] instr_out
);
    reg [31:0] pc;
    wire [31:0] instr;

    reg [31:0] imem [0:15];
    reg [31:0] regs [0:31];
    reg [31:0] dmem [0:63];

    assign instr = imem[pc[5:2]];

    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    wire [31:0] imm;

    assign imm = (opcode == 7'b0100011) ? imm_s :
                 (opcode == 7'b1100011) ? imm_b :
                 (opcode == 7'b1101111) ? imm_j : imm_i;

    wire [31:0] rs1_val = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    wire [31:0] rs2_val = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

    wire ctrl_R   = (opcode == 7'b0110011);
    wire ctrl_I   = (opcode == 7'b0010011);
    wire ctrl_LW  = (opcode == 7'b0000011);
    wire ctrl_SW  = (opcode == 7'b0100011);
    wire ctrl_BR  = (opcode == 7'b1100011);
    wire ctrl_JAL = (opcode == 7'b1101111);

    wire regwrite    = ctrl_R | ctrl_I | ctrl_LW | ctrl_JAL;
    wire memwrite    = ctrl_SW;
    wire memread     = ctrl_LW;
    wire alu_src_imm = ctrl_I | ctrl_LW | ctrl_SW;
    wire branch      = ctrl_BR;
    wire jump        = ctrl_JAL;

    reg [3:0] alu_op;
    always @(*) begin
        alu_op = 4'd0;
        if (ctrl_R) begin
            case (funct3)
                3'b000: alu_op = funct7[5] ? 4'd1 : 4'd0;
                3'b111: alu_op = 4'd2;
                3'b110: alu_op = 4'd3;
                3'b100: alu_op = 4'd4;
                3'b010: alu_op = 4'd7;
            endcase
        end else if (ctrl_I) begin
            case (funct3)
                3'b000: alu_op = 4'd0;
                3'b111: alu_op = 4'd2;
                3'b110: alu_op = 4'd3;
                3'b100: alu_op = 4'd4;
            endcase
        end else if (ctrl_BR) begin
            alu_op = 4'd1;
        end
    end

    wire [31:0] alu_a = rs1_val;
    wire [31:0] alu_b = alu_src_imm ? imm : rs2_val;

    reg [31:0] alu_y;
    always @(*) begin
        case (alu_op)
            4'd0: alu_y = alu_a + alu_b;
            4'd1: alu_y = alu_a - alu_b;
            4'd2: alu_y = alu_a & alu_b;
            4'd3: alu_y = alu_a | alu_b;
            4'd4: alu_y = alu_a ^ alu_b;
            4'd7: alu_y = ($signed(alu_a) < $signed(alu_b)) ? 32'd1 : 32'd0;
            default: alu_y = alu_a;
        endcase
    end

    wire [31:0] mem_data = dmem[alu_y[7:2]];
    wire [31:0] pc_plus4 = pc + 4;
    wire [31:0] wb_data = memread ? mem_data : (jump ? pc_plus4 : alu_y);

    wire alu_zero = (alu_y == 32'd0);
    wire branch_taken = branch && (
        (funct3 == 3'b000 && alu_zero) ||
        (funct3 == 3'b001 && !alu_zero)
    );
    wire [31:0] pc_next = (jump || branch_taken) ? (pc + imm) : pc_plus4;

    integer i;
    initial begin
        pc = 0;
        for (i = 0; i < 32; i = i + 1) regs[i] = 0;
        for (i = 0; i < 64; i = i + 1) dmem[i] = 0;
        imem[0] = 32'h00500093;
        imem[1] = 32'h00300113;
        imem[2] = 32'h002081B3;
        imem[3] = 32'h00302023;
        imem[4] = 32'h00002203;
        imem[5] = 32'h00000063;
        for (i = 6; i < 16; i = i + 1) imem[i] = 32'h00000013;
    end

    always @(posedge clk) begin
        if (rst) pc <= 0;
        else     pc <= pc_next;
    end

    always @(posedge clk) begin
        if (regwrite && rd != 5'd0)
            regs[rd] <= wb_data;
    end

    always @(posedge clk) begin
        if (memwrite)
            dmem[alu_y[7:2]] <= rs2_val;
    end

    assign pc_out = pc;
    assign instr_out = instr;
endmodule
