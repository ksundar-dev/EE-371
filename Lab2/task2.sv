//Shomik Sen Kavin Sundar
//4/17/26
//LAB2
// synopsys translate_off
// `timescale 1 ps / 1 ps
// synopsys translate_on
//Task 2 module that is our multideminsional array 
module task2 (input logic clock, input logic [4:0] address, input logic [2:0] data, input logic wren, output logic [2:0] q);

	logic [2:0] memory_array[31:0];	//creates the array with correct bits and words
	
	always_ff @(posedge clock) begin				//sync
		if(wren) begin									//writes
			memory_array[address] <= data;
			q <= data;
		end
		
		else												//reads
			q <= memory_array[address];
	end
	
endmodule
		 