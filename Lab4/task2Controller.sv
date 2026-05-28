//Shomik Sen, Kavin Sundar
//This is the module that handles the binary search state transitions and controll logic, taking status signals from the data path and outputting control signals
module task2Controller(incr_addr, decr_addr, Assert_found, Load_Reg, equals, count_big, Rom_small, assert_done, reset, start, clock, incr_count);
	
	//status signals and clock and reset
	input logic equals, count_big, Rom_small, start, reset, clock;
	
	//control signals to the data path
	output logic incr_addr, decr_addr, Assert_found, Load_Reg, assert_done, incr_count;
	
	//three states
	enum logic [2:0] {s0,s_wait,s_start,s_done} ps, ns;
	
	//state transition logic
	always_comb begin
		case(ps) 
			
			s0: if(start) ns = s_wait;
				 else ns = s0;
				 
		   
			s_wait: ns = s_start;
			
			s_start: if(equals) begin
							ns = s_done;
						end
						else if(count_big) ns = s_done;
						else ns = s_wait;
						
			s_done: ns = s0;
			
			default: ns = s0;
		endcase
	end
	
	//reset and state logic on flip flop
	always_ff @(posedge clock) begin
		if(reset) ps <= s0;
		else ps <= ns;
	end
	
	//control signal output logic based ont he states and status signals
	always_comb begin
		
		incr_addr = 0;
		decr_addr = 0;
		Assert_found = 0;
		Load_Reg = 0;
		assert_done = 0;
		incr_count = 0;
		
		if(ps == s0 && ns == s_wait) Load_Reg = 1;
		else if(ps == s_wait) incr_count = 1;
		
		else if(ps == s_start && equals) Assert_found = 1;
		
		else if(ps == s_start && Rom_small) incr_addr = 1;
		
		else if (ps == s_start && ~Rom_small) decr_addr = 1;
		
		else if(ps == s_done) assert_done = 1;
	end
		
endmodule 



	
		