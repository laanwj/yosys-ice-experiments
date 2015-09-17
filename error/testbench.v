`timescale 1ns / 1ps

module testbench;
	localparam CLOCK_FREQ_HZ = 12e6;
	localparam BAUD_RATE = 115200;

	reg clk = 0;
	initial begin
		#(1.5e9 / CLOCK_FREQ_HZ);
		forever #(0.5e9 / CLOCK_FREQ_HZ) clk = ~clk;
	end

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

	reg [7:0] tx_buffer;
	integer i;

	always begin
		// tx start bit
		@(negedge TXD);
		#(0.5e9 / BAUD_RATE);

		// tx data bits
		tx_buffer = 0;
		for (i = 0; i < 8; i = i+1) begin
			#(1e9 / BAUD_RATE);
			tx_buffer = tx_buffer | (TXD << i);
		end

		if (tx_buffer < 32)
			$display("TX char: hex %02x", tx_buffer);
		else
			$display("TX char: '%c'", tx_buffer);
	end

	top uut (
		.clk(clk),
		.resetq(resetq),
		.TXD(TXD),
		.RXD(RXD)
	);
endmodule
