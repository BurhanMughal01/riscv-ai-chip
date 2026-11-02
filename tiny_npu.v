module tiny_npu(
    input clk, rst_n,
    input [7:0] din,
    input din_ce,
    output reg [7:0] dout,
    output reg dout_ce
);
    reg [7:0] A[0:15], B[0:15], C[0:15];
    reg [5:0] cyc;

    always @(posedge clk) begin
        if (!rst_n) cyc <= 0;
        else if (cyc < 6'd63) cyc <= cyc + 1;
    end

    always @(posedge clk) begin
        if (din_ce && cyc < 16) A[cyc[3:0]] <= din;
        else if (din_ce && cyc >= 16 && cyc < 32) B[cyc[3:0]] <= din;
    end

    function [15:0] mac4;
        input [7:0] a0, a1, a2, a3, b0, b1, b2, b3;
        mac4 = a0*b0 + a1*b1 + a2*b2 + a3*b3;
    endfunction

    wire [15:0] mac_out = mac4(
        A[{cyc[3:2], 2'b00}], A[{cyc[3:2], 2'b01}],
        A[{cyc[3:2], 2'b10}], A[{cyc[3:2], 2'b11}],
        B[{2'b00, cyc[1:0]}], B[{2'b01, cyc[1:0]}],
        B[{2'b10, cyc[1:0]}], B[{2'b11, cyc[1:0]}]
    );

    always @(posedge clk) begin
        if (cyc >= 32 && cyc < 48) C[cyc[3:0]] <= mac_out[7:0];
    end

    always @(posedge clk) begin
        dout_ce <= (cyc >= 48);
        dout <= C[cyc[3:0]];
    end
endmodule
