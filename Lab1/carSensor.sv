module carSensor(enter, exit, outer, inner, clk, reset);
	input logic outer, inner, clk, reset;
	output logic enter, exit; 
	
	//sets the three states needed to determine weather the car is entering or exiting
	enum logic [1:0] {ZeroZero, ZeroOne, OneOne, OneZero} ps, ns;
	
	always_comb begin 
	
		case(ps)
			//handle the case where no car is there
			ZeroZero: if(outer == 0 && inner == 1) ns = ZeroOne; 
						 else if(outer == 1 && inner == 0) ns = OneZero;
						 else ns = ZeroZero;
			//case where the car is exiting
			ZeroOne: if(outer == 1 && inner == 1) ns = OneOne;
						else if(outer == 0 && inner == 1) ns = ZeroOne;
						else ns = ZeroZero;
			//case where car is in the middle
			OneOne: if( outer == 0 && inner == 0) ns = ZeroZero;
                 else if (outer == 1 && inner == 0) ns = OneZero;
                 else if (outer == 0 && inner == 1) ns = ZeroOne;
                 else ns = OneOne;
			//case where car is entering
			OneZero: if (outer==1 && inner==1)  ns = OneOne;
                  else if (outer == 1 && inner == 0) ns = OneZero;
                  else ns = ZeroZero;
						
	  endcase
	end
	
	//when reset go back to the empty state
	always_ff @(posedge clk or posedge reset) begin
		if (reset) ps <= ZeroZero;
		else ps <= ns;
	end
	
	
	assign enter = (ps == OneOne && ns == ZeroOne); //enter will only be valid during the transition None state to Enter state
	assign exit = (ps == OneOne && ns == OneZero); //exit will only be valid during the transition between None state and Exit state
endmodule
