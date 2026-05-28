//Shomik Sen, Kavin Sundar
//This is our testbench module for the data path of the binary search
module task2DataPath_tb();
	
	logic incr_addr, decr_addr, Load_Reg, assert_done, assert_found, clock;
	
	logic equals, count_big, Rom_small, done, reset;
	
	logic [7:0] A, datain;
	
	logic [4:0] addr;
	
	logic [3:0] count;
	
	logic found;
	logic [4:0] loc;
	
	logic incr_count;
	
	
	task2DataPath dut(.*);
	
		// Clock generation
	parameter CLOCK_PERIOD=100;
	initial begin
		clock <= 0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock; // Forever toggle the clock
	end
	
	initial begin
	
		//initialize things
		assert_done <= 0;
		decr_addr <= 0;
		incr_addr <= 0;
		assert_found <= 0;
		Load_Reg <= 1;   @(posedge clock);
		Load_Reg <= 0;   @(posedge clock);
		
		
		//initialize the A variable
		A <= 8'd12;  @(posedge clock);
		
		
		//create a datain value to see if equals becomes high 
		datain <= 8'd12;  @(posedge clock);
		
		//decriment the address to see if count increases and the addr changes to 8
		decr_addr <= 1;  incr_count <= 1;     @(posedge clock);
		decr_addr <= 0;  incr_count <= 0;      @(posedge clock);
		
		//increment address to see if it changes to 12
		
		incr_addr <= 1;   incr_count <= 1;      @(posedge clock);
		incr_addr <= 0;   incr_count <= 0;    @(posedge clock);
		
		//decriment address to see if count increases and addr changes to 10
		decr_addr <= 1; incr_count <= 1;     @(posedge clock);
		decr_addr <= 0;  incr_count <= 0;  @(posedge clock);
		
		//increment address to see if count icnreases and addr changes to 11;
		incr_addr <= 1; incr_count <= 1;     @(posedge clock);
		incr_addr <= 0; incr_count <= 0;      @(posedge clock);
		//now change datain to see if rom_small gets asserted
		datain <= 8'd11;    @(posedge clock);
		
		//do another decriment or increment to see if the count increases and count big is asserted
		
		incr_addr <= 1; incr_count <= 1;     @(posedge clock);
		incr_addr <= 0;  incr_count <= 0;     @(posedge clock);
		
		assert_found <= 1;                    @(posedge clock);
		
		assert_done <= 1;   @(posedge clock);
								@(posedge clock);
		
		$stop;
	end
endmodule 
		