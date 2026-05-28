//Shomik Sen, Kavin Sundar
//This is our module for task1 where it connects the read, write, writedata_left, and Writedata_right ports to the correct inputs

module part1 (CLOCK_50, read_ready, write_ready,readdata_left, readdata_right,writedata_left, writedata_right, read, write);

	input CLOCK_50;
	
	// Local wires.
	input read_ready, write_ready;
	input [23:0] readdata_left, readdata_right;
	output [23:0] writedata_left, writedata_right;
	output read, write;

	//connects read and write to the correct inputs
	assign read = read_ready && write_ready;
	assign write = read_ready && write_ready;
	
	
	//connects the writedata_left and writedata_right outputs to the correct inputs
	assign writedata_left = readdata_left;
	assign writedata_right = readdata_right;
	


endmodule


