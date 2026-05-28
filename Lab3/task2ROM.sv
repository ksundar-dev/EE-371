//Shomik Sen, Kavin Sundar
//This module plays the single tone from the MIF file in our ROM by iterating through each address to play the note 

module task2ROM(CLOCK_50, reset, write_ready, writedata_left, writedata_right, write);
	
	
	//inputs and outputs to connect the ROM to the audio Codec
	input logic CLOCK_50, reset, write_ready; 
	output logic [23:0] writedata_left, writedata_right;
	output logic write;
	
	//ROM address and data
	reg[16:0] addr;
	wire [23:0] rom_data;
	
	
	//instantiate the ROM module 
	task2 ROM(.address(addr), .clock(CLOCK_50), .q(rom_data));
	
	
	//set the left and right data to the ROM values
	assign writedata_left = rom_data;
	
	assign writedata_right = rom_data;
	
	always_ff @(posedge CLOCK_50) begin
		if(reset) addr <= 0; //resets the address
		
		
		//when write_ready is toggled it will write and iterate through each address in the ROM
		else if(write_ready) begin
			write <= 1'b1;         //
		
			if (addr == 17'd95999) begin
				addr <= 0;
			end
		
			else
				addr <= addr +1;
		end
		else write <= 1'b0;
	end

	
endmodule
