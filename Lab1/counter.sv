//Shomik Sen, Kavin Sundar
//This is a counter module that will keep track of how many cars are in the lot. 
//The maximum amount of cars is 18 and will signal full when it is reached. 
//When there are no cars in the lot it will signal clear. 

module counter (incr, decr, total, clk, reset, clear, full);
	input logic incr, decr, clk, reset;
	output logic [4:0] total;
	output logic clear, full;
	
	//Check to see if there is a car entering or exiting
	//resetting will set the total back to zero
	always_ff @(posedge clk) begin
		if (reset) begin
			total <= 0;
		end
		else begin
			if(incr && full != 1) begin  //if entering it will increase total by one
				total <= total + 1'b1;
			end
			else if (decr && clear != 1) begin  //if exiting it will decrease total by one
				total <= total - 1'b1;
			end
		end
	end
	
   //sets clear to 1 when total is zero
	//sets full to 1 when total is at 18
	assign clear = (total == 0);
	assign full = (total >= 18);
endmodule

	
	