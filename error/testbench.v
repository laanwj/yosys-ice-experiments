`timescale 1ns / 1ps

module testbench;
	localparam CLOCK_FREQ_HZ = 12e6;
	localparam BAUD_RATE = 115200;

	reg clk = 1;
	always #(0.5e9 / CLOCK_FREQ_HZ) clk = ~clk;

	reg resetq = 0;
	initial begin
		repeat (100) @(posedge clk);
		resetq <= 1;
	end

	reg RXD = 1;
	wire TXD;

	initial begin
		$dumpfile("testbench.vcd");
		$dumpvars(0, testbench);

		// wait 10 bit times
		repeat (10) #(1e9 / BAUD_RATE);

		// send 'a' (b01100001)
		#(1e9 / BAUD_RATE); RXD <= 0;  // start bit
		#(1e9 / BAUD_RATE); RXD <= 1;  // data bit #0 (LSB)
		#(1e9 / BAUD_RATE); RXD <= 0;  // data bit #1
		#(1e9 / BAUD_RATE); RXD <= 0;  // data bit #2
		#(1e9 / BAUD_RATE); RXD <= 0;  // data bit #3
		#(1e9 / BAUD_RATE); RXD <= 0;  // data bit #4
		#(1e9 / BAUD_RATE); RXD <= 1;  // data bit #5
		#(1e9 / BAUD_RATE); RXD <= 1;  // data bit #6
		#(1e9 / BAUD_RATE); RXD <= 0;  // data bit #7 (MSB)
		#(1e9 / BAUD_RATE); RXD <= 1;  // stop bit

		// wait 100 bit times
		repeat (100) #(1e9 / BAUD_RATE);
		$finish;

	end

	top uut (
		.clk(clk),
		.resetq(resetq),
		.TXD(TXD),
		.RXD(RXD)
	);
endmodule
