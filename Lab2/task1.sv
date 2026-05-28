//Shomik Sen Kavin Sundar
//4/17/26
//LAB2
// synopsys translate_off
// `timescale 1 ps / 1 ps
// synopsys translate_on
//Task 1 module that calls the 32x3 1 port ram
module task1(input logic clock, input logic [4:0] address, input logic [2:0] data, input logic wren, output logic [2:0] q);

	ram32x3 ram(.clock(clock),.address(address),.data(data), .wren(wren),.q(q));
	
endmodule