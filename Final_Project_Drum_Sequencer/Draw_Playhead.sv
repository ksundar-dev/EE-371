//Shomik Sen, Kavin Sundar
//This module is i charge of the playhead above the boxes. It operates on 130bpm so will appear, erase, and appear on the next
//box at the rate of 130bpm
module Draw_Playhead (x0, count, y0, clock, reset,clear_count, incr_count, line_clear, x, y, pixel_write, switcher);

	input logic [10:0] x0, y0; //top left coordinates
	
	input logic [3:0] count;  //counter to determine what block the count is on
	
	input logic clock, reset; //clock and reset
	
	output logic switcher;
	
	output logic incr_count; //control signal to increment the counter
	
	output logic line_clear; //control signal to erase the line
	
	output logic [10:0] x, y; //lines that are being drawn 
	
	output logic clear_count; //control signal to set the counter to zero
	
	output logic pixel_write; //write enable signal to send to the VGA
	
	localparam [25:0] Seventy_BPM = 26'd42857143; //seventy bpm counter
	
	localparam [25:0] OneThirty_BPM = 26'd23076923; // 130 BPM counter limit at 50MHz
	
	logic [25:0] bpm_counter;  //bpm counter to go to seventy bpm
	
	logic [10:0] temp_x;      //new x that will draw
	

	logic line_done;      //wire to signal that the line is done drawing
	
	logic [10:0] line_x, line_y; //actual lines that will be drawn
	
	logic line_reset;    //signal to tell the line drawer to start another line
	
	assign x = line_x;
	assign y = line_y;
	
	//states
	enum logic [2:0] {S_Start, S_Count, S_Draw, S_Clear, S_Wait, S_Incr} ps, ns;
	
	//line drawer insatntiation 
	line_drawer ticker(.clk(clock), .reset(line_reset), .x0(temp_x), .y0(y0), .x1(temp_x + 10'd25), .y1(y0), .x(line_x), .y(line_y), .done(line_done));
	
	//state transitions
	always_comb begin
		case(ps)
		
			S_Start: if(count == 0) ns = S_Count;
						else ns = S_Start;
			
			
			S_Count:  ns = S_Draw;
			
			S_Draw: if(line_done) ns = S_Wait;
						else ns = S_Draw;
			
			S_Wait: if(bpm_counter == OneThirty_BPM) ns = S_Clear;
					  else ns = S_Wait;
			
			S_Clear: if(line_done) ns = S_Incr;
						else ns = S_Clear;
			
			S_Incr: ns = S_Draw;
			
			default ns = S_Start;
			
		endcase
	end
	
	always_ff @(posedge clock) begin
		if(reset) begin
			ps <= S_Start;
			bpm_counter <= '0;
		end
		else begin
			ps <= ns;
			
			//memory needed to increment the bpm counter
			if(ps == S_Wait) begin
				bpm_counter <= bpm_counter + 26'd1;
			end
			else bpm_counter <= '0;
		end
	end
	
	
	always_comb begin
	//inital values
		clear_count = 1'b0;
      incr_count  = 1'b0;
      line_clear  = 1'b0;
      pixel_write = 1'b0;
      line_reset  = 1'b0;
		switcher = 1'b0;
		temp_x = x0;
		
		//set the temp_x to save it in all states
		if(ps == S_Count) begin
			clear_count = 1; //clear the count to start at the first block
			line_reset = 1'b1; //tell the line drawer that it is time to draw another line
			temp_x = x0 + (11'd40 * {7'b0,count});
			switcher = 1'b0;
		end
		else if(ps == S_Draw) begin
			temp_x= x0 + (11'd40 * {7'b0, count});
			pixel_write = 1'b1;  //tell the vga to start drawing
			line_clear = 1'b0;  //set color to white
			switcher = 1'b0;
		end
		else if(ps == S_Wait) begin
			temp_x = x0 + (11'd40 * {7'b0, count});
			line_reset = 1'b1; //tell the line drawer it is time to draw another line
			switcher = 1'b0;
		end
		
		else if(ps == S_Clear) begin
			temp_x= x0 + (11'd40 * {7'b0, count});
			pixel_write = 1'b1; //VGA will draw
			line_clear = 1'b1; //black line
			switcher = 1'b1;
		end
		else if(ps == S_Incr) begin
			temp_x = x0 + (11'd40 * {7'b0, count});
			incr_count = 1'b1; //increment the counter to the next block
			line_reset = 1'b1; //draw the next line
			switcher = 1'b0;
		end
		else begin
			clear_count = 1'b0;
         incr_count  = 1'b0;
         line_clear  = 1'b0;
         pixel_write = 1'b0;
         line_reset  = 1'b0;
         temp_x      = x0;
		end
	end
endmodule 
			
	