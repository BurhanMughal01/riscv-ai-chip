module soc_demo(
    input clk, rst,
    output [31:0] result,
    output halt
);
    reg [7:0] pc;
    reg [7:0] regs [0:1];
    reg [7:0] imem [0:7];
    reg signed [7:0] A [0:1];
    reg signed [7:0] B [0:1];
    reg signed [31:0] C0;
    reg acc_busy, acc_done;
    reg [1:0] acc_step;
    integer i;

    initial begin
        imem[0]=8'hA0; // START accelerator
        imem[1]=8'hB0; // WAIT for done
        imem[2]=8'hC0; // READ result to R1
        imem[3]=8'h80; // HALT
        for (i=4;i<8;i=i+1) imem[i]=0;
        A[0]=2; A[1]=3;
        B[0]=4; B[1]=5;
    end

    always @(posedge clk) begin
        if (rst) begin
            pc<=0; acc_busy<=0; acc_done<=0; acc_step<=0;
            regs[1]<=0; C0<=0;
        end else begin
            if (acc_busy) begin
                case (acc_step)
                    0: begin C0 <= A[0]*B[0]+A[1]*B[1]; acc_step<=1; end
                    1: begin acc_done<=1; acc_busy<=0; acc_step<=0; end
                endcase
            end

            case (imem[pc][7:4])
                4'hA: begin
                    if (!acc_busy && !acc_done) acc_busy<=1;
                    else pc<=pc+1;
                end
                4'hB: begin if (acc_done) pc<=pc+1; end
                4'hC: begin regs[1]<=C0[7:0]; pc<=pc+1; end
                4'h8: ;
                default: pc<=pc+1;
            endcase
        end
    end

    assign result = C0;
    assign halt = (imem[pc][7:4]==4'h8);
endmodule
