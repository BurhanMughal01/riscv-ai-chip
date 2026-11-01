module mac_optimized(
    input clk, rst,
    input signed [7:0] a, b,
    input valid, clear,
    output reg signed [31:0] acc,
    output reg zero_skipped,
    output reg mul_active
);
    reg signed [7:0] a_s1, b_s1;
    reg valid_s1;
    reg signed [15:0] prod_s2;
    reg valid_s2;

    always @(posedge clk) begin
        if (rst || clear) begin
            acc <= 0;
            a_s1 <= 0; b_s1 <= 0; valid_s1 <= 0;
            prod_s2 <= 0; valid_s2 <= 0;
            zero_skipped <= 0;
            mul_active <= 0;
        end else begin
            // Stage 1: latch
            a_s1 <= a; b_s1 <= b;
            valid_s1 <= valid;
            zero_skipped <= valid && (a == 0 || b == 0);

            // Stage 2: multiply (skip if zero)
            if (valid_s1 && a_s1 != 0 && b_s1 != 0) begin
                prod_s2 <= a_s1 * b_s1;
                valid_s2 <= 1;
                mul_active <= 1;
            end else begin
                prod_s2 <= 0;
                valid_s2 <= 0;
                mul_active <= 0;
            end

            // Stage 3: accumulate
            if (valid_s2) acc <= acc + prod_s2;
        end
    end
endmodule
