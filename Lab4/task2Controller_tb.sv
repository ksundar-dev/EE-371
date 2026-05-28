//Shomik Sen, Kavin Sunder
//This is our testbnech module for task2Controller
module task2Controller_tb();

	logic equals, count_big, Rom_small, start, reset, clock, incr_count;
	
	logic incr_addr, decr_addr, Assert_found, Load_Reg, assert_done;
	
	task2Controller dut(.*);
	
		// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end
	
	initial begin 
		
		//toggle reset and intialize things
		reset<= 1;  @(posedge clock);
		reset <= 0; @(posedge clock);
		
		//loop back to s0
		
		start <= 0;     @(posedge clock);
		
		//go to s wait and see if load reg is asserted
		
		start <= 1;      @(posedge clock);
		
		//go to s_start 
		            @(posedge clock);
						
		//toggele rom small to see if incr_addr is toggles
		
		equals <= 0;
		count_big <= 0;
		Rom_small <= 1; @(posedge clock);
		Rom_small <= 0; @(posedge clock);
		
		//Rom_small is still at zero to show that decr_addr is asserted
		
							@(posedge clock);
							@(posedge clock);
		//set equals to 1 and assert_found should be toggled
		equals <= 1;   @(posedge clock);
		
		//wait a clock cycle so that assert done becomes 1
							@(posedge clock);
		$stop;
	end
endmodule 
		