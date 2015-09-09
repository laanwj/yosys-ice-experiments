#!/bin/bash
set -ex
iverilog -o testbench_ok -s testbench testbench.v ok.v uart.v $(yosys-config --datdir/ice40/cells_sim.v)
./testbench_ok
mv testbench.vcd testbench_ok.vcd
iverilog -o testbench_fail -s testbench testbench.v fail.v uart.v $(yosys-config --datdir/ice40/cells_sim.v)
./testbench_fail
mv testbench.vcd testbench_fail.vcd
