#!/bin/bash
cd ~/chip
yosys -p "read_verilog mac_int8.v; proc; memory; read_verilog mac_synth.v; proc; memory; equiv_make mac_int8 mac_synth equiv; hierarchy -top equiv; equiv_simple; equiv_status -assert" 2>&1 | tail -10
