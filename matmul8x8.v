module matmul8x8(
    input clk, rst, start,
    input signed [7:0] a_in, b_in,
    input [5:0] a_addr, b_addr, c_addr,
    input a_we, b_we,
    output signed [31:0] c_out,
    output done
);
    reg signed [7:0] A [0:63];
    reg signed [7:0] B [0:63];
    reg signed [31:0] C [0:63];
    reg [2:0] state;
    reg [3:0] k;
    reg done_reg;
    integer i, j, idx;

    always @(posedge clk) begin
        if (rst) begin
            state<=0; k<=0; done_reg<=0;
            for (idx=0; idx<64; idx=idx+1) begin A[idx]<=0; B[idx]<=0; C[idx]<=0; end
        end else begin
            if (a_we) A[a_addr] <= a_in;
            if (b_we) B[b_addr] <= b_in;
            case(state)
                0: if (start) begin
                    state<=1; k<=0;
                    for (idx=0; idx<64; idx=idx+1) C[idx]<=0;
                end
                1: begin
                    for (i=0; i<8; i=i+1)
                        for (j=0; j<8; j=j+1)
                            C[i*8+j] <= C[i*8+j] + A[i*8+k] * B[k*8+j];
                    if (k==7) state<=2;
                    else k<=k+1;
                end
                2: begin
                    done_reg<=1;
                    if (!start) state<=0;
                end
            endcase
        end
    end
    assign c_out = C[c_addr];
    assign done = done_reg;
endmodule
