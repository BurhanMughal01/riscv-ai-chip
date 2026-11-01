module matmul4x4(
    input clk,
    input rst,
    input start,
    input signed [7:0] a_in, b_in,
    input [3:0] a_addr, b_addr, c_addr,
    input a_we, b_we,
    output signed [31:0] c_out,
    output done
);
    reg signed [7:0] A [0:15];
    reg signed [7:0] B [0:15];
    reg signed [31:0] C [0:15];

    reg [1:0] state;
    reg [1:0] k;
    reg done_reg;

    localparam IDLE    = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam DONE_ST = 2'd2;

    integer i, j, idx;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            k <= 0;
            done_reg <= 0;
            for (idx = 0; idx < 16; idx = idx + 1) begin
                A[idx] <= 0;
                B[idx] <= 0;
                C[idx] <= 0;
            end
        end else begin
            if (a_we) A[a_addr] <= a_in;
            if (b_we) B[b_addr] <= b_in;

            case (state)
                IDLE: begin
                    done_reg <= 0;
                    if (start) begin
                        state <= COMPUTE;
                        k <= 0;
                        for (idx = 0; idx < 16; idx = idx + 1)
                            C[idx] <= 0;
                    end
                end

                COMPUTE: begin
                    for (i = 0; i < 4; i = i + 1)
                        for (j = 0; j < 4; j = j + 1)
                            C[i*4 + j] <= C[i*4 + j] + A[i*4 + k] * B[k*4 + j];

                    if (k == 2'd3)
                        state <= DONE_ST;
                    else
                        k <= k + 1;
                end

                DONE_ST: begin
                    done_reg <= 1;
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end

    assign c_out = C[c_addr];
    assign done  = done_reg;
endmodule
