module rv32i_pipelined(
    input clk, rst,
    output [31:0] pc_out,
    output [3:0] cyc_out,
    output [31:0] x3_out,
    output [31:0] x4_out,
    output [31:0] mem0_out
);
    reg [31:0] pc, imem [0:31], regs [0:31], dmem [0:63];
    reg [3:0] cyc;
    integer i;

    reg [31:0] if_id;
    reg [31:0] id_ex_a, id_ex_b, id_ex_imm;
    reg [4:0] id_ex_rd;
    reg [3:0] id_ex_aluop;
    reg id_ex_rw, id_ex_mr, id_ex_mw, id_ex_ui;

    reg [31:0] ex_mem_y, ex_mem_b;
    reg [4:0] ex_mem_rd;
    reg ex_mem_rw, ex_mem_mr, ex_mem_mw;

    reg [31:0] mem_wb_d;
    reg [4:0] mem_wb_rd;
    reg mem_wb_rw;

    assign pc_out = pc;
    assign cyc_out = cyc;
    assign x3_out = regs[3];
    assign x4_out = regs[4];
    assign mem0_out = dmem[0];

    wire [31:0] instr = imem[pc[6:2]];

    always @(posedge clk) begin
        if (rst) begin pc<=0; cyc<=0; if_id<=32'h13; end
        else begin pc<=pc+4; if_id<=instr; if (cyc<15) cyc<=cyc+1; end
    end

    wire [6:0] opc = if_id[6:0];
    wire [4:0] rd_ = if_id[11:7];
    wire [2:0] f3 = if_id[14:12];
    wire [4:0] rs1 = if_id[19:15];
    wire [4:0] rs2 = if_id[24:20];
    wire [6:0] f7 = if_id[31:25];

    wire [31:0] immI = {{20{if_id[31]}}, if_id[31:20]};
    wire [31:0] immS = {{20{if_id[31]}}, if_id[31:25], if_id[11:7]};
    wire [31:0] imm = (opc == 7'b0100011) ? immS : immI;

    wire is_R  = (opc == 7'b0110011);
    wire is_I  = (opc == 7'b0010011);
    wire is_LW = (opc == 7'b0000011);
    wire is_SW = (opc == 7'b0100011);

    wire c_rw = is_R | is_I | is_LW;
    wire c_mr = is_LW;
    wire c_mw = is_SW;
    wire c_ui = is_I | is_LW | is_SW;

    reg [3:0] aluop;
    always @(*) begin
        aluop = 0;
        if (is_R) begin
            case(f3)
                3'b000: aluop = f7[5] ? 4'd1 : 4'd0;
                3'b111: aluop = 4'd2;
                3'b110: aluop = 4'd3;
                3'b100: aluop = 4'd4;
            endcase
        end else if (is_I) begin
            case(f3)
                3'b000: aluop = 4'd0;
                3'b111: aluop = 4'd2;
                3'b110: aluop = 4'd3;
                3'b100: aluop = 4'd4;
            endcase
        end
    end

    wire [31:0] rv1 = (rs1==0) ? 0 :
        ((mem_wb_rw && mem_wb_rd==rs1) ? mem_wb_d :
         (ex_mem_rw && ex_mem_rd==rs1 && !ex_mem_mr) ? ex_mem_y : regs[rs1]);
    wire [31:0] rv2 = (rs2==0) ? 0 :
        ((mem_wb_rw && mem_wb_rd==rs2) ? mem_wb_d :
         (ex_mem_rw && ex_mem_rd==rs2 && !ex_mem_mr) ? ex_mem_y : regs[rs2]);

    always @(posedge clk) begin
        id_ex_a <= rv1; id_ex_b <= rv2; id_ex_imm <= imm;
        id_ex_rd <= rd_; id_ex_aluop <= aluop;
        id_ex_rw <= c_rw; id_ex_mr <= c_mr; id_ex_mw <= c_mw; id_ex_ui <= c_ui;
    end

    wire [31:0] eb = id_ex_ui ? id_ex_imm : id_ex_b;
    reg [31:0] ey;
    always @(*) begin
        case(id_ex_aluop)
            4'd0: ey = id_ex_a + eb;
            4'd1: ey = id_ex_a - eb;
            4'd2: ey = id_ex_a & eb;
            4'd3: ey = id_ex_a | eb;
            4'd4: ey = id_ex_a ^ eb;
            default: ey = id_ex_a;
        endcase
    end

    always @(posedge clk) begin
        ex_mem_y <= ey;
        ex_mem_b <= id_ex_b;
        ex_mem_rd <= id_ex_rd;
        ex_mem_rw <= id_ex_rw;
        ex_mem_mr <= id_ex_mr;
        ex_mem_mw <= id_ex_mw;
    end

    always @(posedge clk) begin
        if (ex_mem_mw) dmem[ex_mem_y[7:2]] <= ex_mem_b;
        mem_wb_d <= ex_mem_mr ? dmem[ex_mem_y[7:2]] : ex_mem_y;
        mem_wb_rd <= ex_mem_rd;
        mem_wb_rw <= ex_mem_rw;
    end

    always @(posedge clk) begin
        if (mem_wb_rw && mem_wb_rd != 0) regs[mem_wb_rd] <= mem_wb_d;
    end

    initial begin
        for (i=0; i<32; i=i+1) regs[i]=0;
        for (i=0; i<64; i=i+1) dmem[i]=0;
        for (i=0; i<32; i=i+1) imem[i]=32'h13;
        imem[0] = 32'h00500093;
        imem[1] = 32'h00300113;
        imem[2] = 32'h00000013;
        imem[3] = 32'h002081B3;
        imem[4] = 32'h00000013;
        imem[5] = 32'h00302023;
        imem[6] = 32'h00000013;
        imem[7] = 32'h00000013;
        imem[8] = 32'h00002203;
    end
endmodule
