module npu_32x32_top(
    input clk, rst, start,
    input signed [7:0] load_a, load_b,
    input [9:0] load_idx,
    input load_we,
    input signed [31:0] bias_val,
    output reg signed [31:0] result,
    output done
);
    reg signed [7:0] A [0:1023];
    reg signed [7:0] B [0:1023];
    reg signed [31:0] C [0:1023];
    reg [2:0] state;
    reg [5:0] cycle;
    reg done_reg;
    integer i, j;

    always @(posedge clk) begin
        if (rst) begin
            state <= 0; cycle <= 0; done_reg <= 0; result <= 0;
            for (i=0; i<1024; i=i+1) begin
                A[i] <= 0; B[i] <= 0; C[i] <= 0;
            end
        end else begin
            done_reg <= 0;
            if (load_we) begin
                A[load_idx] <= load_a;
                B[load_idx] <= load_b;
            end else begin
                case (state)
                    3'd0: if (start) begin
                        state <= 3'd1; cycle <= 0;
                        for (i=0; i<1024; i=i+1) C[i] <= 0;
                    end
                    3'd1: begin
                        for (i=0; i<32; i=i+1)
                            for (j=0; j<32; j=j+1)
                                C[i*32+j] <= C[i*32+j] +
                                    A[i*32+cycle] * B[cycle*32+j];
                        if (cycle == 31) begin
                            state <= 3'd2; cycle <= 0;
                        end else cycle <= cycle + 1;
                    end
                    3'd2: begin
                        for (i=0; i<1024; i=i+1)
                            C[i] <= C[i] + bias_val;
                        state <= 3'd3;
                    end
                    3'd3: begin
                        for (i=0; i<1024; i=i+1)
                            if (C[i] < 0) C[i] <= 0;
                        state <= 3'd4;
                    end
                    3'd4: begin
                        result <= C[0];
                        done_reg <= 1;
                        state <= 3'd0;
                    end
                endcase
            end
        end
    end
    assign done = done_reg;
endmodule
