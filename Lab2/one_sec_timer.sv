//Shomik Sen Kavin Sundar
//4/17/26
//LAB2
//This module defines the one second timer that will determine when the counter for the address on task3 is incrementing 
module one_sec_timer #(parameter COUNT_MAX = 550000)(
	input logic clk,
	input logic reset,
	output logic oneSec);

	logic [$clog2(COUNT_MAX):0] count; //Makes count that can be tracked through simulations

	always_ff @(posedge clk or posedge reset)begin
		if(reset)begin
			count<=0;						//makes count and onesec 0 at reset
			oneSec<=0;
		end
		else begin
			if(count >= COUNT_MAX - 1)begin		//checks if abopve or equal to one sec threshold
				count<=0;
				oneSec<=1;
			end
			else begin
				count <= count+1;						//increments one if not reset or equal/greater than parameter
				oneSec<=0;
			end
		end
	end
endmodule



