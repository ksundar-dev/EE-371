//Shomik Sen, Kavin Sundar
//LAB 5 MAY 22 2026
/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
 /* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *
 */
module DE1_SoC (
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 
    KEY, LEDR, SW, CLOCK_50,    
    VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS
);
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;    
    output logic [9:0] LEDR;    
    input  logic [3:0] KEY;    
    input  logic [9:0] SW;
    input  logic       CLOCK_50;    
    output [7:0]       VGA_R, VGA_G, VGA_B;    
    output             VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;

	 //used this instead of clock divider to have different pauses between the line drawing and drawing finish so that everything still
	 //operates on the same clock
    localparam [25:0] PAUSE_LAST      = 26'd74999999; //1.5s
    localparam [25:0] INTER_LINE_PAUSE = 26'd17499999; // 0.5s

    //coordinates for each line in the star labeled from 0-9
    localparam [10:0] X0_0=11'd160, Y0_0=11'd20,   X1_0=11'd195, Y1_0=11'd100; // Line 0
	 
    localparam [10:0] X0_1=11'd195, Y0_1=11'd100,  X1_1=11'd280, Y1_1=11'd110; // Line 1
	 
    localparam [10:0] X0_2=11'd280, Y0_2=11'd110,  X1_2=11'd210, Y1_2=11'd160; // Line 2
	 
    localparam [10:0] X0_3=11'd210, Y0_3=11'd160,  X1_3=11'd235, Y1_3=11'd240; // Line 3
	 
    localparam [10:0] X0_4=11'd235, Y0_4=11'd240,  X1_4=11'd160, Y1_4=11'd195; // Line 4
	 
    localparam [10:0] X0_5=11'd160, Y0_5=11'd195,  X1_5=11'd85,  Y1_5=11'd240; // Line 5
	 
    localparam [10:0] X0_6=11'd85,  Y0_6=11'd240,  X1_6=11'd110, Y1_6=11'd160; // Line 6
	 
    localparam [10:0] X0_7=11'd110, Y0_7=11'd160,  X1_7=11'd40,  Y1_7=11'd110; // Line 7
	 
    localparam [10:0] X0_8=11'd40,  Y0_8=11'd110,  X1_8=11'd125, Y1_8=11'd100; // Line 8
	 
    localparam [10:0] X0_9=11'd125, Y0_9=11'd100,  X1_9=11'd160, Y1_9=11'd20;  // Line 9

	
	 //state declerations for the controller, draw the line, wait for line to be done, wait to draw the next line, wait after the full star is drawn, clear the whole screen
    enum logic [2:0] { S_Draw, S_Wait, S_LineP, S_Pause, S_Clear} ps, ns;


	 //reset on key[3] to reset the whole screen no matter what
    logic reset_sig;    
    assign reset_sig = ~KEY[3]; 
	
	//datapath logic/ variables
    logic [10:0] x0_reg, y0_reg, x1_reg, y1_reg; //X0,Y0, X1,Y1 registers
    logic [10:0] line_x, line_y; //tru X,Y coordinate
    logic        line_done;     //done wire that will feed into line drawer
    logic        line_reset;    //local reset for the line drawer
    logic [10:0] vga_x, vga_y;    //vga port connections
    logic        pixel_color, pixel_write; 
    logic [3:0]  line_idx;       //which line we are writing to
    logic [25:0] pause_cnt;     
    logic [8:0]  clear_x;        //wipe every x pixel in the range of our drawing 0-320
    logic [7:0]  clear_y;        //wipe every y pixel in the range of our drawing 0-240
    logic        clear_done;     //internal signal that will assert true when the screen is cleared after the drawing is finished 

    assign clear_done = (clear_x == 9'd319) && (clear_y == 8'd239); 

   //instantiate the line_drawer module
    line_drawer lines (
        .clk   (CLOCK_50), 
        .reset (line_reset), 
        .x0    (x0_reg), .y0(y0_reg), 
        .x1    (x1_reg), .y1(y1_reg), 
        .x     (line_x), .y(line_y), 
        .done  (line_done) 
    );

	 //instantiate the framebuffer module with proper ports
    VGA_framebuffer fb (
        .clk50       (CLOCK_50), .reset(reset_sig), 
        .x           (vga_x), .y(vga_y), 
        .pixel_color (pixel_color), .pixel_write(pixel_write), 
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS, 
        .VGA_BLANK_n (VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N) 
    );

	
	//vga datapath
    always_comb begin    
        case (ps)    
            S_Draw: begin    
                vga_x       = line_x; //draw each line at the proper pixel
                vga_y       = line_y; //draw each line at the proper pixel
                pixel_color = 1'b1;   //set color to white
                pixel_write = 1'b1; 	//draw enable
            end    
            S_Clear: begin    
                vga_x       = {2'b00, clear_x}; //make the clear the same size as vga_x
                vga_y       = {3'b000, clear_y};  //make the clear the same size as vga_y
                pixel_color = 1'b0;   
                pixel_write = 1'b1; 
            end    
            default: begin  
                vga_x       = 11'd0;  //set default everything to zero
                vga_y       = 11'd0; 
                pixel_color = 1'b0; 
                pixel_write = 1'b0; 
            end    
        endcase    
    end    


	
    always_comb begin
        case (line_idx)    
            4'd0:    begin 
								x0_reg = X0_0; y0_reg = Y0_0; x1_reg = X1_0; y1_reg = Y1_0; //line 1
							end 
            4'd1:    begin 
								x0_reg = X0_1; y0_reg = Y0_1; x1_reg = X1_1; y1_reg = Y1_1; //line 2
							end 
            4'd2:    begin 
								x0_reg = X0_2; y0_reg = Y0_2; x1_reg = X1_2; y1_reg = Y1_2; //line 3
							end 
            4'd3:    begin 
								x0_reg = X0_3; y0_reg = Y0_3; x1_reg = X1_3; y1_reg = Y1_3; //line 4
							end 
            4'd4:    begin 
								x0_reg = X0_4; y0_reg = Y0_4; x1_reg = X1_4; y1_reg = Y1_4; //line 5
							end 
            4'd5:    begin 
								x0_reg = X0_5; y0_reg = Y0_5; x1_reg = X1_5; y1_reg = Y1_5;//line 6
							end
            4'd6:    begin 
								x0_reg = X0_6; y0_reg = Y0_6; x1_reg = X1_6; y1_reg = Y1_6; //line 7
							end
            4'd7:    begin 
								x0_reg = X0_7; y0_reg = Y0_7; x1_reg = X1_7; y1_reg = Y1_7; //line 8
							end
            4'd8:    begin 
								x0_reg = X0_8; y0_reg = Y0_8; x1_reg = X1_8; y1_reg = Y1_8; //line 9
							end
            4'd9:    begin 
								x0_reg = X0_9; y0_reg = Y0_9; x1_reg = X1_9; y1_reg = Y1_9; //line 10
							end
            default: begin x0_reg = X0_0; y0_reg = Y0_0; x1_reg = X1_0; y1_reg = Y1_0; end //default is line zero
        endcase    
    end


    always_comb begin
        ns = ps; //default case

        case (ps)
            S_Draw: begin  //draw case
                if (line_done) ns = S_LineP; //if the line_done status signal is asserted then pause at the finished drawing
                else           ns = S_Draw;   //otherwise draw
            end

            S_LineP: begin
                if (pause_cnt == INTER_LINE_PAUSE) begin //it has paused long enough between lines being drawn
                    if (line_idx == 4'd9) ns = S_Pause;  //if we have finished drawing the last line then stay paused
                    else                  ns = S_Wait;
                end
                else ns = S_LineP;  //stay here until pause cnt is incremented enough 
            end

            S_Wait: begin
                if (!line_done) ns = S_Draw; //if the line is not done being drawn then still draw
                else            ns = S_Wait; //otherwise wait in between lines being drawn
            end

            S_Pause: begin
                if (pause_cnt == PAUSE_LAST) ns = S_Clear; //once the drawing is finished if the pause is done incrementing then clear the frame
                else                         ns = S_Pause; //otherwise still increment the pause timer
            end

            S_Clear: begin
                if (clear_done) ns = S_Wait; //clear or dont clear
                else            ns = S_Clear;
            end

            default: ns = S_Clear;
        endcase
    end


	//controls the lines being drawn and the pause counters being incremented
    always_ff @(posedge CLOCK_50) begin    
        if (reset_sig) begin    //logic on reset
            ps        <= S_Clear; 
            line_idx  <= 4'd0; 
            pause_cnt <= '0; 
            clear_x   <= '0; 
            clear_y   <= '0; 
        end    
        else begin    
            ps <= ns; // switch between states

            case (ps)    
                S_Draw: begin    
                    //nothing changes just drawing
                end    

                S_LineP: begin
                    if (pause_cnt == INTER_LINE_PAUSE) begin 
                        pause_cnt <= '0; // Clear the counter
                        if (line_idx != 4'd9) begin       
                            line_idx <= line_idx + 4'd1; // after paused for long enough draw the next line
                        end
                    end
                    else begin
                        pause_cnt <= pause_cnt + 26'd1; //otherwise increment the pause count
                    end
                end

                S_Wait: begin    
                    // nothing happens here either just wait for human eyes to process
                end    

                S_Pause: begin    
                    if (pause_cnt == PAUSE_LAST) begin  //when the final image has been held for long enough clearing has to start
                        pause_cnt <= '0;  //
                        clear_x   <= '0; 
                        clear_y   <= '0; 
                    end    
                    else begin
                        pause_cnt <= pause_cnt + 26'd1;  //increment the pause count until it has been held for long enough 
                    end
                end    

                S_Clear: begin    
                    if (clear_done) begin 
                        line_idx <= 4'd0; // when it is done clearing draw the first line again
                    end    
                    else begin    
                        if (clear_x == 9'd319) begin //if clear x is done
                            clear_x <= '0; 
                            clear_y <= clear_y + 8'd1; //increment and cleary y
                        end    
                        else begin
                            clear_x <= clear_x + 9'd1;  //otherwise clear x first
                        end
                    end    
                end    
            endcase    
        end    
    end    


	//we need these line resets to be asserted becuase our line drawer stays in the done state until reset is asserted
    always_comb begin

        line_reset = 1'b0;
		  
		  //if the reset is triggered call the internal reset signal
        if (reset_sig) begin
            line_reset = 1'b1;
        end
		  //if it is in clear state and done clearing reset the internal signal
        else if (ps == S_Clear && clear_done) begin
            line_reset = 1'b1;
        end
		  //trigger the next line to draw when the star is not finished and the pause has been long enough
        else if (ps == S_LineP && pause_cnt == INTER_LINE_PAUSE && line_idx != 4'd9) begin
            line_reset = 1'b1;
        end
		  //trigger after it has waited and the previous line is done drawing
        else if (ps == S_Wait && line_done) begin
            line_reset = 1'b1;
        end
    end

	
	//sets all the HEX and LEDR to appropriate values

    assign HEX0 = '1; assign HEX1 = '1; assign HEX2 = '1;
    assign HEX3 = '1; assign HEX4 = '1; assign HEX5 = '1;
    assign LEDR[8:0] = SW[8:0];

endmodule


