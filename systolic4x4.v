module systolic4x4(
    input clk, rst, start,
    input signed [7:0] a_row0, b_col0,
    output signed [31:0] c_out,
    input [3:0] c_addr,
    output done
);
    reg signed [7:0] a_reg [0:3][0:3];
    reg signed [7:0] b_reg [0:3][0:3];
    reg signed [31:0] acc [0:3][0:3];
    reg [3:0] cycle;
    reg done_reg;
    integer i, j;

    always @(posedge clk) begin
        if (rst) begin
            cycle <= 0; done_reg <= 0;
            for (i=0; i<4; i=i+1)
                for (j=0; j<4; j=j+1) begin
                    a_reg[i][j] <= 0;
                    b_reg[i][j] <= 0;
                    acc[i][j] <= 0;
                end
        end else if (start && cycle < 10) begin
            // Skew input: diagonal wavefront
            for (i=0; i<4; i=i+1)
                a_reg[i][0] <= (cycle == i) ? a_row0 : 0;
            for (j=0; j<4; j=j+1)
                b_reg[0][j] <= (cycle == j) ? b_col0 : 0;

            // Shift a right, b down
            for (i=0; i<4; i=i+1)
                for (j=1; j<4; j=j+1)
                    a_reg[i][j] <= a_reg[i][j-1];
            for (i=1; i<4; i=i+1)
                for (j=0; j<4; j=j+1)
                    b_reg[i][j] <= b_reg[i-1][j];

            // MAC at each cell
            for (i=0; i<4; i=i+1)
                for (j=0; j<4; j=j+1)
                    acc[i][j] <= acc[i][j] + a_reg[i][j] * b_reg[i][j];

            cycle <= cycle + 1;
            if (cycle == 9) done_reg <= 1;
        end else if (!start) begin
            cycle <= 0; done_reg <= 0;
        end
    end

    assign c_out = acc[c_addr[3:2]][c_addr[1:0]];
    assign done = done_reg;
endmodule
