//Shomik Sen
//FSM to Detect button press
module buttonPress(clock, reset, button, isPressed);
	input logic clock, reset, button;
	output logic isPressed;
	
	logic meta_button1, meta_button2;
	 //handles metastability
	always_ff @(posedge clock) begin
		meta_button1 <= button;
		meta_button2 <= meta_button1;
	end
	
	enum {pressed, notPressed} ns,ps;
	
	//button logic to decide when it is pressed or not
	always_comb begin
		case(ps)
			notPressed: begin
				if(~meta_button2)
					ns = pressed;
				else
					ns = notPressed;
			end
			
			pressed: begin
				if(~meta_button2)
					ns = pressed;
				else
					ns = notPressed;
			end	
		endcase
	end
	
	//make the output isPressed only true for one clock cycle
	//eg. when the button is not being held down but is pressed at that exact
	//moment
	assign isPressed = (ps == notPressed) && (~meta_button2);
	
	always_ff @(posedge clock) begin
		if(reset)
			ps <= notPressed;
		else
			ps <= ns;
	end
endmodule


module buttonPress_tb();
	logic clock, reset, button;
	logic isPressed;
	
	buttonPress bP(clock, reset, button, isPressed);
	
	//simulate clock
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin
		clock <=0;
		forever #(CLOCK_PERIOD/2) clock <= ~clock;
	end
	
	//now this is the actual testing
	
	initial begin
		reset = 1;     @(posedge clock);
		reset = 0;     @(posedge clock);
							@(posedge clock);
							@(posedge clock);
		button <=1; repeat(4) @(posedge clock);
		button <=0; repeat(4) @(posedge clock);
		button <=1;   repeat(2) @(posedge clock);
		button<= 0;   repeat(2) @(posedge clock);
		$stop;
	end
endmodule 
	   