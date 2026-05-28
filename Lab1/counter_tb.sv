module counter_tb();

	logic incr, decr, clk, reset;
	logic [4:0] total;
	logic clear, full;
	
	counter ctb(.*);
	
		// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		clk <= 0;	
		forever #(CLOCK_PERIOD/2) clk <= ~clk;	// Forever toggle the clock
	end	
	
	
	initial begin
		
		//toggle reset
		reset = 1;  @(posedge clk)
		reset = 0;  @(posedge clk)
		incr = 0;
		
		//fill up 18 cars to see if the full turns on
		repeat(18) begin
        @(posedge clk);
        incr = 1;       // Car enters
        @(posedge clk);
        incr = 0;       // Sensor clears
		end
		
		//toggle reset 
		reset = 1;  @(posedge clk);
		reset = 0; @(posedge clk);
		
		
		//fill up 5 cars then have the 5 cars leaving to see if clear displays properly 
		repeat(5) begin
        @(posedge clk);
        incr = 1;       // Car enters
        @(posedge clk);
        incr = 0;       // Sensor clears
		end
		
		repeat(5) begin
        @(posedge clk);
        decr = 1;       // Car enters
        @(posedge clk);
        decr = 0;       // Sensor clears
		end
		
		//toggle reset 
		reset = 1;  @(posedge clk);
		reset = 0; @(posedge clk);
		
		$stop;
	end
endmodule 