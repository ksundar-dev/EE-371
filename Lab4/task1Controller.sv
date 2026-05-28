//Shomik Sen, Kavin Sundar
//This is the controller module for task1 that will take in status signals from the datapath and then updates the control signals based on the states using the ASMD chart

module task1Controller #(parameter N= 8)(A0, A_empty, right_shiftA, incr_result, init_result, Load_A, set_done, s, clock, reset);
	
	
	//inputs and outpus which are status signals and control signals 
	input logic  s, clock, reset, A0, A_empty;
	
	output logic right_shiftA, Load_A, set_done, init_result;
	
	output logic incr_result;
	
	enum logic[1:0] {S1, S2, S3} ps, ns;
	
	
	//state transitions based on the status signals from the data and the ASMD chart
	always_comb begin 
		case(ps)
			
			S1: if(s) ns = S2;
				 else  ns = S1;
			
			S2: if (A_empty) ns = S3;
				 else  ns = S2;
				 
			S3: if(s) ns = S3;
				 else ns = S1;
				 
			default: ns = S1;
		endcase
	end
	
	//reset logic to transition between states
	always_ff @(posedge clock) begin
		if(reset)begin
			ps <= S1;
		end
		else ps <= ns;
	end
	
	
	//combinational logic to assign all of the control signals based on the current state
	always_comb begin
	
		right_shiftA = 0;
		Load_A       = 0;
		set_done     = 0;
		init_result  = 0;
		incr_result  = 0;
		if( ps == S1 ) begin
			set_done = 0;
		if(s) begin
        init_result = 1; // Transitioning to S2
		end else begin
				Load_A = 1;      // Idling in S1
			end
		end
		
		else if (ps == S2) begin
			right_shiftA = 1;
			if(A0) incr_result = 1;;
		end
		
		else if( ps == S3) set_done = 1;	
	end
endmodule
				
				
				

	
	
		
		
		
		
	

	
	
	
	

