//Shomik Sen, Kavin Sunder
//This is our testbench module for Draw_Playhead functionality
module Draw_Playhead_tb();

	logic [10:0] x0, y0;
	logic [3:0]  count;
	logic        clock, reset;

	logic        incr_count, clear_count;
	logic        line_clear, pixel_write;
	logic [10:0] x, y;
	logic        switcher;

	Draw_Playhead dut(.*);

	// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end

	initial begin

		//toggle reset and intialize everything
		reset <= 1; x0 <= 11'd5; y0 <= 11'd5;
		count <= 4'd0;                          @(posedge clock);
		reset <= 0;                             @(posedge clock);

		//FSM will start because count is zero
		count <= 4'd0;                          @(posedge clock);

		//Go to S_Count state
		                                        @(posedge clock);

		//Go to S_Draw state
		                                        @(posedge clock);

		//wait for the playhead to to be done drawing
		@(posedge dut.ticker.done);

		//enter the wait state and wait there until the bpm counter increases
		repeat(4)                               @(posedge clock);

		//S_Clear state start erasing
		                                        @(posedge clock);
		
		// Wait for the line to clear 
		@(posedge dut.ticker.done);

		//go to S_Incr to see if incr count is triggered
		                                        @(posedge clock);

		//S_Incr to S_Start to S_Count to S_Draw
		                                        @(posedge clock);
		                                        @(posedge clock);
		                                        @(posedge clock);

		//S_Draw again 
		@(posedge dut.playhead.done);
		
		$stop;
	end
endmodule