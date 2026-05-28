//Kavin Sundar Shomik Sen
//4/17/2026
//Lab 2 Memory
//This is the testbench for the task 1 specifcally used for making sure reading and
//writing memory works correctly.
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module task1_tb();

	logic clock; 
	logic [4:0] address;
	logic [2:0] data; 
	logic wren; 
	logic [2:0] q;	//important inputs/logics
	
	task1 dut1(.clock(clock),.address(address),.data(data), .wren(wren),.q(q)); //calls task 1
	task2 dut2(.*); //calls task 2
	
	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		clock <= 0;	
		forever #(CLOCK_PERIOD/2) clock <= ~clock;	// Forever toggle the clock
	end	
	
	initial begin
	
		//instantiate everything 
	                         
														@(posedge clock); 
		wren <= 1'b0; address <= 5'b0; data <= 3'b0;  @(posedge clock);
	
		//write data to an address
	
		wren <= 1'b1; address <= 5'b1; data <= 3'b1;  @(posedge clock);
	
		//write different data to another address
	
		wren <= 1'b1; address <= 5'd2; data <= 3'b100;  @(posedge clock);
	
		//read data from a specific address
		
		wren <= 1'b0; address <= 5'b1;             @(posedge clock);
		
		//write data to an address
	
		wren <= 1'b1; address <= 5'b1; data <= 3'b110;  @(posedge clock);
	
		//write different data to another address
	
		wren <= 1'b1; address <= 5'd4; data <= 3'b011;  @(posedge clock);
	
		//read data from a specific address
		
		wren <= 1'b0; address <= 5'd4;             @(posedge clock);
	
		// Fill up memory and overwrite everything that has been written 
		for(int i = 0; i < 32; i++) begin    @(posedge clock);
			wren <= 1;
			address <= i;
			data <= 1;
		end                                  
		
		//read all of the memory
		for(int i = 0; i < 32; i++) begin    @(posedge clock);
			wren <= 0;
			address <= i;
		end                                  
		
		$stop;
	end
endmodule
	
	 
	
	
		