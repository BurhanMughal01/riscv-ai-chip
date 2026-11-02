#!/bin/bash
cd ~/chip
PASS=0; FAIL=0

echo "=========================================="
echo "  FULL CHIP TEST SUITE"
echo "=========================================="

test_run() {
    local name=$1; shift
    echo ""
    echo "--- $name ---"
    if iverilog -o /tmp/t_sim "$@" 2>/dev/null && vvp /tmp/t_sim 2>&1 | grep -q "PASS"; then
        echo "  SIMULATION: PASS"
        PASS=$((PASS+1))
    else
        echo "  SIMULATION: FAIL"
        FAIL=$((FAIL+1))
    fi
}

synth_test() {
    local file=$1
    echo ""
    echo "--- SYNTH: $file ---"
    if timeout 300 yosys -p "read_verilog $file; synth; stat" 2>&1 | grep -q "0 problems"; then
        local cells=$(timeout 300 yosys -p "read_verilog $file; synth; stat" 2>&1 | grep -oE "[0-9]+ cells" | tail -1)
        echo "  SYNTHESIS: PASS ($cells)"
        PASS=$((PASS+1))
    else
        echo "  SYNTHESIS: FAIL"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "===== SIMULATIONS ====="
test_run "8-bit CPU" alu.v regfile.v pc.v imem.v control.v cpu.v cpu_tb.v
test_run "RV32I single-cycle" rv32i_cpu.v rv32i_tb.v
test_run "RV32I pipelined" rv32i_pipelined.v rv32i_pipelined_tb.v
test_run "MAC int8" mac_int8.v mac_int8_tb.v
test_run "MAC optimized" mac_optimized.v mac_optimized_tb.v
test_run "Matmul 4x4" matmul4x4.v matmul4x4_tb.v
test_run "Matmul 8x8" matmul8x8.v matmul8x8_tb.v
test_run "Systolic 4x4" systolic4x4.v systolic4x4_tb.v
test_run "Systolic 16x16" systolic16x16.v systolic16x16_tb.v
test_run "Systolic 32x32" systolic32x32.v systolic32x32_tb.v
test_run "MLP XOR" mlp.v mlp_tb.v
test_run "Digit classifier" digit_classifier.v digit_classifier_tb.v
test_run "SoC CPU+ACC" soc_demo.v soc_demo_tb.v
test_run "SoC Top" soc_top.v soc_top_tb.v rv32i_pipelined.v mac_optimized.v

echo ""
echo "===== SYNTHESIS ====="
synth_test alu.v
synth_test alu32.v
synth_test mac_optimized.v
synth_test rv32i_cpu.v
synth_test rv32i_pipelined.v
synth_test matmul4x4.v
synth_test digit_classifier.v

echo ""
echo "=========================================="
echo "  RESULT: $PASS PASS, $FAIL FAIL"
echo "=========================================="
