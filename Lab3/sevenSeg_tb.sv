module sevenSeg_tb();

	logic clk;
	logic [4:0] total;
	logic clear;
	logic full;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	sevenSeg dut (num, HEX);

	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	initial begin
		@(posedge clk); //TESTS FOR EMPTY
		clear = 1; @(posedge clk); //TESTS FOR EMPTY WITH NO TOTAL
		total = 5'd4; @(posedge clk); //TESTS FOR EMPTY WITH TOTAL
		clear = 0;
		total = 5'd0;

					@(posedge clk); //TESTS FOR FULL
		full = 1;   @(posedge clk); //TESTS FOR FULL WITH NO TOTAL
		total = 5'd4; @(posedge clk); //TESTS FOR EMPTY WITH TOTAL


		full=0; @(posedge clk); //TESTS ALL CASES FOR HEXs
		total = 5'd0; @(posedge clk);
		total = 5'd1; @(posedge clk);
		total = 5'd2;  @(posedge clk);
		total = 5'd3; @(posedge clk);
		total = 5'd4; @(posedge clk);
		total = 5'd5; @(posedge clk);
		total = 5'd6; @(posedge clk);
		total = 5'd7; @(posedge clk);
		total = 5'd8; @(posedge clk);
		total = 5'd9; @(posedge clk);
		total = 5'd10; @(posedge clk);
		total = 5'd11; @(posedge clk);
		total = 5'd12; @(posedge clk);
		total = 5'd13; @(posedge clk);
		total = 5'd14; @(posedge clk);
		total = 5'd15; @(posedge clk);
		total = 5'd16; @(posedge clk);
		total = 5'd17; @(posedge clk);
		total = 5'd18; @(posedge clk);
		
		$stop;

	end
endmodule