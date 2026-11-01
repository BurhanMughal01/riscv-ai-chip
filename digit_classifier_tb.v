module digit_classifier_tb;
    reg signed [3:0] p0, p1, p2, p3;
    wire signed [15:0] score;
    digit_classifier uut(.p0(p0),.p1(p1),.p2(p2),.p3(p3),.score_1(score));

    initial begin
        $display("===== DIGIT CLASSIFIER =====");
        // Digit "1" — vertical line: middle pixels ON
        p0=0; p1=8; p2=0; p3=8; #1;
        $display("Pattern [0,8,0,8]: score=%0d -> %s",
            score, (score > 0) ? "DIGIT 1" : "DIGIT 0");

        // Digit "0" — horizontal/dense: top pixels ON
        p0=8; p1=8; p2=0; p3=0; #1;
        $display("Pattern [8,8,0,0]: score=%0d -> %s",
            score, (score > 0) ? "DIGIT 1" : "DIGIT 0");

        // Digit "0" — dense all
        p0=8; p1=8; p2=8; p3=8; #1;
        $display("Pattern [8,8,8,8]: score=%0d -> %s",
            score, (score > 0) ? "DIGIT 1" : "DIGIT 0");

        $finish;
    end
endmodule
