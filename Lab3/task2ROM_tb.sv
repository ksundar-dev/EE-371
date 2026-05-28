//Kavin Sundar, Shomik Sen
//This is the tsk2ROM testbench that cycles through each value in the MIF file and writes it to the writedata_left and writedata_right
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module task2ROM_tb();

	//inputs and outputs to connect the ROM to the audio Codec
	logic CLOCK_50, reset, write_ready; 
	logic [23:0] writedata_left, writedata_right;
	logic write;
	
	task2ROM dut(.*);
	
	parameter CLOCK_PERIOD=100;	
	initial begin	
		CLOCK_50 <= 0;	
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;	// Forever toggle the clock
	end	
	
	initial begin 
		
		//toggle reset
		
		reset = 1;  @(posedge CLOCK_50);
		
		reset = 0;  @(posedge CLOCK_50);
		
		
		
		//increment each address and see if it reads the correct data from the MIF file
	  
		repeat (4092) begin
			@(posedge CLOCK_50);
			write_ready = 1;
		end
		
		
		//toggle reset
		reset = 1;       @(posedge CLOCK_50);
		
		reset = 0;       @(posedge CLOCK_50);
		
		
		$stop;
	end
endmodule 

	