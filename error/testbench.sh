#!/bin/bash
set -ex

run_testbench() {
	local p=$1; shift
	iverilog -o testbench_$p -s testbench testbench.v $p.v "$@" \
			$(yosys-config --datdir/ice40/cells_sim.v --datdir/simcells.v --datdir/simlib.v)
	./testbench_$p
	mv testbench.vcd testbench_$p.vcd
}

run_testbench ok uart.v
run_testbench fail uart.v

yosys -o synth_ok.v -ql synth_ok.log -p 'synth_ice40 -top top' ok.v uart.v
run_testbench synth_ok

yosys -o synth_fail.v -ql synth_fail.log -p 'synth_ice40 -top top' fail.v uart.v
run_testbench synth_fail

icebox_vlog -n top -sLp ok.pcf ok.txt > post_ok.v
run_testbench post_ok

icebox_vlog -n top -sLp fail.pcf fail.txt > post_fail.v
run_testbench post_fail

