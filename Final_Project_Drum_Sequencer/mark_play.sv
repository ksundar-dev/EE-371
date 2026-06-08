//Shomik Sen, Kavin Sundar
//This module handles the situation when the user pressed the button. It should mark a diagonal like across the current box
//that the playhead is on.
module mark_play (x0, count, y0, clock, reset, line_clear, x, y, pixel_write, width, height, buttonPressed, start, array_reg, all_done);

	input logic [10:0] x0, y0, width, height; //coordinates for the top left of the rectangle for each row
	
	input logic clock, reset, buttonPressed, start; //basic clock, reset, buttonpressed signals
	
	input logic [3:0] count;  //count signal from the Draw_Playhead module
	
	input logic [15:0] array_reg; //array that contains the positions in which a note is already pressed
	
	output logic pixel_write; //signal to tell the VGA to draw
	
	output logic line_clear; //signal to erase a line
	
	output logic [10:0] x, y; //actual lines that will be drawn
	
	output logic all_done;  //signal to tell the top level to go back to drawing playheads
	
	logic [10:0] temp_x0, temp_x1, temp_y1, temp_y0; //coordinates to change based on the position of the playhead
	
	logic line_done, line_reset; //internal signals for the line drawer module
	
	logic [10:0] line_x, line_y; //internal signals for the actual lines being drawn
	
	//assign the actual lines to eachother
	assign x = line_x;
	assign y = line_y;
	
	//instantiate the line drawer module
	line_drawer diagonal(.clk(clock), .reset(line_reset), .x0(temp_x0), .y0(temp_y0), .x1(temp_x1), .y1(temp_y1), .x(line_x), .y(line_y), .done(line_done));
	
	//different states
	enum logic [1:0] {S_Setup, S_Wait, S_Draw, S_Done} ps, ns;
	
	//state transitions
	always_comb begin 
		case(ps)
			
			S_Setup: if(start) ns = S_Wait;
						else ns = S_Setup;
						
			S_Wait: if(buttonPressed) ns = S_Draw;
					  else ns = S_Wait;
					  
			S_Draw: if(line_done) ns = S_Done;
					  else ns = S_Draw;
			S_Done: ns = S_Wait;
			
			default: ns = S_Setup;
		endcase
	end
	
	//flip flop transitions
	always_ff @(posedge clock) begin
		if(reset) ps <= S_Setup;
		else ps <= ns;
	end
	
	//signals that change based on the current states and status signals
	always_comb begin
	//default signals
		line_clear = 1'b0;
		pixel_write = 1'b0;
		line_reset = 1'b0;
		temp_x0 = x0;
		temp_y0 = y0;
		temp_x1 = x0 + width;
		temp_y1 = y0 + height;
		all_done = 1'b0;
		
		//set the first line to the first rectangle
		if(ps == S_Setup && start) begin
			temp_x0 = x0;
			temp_y0 = y0;
			temp_x1 = x0 + width;
			temp_y1 = y0 + height;
			line_reset = 1'b1; //tell the line to get ready to draw
			line_clear = 0;  //white
			pixel_write = 0; //dont draw
		end
		//change the coordinates to the current playhead counter
		else if(ps == S_Wait) begin
			line_reset  = 1'b1; 
			temp_x0     = x0 + (11'd40 * {7'b0,count});
			temp_y0     = y0;
			temp_x1     = temp_x0 + width;
			temp_y1     = y0 + height;
		end
		//draw the line
		else if(ps == S_Draw) begin
			if(array_reg[count] == 0) begin
				pixel_write = 1'b1; //draw
				temp_x0 = x0 + (11'd40 * {7'b0,count});
				temp_y0 = y0;
				temp_x1 = temp_x0 + width;
				temp_y1 = y0 + height;
				line_clear = 0; //white
			end
			else begin
				pixel_write = 1; //draw
				temp_x0 = x0 + (11'd40 * {7'b0,count}); //current box top left x coordinate
				temp_y0 = y0;
				temp_x1 = temp_x0 + width;
				temp_y1 = y0 + height;
				line_clear = 1; //black , erase
			end
		end
		else if(ps == S_Done) begin
			line_reset = 1'b1;
			pixel_write = 0;
			all_done = 1'b1;
		end
		else begin
			temp_x0 = x0;
			temp_y0 = y0;
			line_clear = 0;
			line_reset = 0;
			pixel_write = 0;
		end
	end
endmodule 
			
	
	