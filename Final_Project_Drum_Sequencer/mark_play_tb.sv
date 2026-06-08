//Shomik Sen, Kavin Sunder
//This is our testbench module for mark_play module functionality
module mark_play_tb();

	logic [10:0] x0, y0, width, height;
	logic        clock, reset, buttonPressed, start;
	logic [3:0]  count;
	logic [15:0] array_reg;

	logic        pixel_write, line_clear;
	logic [10:0] x, y;
	logic        all_done;

	// Instantiate the module under test using named wildcard port bindings
	mark_play dut(.*);

	// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end

	initial begin

		// Toggle reset and initialize everything
		reset <= 1; start <= 0; buttonPressed <= 0; count <= 4'd0;
		x0 <= 11'd20; y0 <= 11'd25;
		width <= 11'd25; height <= 11'd90;
		array_reg <= 16'b0;                 @(posedge clock);
		reset <= 0;                        @(posedge clock);

		//in S_Setup state doing nothing yet
		start <= 0;                        @(posedge clock);

		// Start and see if the internal variables are initialized while going to S_Wait
		start <= 1;                        @(posedge clock);
		start <= 0;

		//press the button and go to S_Draw
		buttonPressed <= 1;                @(posedge clock);
		buttonPressed <= 0; // Clear immediately to simulate real edge control behavior

		//S_Draw state and see if the line is drawing and wait until the done signal is asserted
		@(posedge dut.diagonal.done);

		//go to S_Done
													 @(posedge clock);
		 
		//Loop back to S_Wait 
													 @(posedge clock);

		//Check to see if it will delete a line by marking array_reg[count] to 1
		array_reg[count] <= 1'b1; 
		buttonPressed    <= 1;             @(posedge clock); //Transition from S_Wait to S_Draw
		buttonPressed    <= 0;            

		//Wait for the internal line signal to be asserted while the pixels should be black
		@(posedge dut.diagonal.done);

		//Go to S_Done and then S_Wait again
													 @(posedge clock);
													 @(posedge clock);
		$stop;
	end
endmodule