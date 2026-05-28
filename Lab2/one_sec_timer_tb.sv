//Shomik Sen Kavin Sundar
//4/17/26
//LAB2
//This module is teh testbench for our one second timer to make sure it is actuallyw orking properly
module one_sec_timer_t();
	logic clk;
	logic reset;
	logic oneSec;



	// Instantiate DUT
	one_sec_timer dut(
	.clk(clk),
	.reset(reset),
	.oneSec(oneSec)
	);

	// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end


	initial begin
		// Initialize inputs
		reset = 1;

		// Apply reset
		reset = 1;
			repeat(6000) @(posedge clk);
		reset = 0;
			repeat(6000) @(posedge clk);

		//RUn to make sure everything is good
			repeat(6000) @(posedge clk);
			repeat(6000) @(posedge clk);
			repeat(6000) @(posedge clk);
			repeat(6000) @(posedge clk);
			repeat(6000) @(posedge clk);


		$stop;
	end
endmodule 