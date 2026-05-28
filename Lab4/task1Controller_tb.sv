module task1Controller_tb();

	logic [8:0] A;
	
	logic  s, clock, reset, A0, A_empty;
	
	logic right_shiftA, Load_A, set_done, init_result;
	
	logic incr_result;
	
	task1Controller dut(.*);
	
	// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end
	
	initial begin
	
		//instantiate everything and toggle reset
		reset<= 1;      @(posedge clock);
		reset <= 0;
		A_empty <= 0;

		
		//start in state 1 and assert s to zero, Load_A should be asserted
		
		s <= 0;       @(posedge clock);
		
		//set s to 1 to go to state 2 and right_shiftA should be asserted
		
		s <= 1;       @(posedge clock);
		
		//assert A0 to one to see if incr result is asserted, rightshiftA should be asserted 
		
		A0 <= 1;      @(posedge clock);
		
		A0 <= 0;      @(posedge clock);
		
		A0 <= 1;      @(posedge clock);
		
		A0 <= 1;     @(posedge clock);
		
		//A_empty is zero and Done should be asserted
		
		A_empty <= 1;  @(posedge clock);
		
		//go back to state 1 and init_result 
		
		s <= 0;        @(posedge clock);
		
		$stop;
	end
endmodule