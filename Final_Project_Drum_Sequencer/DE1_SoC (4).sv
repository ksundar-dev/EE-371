module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT); 	
	input  logic         CLOCK_50; // 50MHz clock.	
	input CLOCK2_50;
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 		
	output logic  [9:0]  LEDR; 		
	input  logic  [3:0]  KEY; // True when not pressed, False when pressed	
	input  logic  [9:0]  SW; 			
	output logic [7:0] VGA_R, VGA_G, VGA_B;
   output logic VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	logic read_ready, write_ready, read, write;
	logic [23:0] readdata_left, readdata_right, writedata_left, writedata_right;
	
	logic [6:0]  grid_idx;     // Counts 0 to 47 to track all 48 grid rectangles
	logic [10:0] sq_x0, sq_y0; // Computed top-left coordinates for the current rectangle
	
	wire reset;
	
	assign reset = SW[9];

	// Handshake wires connecting DE1_SoC to the square drawer
	logic        sq_start;     
	logic        sq_done;      

	// output coordinates coming out of the square module
	logic [10:0] draw_x, draw_y; 
	logic        draw_write;
	
	
    // states to handle the drawing of the squares
    enum logic [2:0] {S_CLEAR, S_WAIT, S_DRAW, S_PLAYBACK, S_MARK_NOTE, S_SETUP_NOTE} ps, ns;
	
	//instantiate playhead wires
	
	logic [3:0] playhead_count; 
	logic ticker_incr, ticker_clear;
	logic ticker_line_clear, ticker_write;
	logic [10:0] ticker_x, ticker_y;
	
	logic playhead_reset;
	assign playhead_reset = reset || (ps != S_PLAYBACK && ps != S_MARK_NOTE && ps != S_SETUP_NOTE); //added this so that the playhead does not start drawing before the squares are drawn
	
	//instantiate the playhead and square_drawer modules
	logic switcher;
	
	Draw_Playhead playhead(.x0(11'd1), .count(playhead_count), .y0(11'd5), .clock(CLOCK_50), .reset(playhead_reset),.clear_count(ticker_clear), .incr_count(ticker_incr), .line_clear(ticker_line_clear), .x(ticker_x), .y(ticker_y), .pixel_write(ticker_write), .switcher(switcher));
	
	square_drawer rect_drawer (.clock(CLOCK_50),.reset(reset),.start(sq_start),.done(sq_done), .x0(sq_x0), .y0(sq_y0),.width(11'd25),.height(11'd90),.x(draw_x),.y(draw_y),.pixel_write (draw_write));
	
	// Full-screen erasing sweep counters 
    logic [9:0]  clear_x;      // 0 to 640 columns 
    logic [8:0]  clear_y;      // 0 to 480 rows 
    logic        clear_done;
    
	 //to clear the screen
    assign clear_done = (clear_x == 10'd639) && (clear_y == 9'd479);

    // wires to feed into the vga framebuffer to actually draw it
    logic [9:0] vga_x;
	 logic [8:0] vga_y;
    logic pixel_color, pixel_write;

	
	// Calculate top-left x0 and y0 based on the current grid index
    always_comb begin
        logic [3:0] col;
        logic [1:0] row;
         
        // Extract row and column from the 0-63 counter
        col = grid_idx % 7'd16; // Column index: 0 to 15
        row = grid_idx / 7'd16; // Row index: 0 to 3 

        // should cover the entire screen
        sq_x0 = ({7'b0, col} * 11'd40) + 11'd1;  // spaced 40 pixels apart
        sq_y0 = ({9'b0, row} * 11'd120) + 11'd1 + 11'd25; // spaced 120 pixels apart
    end
	
	//instantiate the VGA Framebuffer
	
	VGA_framebuffer fb (.clk50(CLOCK_50),.reset(reset),.x(vga_x),.y(vga_y),.pixel_color(pixel_color),.pixel_write(pixel_write),.VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B), .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));
	
	//singals and wires for the mark_play module
	
	logic[10:0] active_y0;
	logic [15:0] active_array_reg;
	logic any_button_pressed;
	
	logic [15:0] row0_reg;
	logic [15:0] row1_reg;
	logic [15:0] row2_reg;
	logic [15:0] row3_reg;
	
	logic [10:0] mark_x, mark_y;
	logic mark_write, mark_line_clear;
	logic mark_start;
	logic mark_done;
	
	logic [1:0] row_select_reg;
	logic note_trigger;
	
	//buttonpressed to handle metastability
	logic button3Pressed, button2Pressed, button1Pressed, button0Pressed;
	
	buttonPress button3(.clock(CLOCK_50), .reset(reset), .button(KEY[3]), .isPressed(button3Pressed));
	buttonPress button2(.clock(CLOCK_50), .reset(reset), .button(KEY[2]), .isPressed(button2Pressed));
	buttonPress button1(.clock(CLOCK_50), .reset(reset), .button(KEY[1]), .isPressed(button1Pressed));
	buttonPress button0(.clock(CLOCK_50), .reset(reset), .button(KEY[0]), .isPressed(button0Pressed));

	//assign statements for any button being pressed and the internal start signal for the states of the mark_play module
	assign any_button_pressed = button3Pressed || button2Pressed || button1Pressed || button0Pressed;
	assign mark_start = (ps == S_MARK_NOTE);
	
	//combinational logic to handle the specific row that is going to be marked
	always_comb begin      //depending on the row_select_reg the active row and Y will be chosen
		active_y0 = 11'd25;
		active_array_reg = row0_reg;
		if(row_select_reg == 2'd0) begin
			active_y0 = 11'd25;
			active_array_reg = row0_reg;
		end
		else if(row_select_reg == 2'd1) begin
			active_y0 = 11'd145;
			active_array_reg = row1_reg;
		end
		else if(row_select_reg == 2'd2) begin
			active_y0 = 11'd265;
			active_array_reg = row2_reg;
		end
		else if(row_select_reg == 2'd3) begin
			active_y0 = 11'd385;
			active_array_reg = row3_reg;
		end
	end
	
	//instantiate the mark_play module
	
	mark_play diagonal(.x0(11'd1), .count(playhead_count), .y0(active_y0), .clock(CLOCK_50), .reset(reset), .line_clear(mark_line_clear), .x(mark_x), .y(mark_y), .pixel_write(mark_write), .width(11'd25), .height(11'd90), .buttonPressed(note_trigger), .start(mark_start), .array_reg(active_array_reg), .all_done(mark_done));
	
	//flip flop to handle the reset states for the row registers
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			row0_reg <= 16'd0;
			row1_reg <= 16'd0;
			row2_reg <= 16'd0;
			row3_reg <= 16'd0;
			row_select_reg <= 2'd0;
			note_trigger <= 1'b0;
		end else begin    
			if (ps == S_PLAYBACK) begin   //if the playhead is moving in that state
				if(button3Pressed) begin  //given what key is pressed it will choose which row to select
					row_select_reg <= 2'd0;
					note_trigger <= 1'b1;
				end
				else if(button2Pressed) begin
					row_select_reg <= 2'd1;
					note_trigger <= 1'b1;
				end
				else if(button1Pressed) begin
					row_select_reg <= 2'd2;
					note_trigger <= 1'b1;
				end
				else if (button0Pressed) begin
					row_select_reg <= 2'd3;
					note_trigger <= 1'b1;
				end
			end
			if(ps == S_MARK_NOTE && mark_done) begin //if we are in the mark note state and the mark is done update the registers
				note_trigger <= 1'b0;
				if(row_select_reg == 2'd0) row0_reg[playhead_count] <= ~row0_reg[playhead_count];
				if(row_select_reg == 2'd1) row1_reg[playhead_count] <= ~row1_reg[playhead_count];
				if(row_select_reg == 2'd2) row2_reg[playhead_count] <= ~row2_reg[playhead_count];
				if(row_select_reg == 2'd3) row3_reg[playhead_count] <= ~row3_reg[playhead_count];
			end
		end
	end
	
	
	// VGA datapath chooses which output to put in the VGA
    always_comb begin
        case (ps)
            S_CLEAR: begin
                vga_x       = clear_x;  
                vga_y       = clear_y; 
                pixel_color = 1'b0;             // Turn in black
                pixel_write = 1'b1;             // write the black over
            end
            
            S_DRAW: begin
                vga_x       = draw_x[9:0];           // Draw the square drawer outputs
                vga_y       = draw_y[8:0];
                pixel_color = 1'b1;             // draw it white
                pixel_write = draw_write;       // Write enable from the square module
            end
				
				S_PLAYBACK: begin
					vga_x = ticker_x[9:0];     //when the playhead wants to be drawn use the playhead outputs for x and y
					vga_y = ticker_y[8:0];
					pixel_write = ticker_write; //whenever the write signal is on from the playhead
					
					if(ticker_line_clear) begin  //if the line is done and clear is set to high turn the line black
						pixel_color = 1'b0;
					end 
					else begin
						pixel_color = 1'b1;      //if the line is being drawn the color is white
					end
				end
				
				//mark states
				S_SETUP_NOTE, S_MARK_NOTE: begin
					vga_x = mark_x[9:0]; //set the bga drawers to the x and y of the mark module
					vga_y = mark_y[8:0];
					pixel_write = mark_write; //set pixel write to the write wire in mark module
					if(mark_line_clear) begin
						pixel_color = 1'b0; //set color to black
					end
					else pixel_color = 1'b1; //set color to white
				end
            
            default: begin //Else everything else turns off
                vga_x       = 10'd0;
                vga_y       = 9'd0;
                pixel_color = 1'b0;
                pixel_write = 1'b0;           
            end
        endcase
    end
	 //state logic
    always_comb begin
        ns = ps; 
        case (ps)
            S_CLEAR: begin
                if (clear_done) ns = S_WAIT;
                else            ns = S_CLEAR;
            end
            
            S_WAIT: begin
                ns = S_DRAW; //Transition to the Draw sate
            end
            
            S_DRAW: begin
                if (sq_done) begin
                    if (grid_idx == 7'd63) ns = S_PLAYBACK; // Drawing is done
                    else                   ns = S_WAIT;  // Draw the next rectangle
                end
                else begin
                    ns = S_DRAW; //stay drawing
                end
            end
            
            S_PLAYBACK: begin
					if(any_button_pressed) ns = S_SETUP_NOTE;
               else                    ns = S_PLAYBACK; //Rectangles will stay on the screen but playhead will start drawing
            end
            S_SETUP_NOTE: begin //make a transition state to confrim the curren row where the box is
					ns = S_MARK_NOTE;
				end
				
				S_MARK_NOTE: begin  //mark note state
					if(mark_done) ns = S_PLAYBACK;
					else ns = S_MARK_NOTE;
				end
				
            default: ns = S_CLEAR;
        endcase
    end


    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            ps <= S_CLEAR;
            grid_idx <= 7'd0;
            clear_x  <= '0;
            clear_y  <= '0;
            sq_start <= 1'b0;
				playhead_count <= 4'd0; //playhead count will signal that it is at the first box
        end else begin
            ps       <= ns;
            sq_start <= 1'b0; // start willbe zero

            case (ps)
                S_CLEAR: begin
                    if (clear_done) begin
                        grid_idx <= 7'd0; // set box to first square being drawn
                    end else begin
                        //if clear x is done then start clearing y
                        if (clear_x == 10'd639) begin
                            clear_x <= '0;
                            clear_y <= clear_y + 9'd1;
                        end else begin
                            clear_x <= clear_x + 10'd1;
                        end
                    end
                end
                
                S_WAIT: begin
                    sq_start <= 1'b1; // start the rectangle drawing
                end
                
                S_DRAW: begin
                    if (sq_done && (grid_idx < 7'd63)) begin
                        grid_idx <= grid_idx + 7'd1; // draw the next rectangle
                    end
                end
                
                S_PLAYBACK: begin
                    if(ticker_clear) begin    //if clear is high then it is at the start
								playhead_count <= 4'd0;
						  end
						  else if (ticker_incr) begin
							if(playhead_count == 4'd15) begin  //wrapper condition
								playhead_count <= 4'd0;
							end else begin
								playhead_count <= playhead_count + 4'd1; //increment count condition
							end
                    end
                    else begin
                        playhead_count <= playhead_count;
                    end
                end
            endcase
        end
    end
	 //SOUND IMPLEMENTATION
	 
	 //Assigned 'read' port connection pin to safely listen to Audio Codec's ADC stream status
	 assign read = read_ready; 
	 
	 // Gating logic to isolate sound triggers to a single 1-clock edge pulse right when the playhead steps onto a note box
	 logic play_kick, play_clap, play_hh, play_oh;
	 assign play_kick = ticker_incr && row0_reg[playhead_count];
	 assign play_clap = ticker_incr && row1_reg[playhead_count];
	 assign play_hh   = ticker_incr && row2_reg[playhead_count];
	 assign play_oh   = ticker_incr && row3_reg[playhead_count];
	 
	 //Wire up soundSelector to write_ready from the codec hardware, and feed it the single-cycle note pulses
	 soundSelector soundgeneration(
			.clk(CLOCK_50), 
			.reset(reset),
			.write_ready(write_ready), // Now correctly paired with hardware trace wires
			.switcher(switcher),
			.kickPlay(play_kick),      // Now safely modulated to an edge trigger pulse
			.clapPlay(play_clap),      // Now safely modulated to an edge trigger pulse
			.hhPlay(play_hh),          // Now safely modulated to an edge trigger pulse
			.ohPlay(play_oh),          // Now safely modulated to an edge trigger pulse
			.write(write), 
			.writedata_left(writedata_left),
			.writedata_right(writedata_right)
	 );
	 
	/////////////////////////////////////////////////////////////////////////////////
	// Audio CODEC interface. 
	//
	// The interface consists of the following wires:
	// read_ready, write_ready - CODEC ready for read/write operation 
	// readdata_left, readdata_right - left and right channel data from the CODEC
	// read - send data from the CODEC (both channels)
	// writedata_left, writedata_right - left and right channel data to the CODEC
	// write - send data to the CODEC (both channels)
	// AUD_* - should connect to top-level entity I/O of the same name.
	//         These signals go directly to the Audio CODEC
	// I2C_* - should connect to top-level entity I/O of the same name.
	//         These signals go directly to the Audio/Video Config module
	/////////////////////////////////////////////////////////////////////////////////
		clock_generator my_clock_gen(
			// inputs
			CLOCK2_50,
			reset,

			// outputs
			AUD_XCK
		);

		audio_and_video_config cfg(
			// Inputs
			CLOCK_50,
			reset,

			// Bidirectionals
			FPGA_I2C_SDAT,
			FPGA_I2C_SCLK
		);

		audio_codec codec(
			// Inputs
			CLOCK_50,
			reset,

			read,	write,
			writedata_left, writedata_right,

			AUD_ADCDAT,

			// Bidirectionals
			AUD_BCLK,
			AUD_ADCLRCK,
			AUD_DACLRCK,

			// Outputs
			read_ready, write_ready,
			readdata_left, readdata_right,
			AUD_DACDAT
		);
 
	 
	
	assign HEX0 = 7'h7F; assign HEX1 = 7'h7F; assign HEX2 = 7'h7F;
    assign HEX3 = 7'h7F; assign HEX4 = 7'h7F; assign HEX5 = 7'h7F;
    
    assign LEDR[6:0] = grid_idx;
    assign LEDR[9:7] = '0;
		
endmodule