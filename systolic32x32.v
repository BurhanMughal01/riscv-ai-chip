module systolic32x32(
    input clk, rst, start,
    input signed [7:0] a_row, b_col,
    input [4:0] c_row, c_col,
    output signed [31:0] c_out,
    output done
);
    reg signed [7:0] A [0:31][0:31];
    reg signed [7:0] B [0:31][0:31];
    reg signed [31:0] acc [0:31][0:31];
    reg [5:0] cycle;
    reg done_reg;
    integer i, j;

    always @(posedge clk) begin
        if (rst) begin
            cycle <= 0; done_reg <= 0;
            for (i=0; i<32; i=i+1)
                for (j=0; j<32; j=j+1) begin
                    A[i][j] <= 0; B[i][j] <= 0; acc[i][j] <= 0;
                end
        end else if (start && cycle < 65) begin
            for (i=0; i<32; i=i+1)
                A[i][0] <= (cycle == i) ? a_row : 0;
            for (j=0; j<32; j=j+1)
                B[0][j] <= (cycle == j) ? b_col : 0;
            for (i=0; i<32; i=i+1)
                for (j=1; j<32; j=j+1) A[i][j] <= A[i][j-1];
            for (i=1; i<32; i=i+1)
                for (j=0; j<32; j=j+1) B[i][j] <= B[i-1][j];
            for (i=0; i<32; i=i+1)
                for (j=0; j<32; j=j+1) acc[i][j] <= acc[i][j] + A[i][j] * B[i][j];
            cycle <= cycle + 1;
            if (cycle == 64) done_reg <= 1;
        end else if (!start) begin
            cycle <= 0; done_reg <= 0;
        end
    end
    assign c_out = acc[c_row][c_col];
    assign done = done_reg;
endmodule
