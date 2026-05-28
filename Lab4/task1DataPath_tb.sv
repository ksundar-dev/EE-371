
module task1DataPath_tb();

	logic Load_A, right_shiftA, init_result, incr_result, set_done, clock, reset;
	
	logic [7:0] Switches;
	
	logic [3:0] result;
	
	logic A0, A_empty, Done;
	
	reg [7:0] A;
	
	task1DataPath dut(.*);
	
	// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end
	
	
	initial begin
		//initialize everything
		
		Switches <= 8'b10010011;    @(posedge clock);  
		Load_A <=1;	init_result <= 1;						@(posedge clock); 
	
		Load_A <= 0;     @(posedge clock);
		
		//right Shift A 7 times see what A0 and A_empty is asserted

		right_shiftA <= 1;  repeat(12) @(posedge clock); 
		
		//increment result 4 times
		

		incr_result <= 1;   repeat(5)		@(posedge clock); 
		//set done to 1
		
		set_done <= 1;     @(posedge clock);
		
		$stop;
	end
endmodule
