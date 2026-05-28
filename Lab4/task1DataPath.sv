//Shomik Sem, Kavin Sundar
//This is the datapath logic that takes signals from the controller to update the data and send status signals back to the controller

module task1DataPath #(parameter N = 8)(reset, A0, A_empty, Done, set_done, Load_A, right_shiftA, result,init_result, incr_result, A, Switches, clock);

	//Control signals from the controller to tell the DataPath what to do  
	input logic reset, Load_A, right_shiftA, init_result, incr_result, set_done, clock;
	
	//switches that will determine the values in the A register
	input logic [N-1:0] Switches;
	
	//This is the result that will increment everytime A0 is 1
	output logic [$clog2(N) : 0 ] result;
	
	//status signals that will be sent to the controller
	output logic A0, A_empty, Done;
	
	//this is the register that will shift 
	output reg [N-1:0] A;
	

	always_ff @(posedge clock) begin
	//assign A to the switches given the control signal Load_A
		if(reset)begin
			Done <= 0;
			result <= 0;
			A <= 0;
		end
		else if(init_result) begin 
        result <= 0;
        Done <= 0;
      end
		else if(Load_A) begin
			A <= Switches;
		end
		//shift the register and then check the lsb for A
		else if (right_shiftA) begin
			A <= {1'b0, A[N-1:1]};
			//increment the result based on the control signal
			if (incr_result) result <= result + 1;
		end
		else if(set_done) Done <= 1;
	end
	
	assign A_empty = (A == 0);
	assign A0 = A[0];
endmodule


		
		
	